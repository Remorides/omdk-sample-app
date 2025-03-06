import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omdk_local_data/omdk_local_data.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';

part 'field_image_state.dart';

class FieldImageCubit extends Cubit<FieldImageState> {
  FieldImageCubit({
    required bool isActionEnabled,
    required String entityGuid,
    required String? fieldGuid,
    required JEntityType entityType,
    required OMDKLocalData omdkLocalData,
    required OperaUtils operaUtils,
    required OperaAttachmentRepo attachmentRepo,
    required EntityRepo<Asset> assetRepo,
    required EntityRepo<Node> nodeRepo,
    required EntityRepo<ScheduledActivity> scheduledRepo,
    required EntityRepo<Tool> toolRepo,
  })  : _entityGuid = entityGuid,
        _fieldGuid = fieldGuid,
        _entityType = entityType,
        _omdkLocalData = omdkLocalData,
        _operaUtils = operaUtils,
        _attachmentRepo = attachmentRepo,
        _assetRepo = assetRepo,
        _nodeRepo = nodeRepo,
        _scheduledRepo = scheduledRepo,
        _toolRepo = toolRepo,
        super(FieldImageState(isActionEnabled: isActionEnabled));

  final String _entityGuid;
  final String? _fieldGuid;
  final JEntityType _entityType;
  final OMDKLocalData _omdkLocalData;

  final OperaAttachmentRepo _attachmentRepo;
  final EntityRepo<Asset> _assetRepo;
  final EntityRepo<Node> _nodeRepo;
  final EntityRepo<ScheduledActivity> _scheduledRepo;
  final EntityRepo<Tool> _toolRepo;
  final OperaUtils _operaUtils;

  Future<void> loadImages(List<String> imageGuidList) async {
    if (imageGuidList.isEmpty) {
      emit(state.copyWith(isLoading: false));
    } else {
      final fileList = <File>[];
      final attachmentList = <Attachment>[];

      for (final guid in imageGuidList) {
        Attachment? attachmentEntity;

        if (!kIsWeb) {
          // Try to retrieve file entity from db
          final attachmentRequest =
              await _attachmentRepo.readLocalItem(itemID: guid);
          attachmentRequest.fold(
            (data) => attachmentEntity = data,
            (failure) => _omdkLocalData.logManager.log(
              LogType.warning,
              '$guid Attachment entity not found in isarDB',
            ),
          );
        }

        try {
          // If attachment wasn't found in db try to download it
          attachmentEntity ??= await _downloadEntityAttachment(guid);
          final file = await _retrieveFile(attachmentEntity!);

          fileList.add(file);
          attachmentList.add(attachmentEntity!);
        } on Exception catch (e) {
          _omdkLocalData.logManager.log(
            LogType.warning,
            '$e.userFriendlyMessage',
          );
        }
      }
      emit(
        state.copyWith(
          fileList: fileList,
          attachmentList: attachmentList,
          isLoading: false,
        ),
      );
    }
  }

  Future<File> _retrieveFile(Attachment aEntity) async {
    try {
      final folderPath =
          await _omdkLocalData.fileManager.getDownloadDirectoryPath;
      return await _omdkLocalData.fileManager
          .getFile('$folderPath/${aEntity.guid}/'
              '${aEntity.attachment.fileName}');
    } on FileException {
      // Try to download file
      final downloadRequest = await _attachmentRepo.download(
        guidAttachment: aEntity.guid!,
      );

      Uint8List? fileData;
      downloadRequest.fold(
        (data) => fileData = data,
        (failure) => throw failure,
      );

      // Create attachment folder
      final filePath =
          await _omdkLocalData.fileManager.createFolder(aEntity.guid!);

      // Update attachmentEntity
      await _attachmentRepo.updateLocalItem(
        aEntity.copyWith(mediaStatus: MediaStatus.synced),
        aEntity.guid!,
      );

      return _omdkLocalData.fileManager.saveFile(
        fileData!,
        '$filePath/${aEntity.attachment.fileName}',
      );
    }
  }

  Future<Attachment> _downloadEntityAttachment(String guid) async {
    // If attachment wasn't found in db try to download it
    final attachmentRequest = await _attachmentRepo.getAPIItem(guid: guid);
    var attachmentEntity = attachmentRequest.fold(
      (data) => data,
      (failure) => throw AttachmentException(failure.toString()),
    );

    // Download thumbnail from server
    final thumbnailRequest = await _attachmentRepo.downloadThumbnailString(
      guidAttachment: attachmentEntity.entity.guid!,
    );

    thumbnailRequest.fold(
      (thumbnail) => attachmentEntity = attachmentEntity.copyWith(
        entity: attachmentEntity.entity.copyWith(thumbnail: thumbnail),
      ),
      (failure) => null,
    );

    if (!kIsWeb) {
      final entity = await _entity;
      switch (_entityType) {
        case JEntityType.ScheduledActivity:
          attachmentEntity.scheduledLink.value = entity as ScheduledActivity;
          entity.attachments.add(attachmentEntity);
        case JEntityType.Asset:
          attachmentEntity.assetLink.value = entity as Asset;
          entity.attachments.add(attachmentEntity);
        case JEntityType.Node:
          attachmentEntity.nodeLink.value = entity as Node;
          entity.attachments.add(attachmentEntity);
        case JEntityType.Tool:
          attachmentEntity.toolLink.value = entity as Tool;
          entity.attachments.add(attachmentEntity);
        default:
          break;
      }
      _attachmentRepo.saveLocalItemSync(attachmentEntity);

      // Update entity with attachment isar links
      _entityRepo.updateLocalItemSync(entity, entity.guid!);
    }
    return attachmentEntity;
  }

  Future<Attachment?> _addImage(
    File file, {
    bool replaceFile = false,
    File? fileToRemove,
    String? fileName,
    Attachment? attachmentToRemove,
    Uint8List? rawData,
  }) async {
    assert(
      !replaceFile ||
          replaceFile && fileToRemove != null && attachmentToRemove != null,
      throw AssertionError('File and FileEntity not provided'),
    );
    var fileEntity = await _operaUtils.buildAttachmentEntity(
      file,
      fileName: fileName,
      mimeType: 'image/jpeg',
      fieldReference: _fieldGuid,
    );
    // Save file to app directory
    final filePath = await _omdkLocalData.fileManager.createFolder(
      fileEntity.entity.guid!,
    );
    await _omdkLocalData.fileManager.saveFile(
      rawData ?? file.readAsBytesSync(),
      '$filePath/${fileEntity.attachment.fileName}',
    );

    // try to upload it to server
    final apiRequest = await _attachmentRepo.upload(
      file: file,
      guid: fileEntity.guid,
    );
    apiRequest.fold(
      (success) => fileEntity = fileEntity.copyWith(
        mediaStatus: MediaStatus.synced,
      ),
      (success) => null,
    );

    final entity = await _entity;
    switch (_entityType) {
      case JEntityType.ScheduledActivity:
        fileEntity.scheduledLink.value = entity as ScheduledActivity;
        entity.attachments.add(fileEntity);
      case JEntityType.Asset:
        fileEntity.assetLink.value = entity as Asset;
        entity.attachments.add(fileEntity);
      case JEntityType.Node:
        fileEntity.nodeLink.value = entity as Node;
        entity.attachments.add(fileEntity);
      case JEntityType.Tool:
        fileEntity.toolLink.value = entity as Tool;
        entity.attachments.add(fileEntity);
      default:
        break;
    }

    // Save attachmentEntity with entity link
    _attachmentRepo.saveLocalItemSync(fileEntity);

    // Build new attachmentList
    final attachmentList = [...entity.attachmentsList];
    final indexAttachmentList =
        attachmentList.indexWhere((a) => a.guid == attachmentToRemove?.guid);

    if (replaceFile) {
      if (attachmentToRemove?.mediaStatus == MediaStatus.toUpload) {
        attachmentList.removeAt(indexAttachmentList);
      } else {
        attachmentList[indexAttachmentList] =
            attachmentList[indexAttachmentList].copyWith(
          removed: await _operaUtils.getParticipationDate(),
        );
      }
    }
    attachmentList.add(fileEntity.attachment);

    // Save file with entity reference
    _entityRepo.updateLocalItemSync(
      entity.copyWith(
        dates: entity.dates.copyWith(
          modified: await _operaUtils.getParticipationDate(),
        ),
        attachmentsList: attachmentList,
      ),
      entity.guid!,
    );

    //Cubit index
    final indexCubit = state.attachmentList
        .indexWhere((a) => a.guid == attachmentToRemove?.guid);

    emit(
      state.copyWith(
        isLoading: false,
        fileList: replaceFile
            ? [...state.fileList..removeAt(indexCubit), file]
            : [...state.fileList, file],
        attachmentList: replaceFile
            ? [
                ...state.attachmentList..removeAt(indexCubit),
                fileEntity,
              ]
            : [...state.attachmentList, fileEntity],
      ),
    );
    return fileEntity;
  }

  Future<Attachment?> addEditedhoto(
    Uint8List editedFile, {
    bool replaceFile = false,
    File? fileToRemove,
    String? fileName,
    Attachment? attachmentToRemove,
  }) async {
    emit(state.copyWith(isLoading: true));
    // final wFile = await _omdkLocalData.watermarkService.addCoordinateWatermark(
    //   File.fromRawPath(editedFile),
    //   latitudeLabel: 'Latitude:',
    //   longitudeLabel: 'Longitude:',
    //   withUserData: false,
    // );
    return _addImage(
      File.fromRawPath(editedFile),
      replaceFile: replaceFile,
      fileName: fileName,
      fileToRemove: fileToRemove,
      attachmentToRemove: attachmentToRemove,
      rawData: editedFile,
    );
  }

  Future<Attachment?> takeCameraPhoto({
    required String? userFullName,
    required bool withWatermark,
    bool replaceFile = false,
    File? fileToRemove,
    Attachment? attachmentToRemove,
  }) async {
    final imageFile = await _omdkLocalData.mediaManager.takePicture(
      CameraDevice.rear,
    );
    if (imageFile != null) {
      emit(state.copyWith(isLoading: true));
      final file = withWatermark
          ? await _addWatermark(File(imageFile.path), userFullName)
          : File(imageFile.path);
      return _addImage(
        file,
        replaceFile: replaceFile,
        fileToRemove: fileToRemove,
        attachmentToRemove: attachmentToRemove,
      );
    }
    return null;
  }

  Future<Attachment?> pickImage({
    required String? userFullName,
    required bool withWatermark,
    bool replaceFile = false,
    File? fileToRemove,
    Attachment? attachmentToRemove,
  }) async {
    final imageFile = await _omdkLocalData.mediaManager.selectPicture();
    if (imageFile != null) {
      emit(state.copyWith(isLoading: true));
      final file = withWatermark
          ? await _addWatermark(File(imageFile.path), userFullName)
          : File(imageFile.path);
      return _addImage(
        file,
        replaceFile: replaceFile,
        fileToRemove: fileToRemove,
        attachmentToRemove: attachmentToRemove,
      );
    }
    return null;
  }

  Future<File> _addWatermark(File file, String? userFullName) async =>
      _omdkLocalData.watermarkService.addCoordinateWatermark(
        photo: file,
        userFullName: userFullName,
        latitudeLabel: 'Latitude:',
        longitudeLabel: 'Longitude:',
      );

  void removeImage(Attachment a, File f) => emit(
        state.copyWith(
          attachmentList: [...state.attachmentList..remove(a)],
          fileList: [...state.fileList..remove(f)],
        ),
      );

  Future<Entity> get _entity async {
    final dbRequest = await _entityRepo.readLocalItem(itemID: _entityGuid);
    return dbRequest.fold(
      (entity) => entity,
      (failure) => throw Exception(),
    );
  }

  EntityRepo<Entity> get _entityRepo => switch (_entityType) {
        JEntityType.None => throw UnimplementedError(),
        JEntityType.TemplateActivity => throw UnimplementedError(),
        JEntityType.ScheduledActivity => _scheduledRepo,
        JEntityType.Asset => _assetRepo,
        JEntityType.Node => _nodeRepo,
        JEntityType.User => throw UnimplementedError(),
        JEntityType.Group => throw UnimplementedError(),
        JEntityType.Tool => _toolRepo,
        JEntityType.SparePartGroup => throw UnimplementedError(),
        JEntityType.Warehouse => throw UnimplementedError(),
        JEntityType.IotDevice => throw UnimplementedError(),
        JEntityType.Attachment => throw UnimplementedError(),
        JEntityType.Ticket => throw UnimplementedError(),
        JEntityType.Schema => throw UnimplementedError(),
        JEntityType.Flow => throw UnimplementedError(),
      };
}
