import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:omdk_local_data/omdk_local_data.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/jfields/file/enum/errors.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';

part 'field_file_state.dart';

class FieldFileCubit extends Cubit<FieldFileState> {
  FieldFileCubit({
    required this.entityGuid,
    required this.entityType,
    required bool isEnabled,
    required OMDKLocalData omdkLocalData,
    required OperaAttachmentRepo attachmentRepo,
    required EntityRepo<Asset> assetRepo,
    required EntityRepo<Node> nodeRepo,
    required EntityRepo<ScheduledActivity> scheduledRepo,
    required EntityRepo<Tool> toolRepo,
    required OperaUtils operaUtils,
  })  : _omdkLocalData = omdkLocalData,
        _attachmentRepo = attachmentRepo,
        _assetRepo = assetRepo,
        _nodeRepo = nodeRepo,
        _scheduledRepo = scheduledRepo,
        _operaUtils = operaUtils,
        _toolRepo = toolRepo,
        super(FieldFileState(isEnabled: isEnabled));

  final String entityGuid;
  final JEntityType entityType;
  final OMDKLocalData _omdkLocalData;
  final OperaAttachmentRepo _attachmentRepo;
  final OperaUtils _operaUtils;
  final EntityRepo<Asset> _assetRepo;
  final EntityRepo<Node> _nodeRepo;
  final EntityRepo<ScheduledActivity> _scheduledRepo;
  final EntityRepo<Tool> _toolRepo;

  Future<void> loadFiles(List<String>? guids, String? selected) async {
    // Empty field
    if (guids == null || guids.isEmpty) {
      emit(state.copyWith(isLoading: false));
    } else {
      final fileList = <File>[];
      final attachmentList = <Attachment>[];

      for (final guid in guids) {
        Attachment? attachmentEntity;
        if (!kIsWeb) {
          // Retrieve file entity from db
          final attachmentRequest =
              await _attachmentRepo.readLocalItem(itemID: guid);
          attachmentRequest.fold(
            (data) => attachmentEntity = data,
            (failure) async {
              try {
                // If attachment wasn't found in db try to download it
                attachmentEntity ??= await _downloadEntityAttachment(guid);
                final file = await _retrieveFile(attachmentEntity!);

                fileList.add(file);
                attachmentList.add(attachmentEntity!);
              } on Exception catch (e) {
                _omdkLocalData.logManager.log(
                  LogType.warning,
                  '${e}',
                );
              }
            },
          );
        }
      }

      emit(
        state.copyWith(
          fileList: fileList,
          attachmentList: attachmentList,
          selectedAttachment:
              attachmentList.firstWhereOrNull((a) => a.entity.guid == selected),
          isLoading: false,
        ),
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
      switch (entityType) {
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

  void enable() => emit(state.copyWith(isEnabled: true));

  void disable() => emit(state.copyWith(isEnabled: false));

  void changeSelected(Attachment? attachment) =>
      emit(state.copyWith(selectedAttachment: attachment));

  Future<Attachment?> addFile({
    bool replaceFile = false,
    File? fileToRemove,
    Attachment? attachmentToRemove,
  }) async {
    assert(
      !replaceFile ||
          replaceFile && fileToRemove != null && attachmentToRemove != null,
      throw AssertionError('File and FileEntity not provided'),
    );
    emit(state.copyWith(isLoading: true));

    final itemFile = await _omdkLocalData.mediaManager.pickFile();

    if (itemFile == null) {
      emit(state.copyWith(isLoading: false));
      return null;
    }

    final file = File(itemFile.path);

    var fileEntity = await _operaUtils.buildAttachmentEntity(file);
    // Save file to app directory
    final filePath = await _omdkLocalData.fileManager.createFolder(
      fileEntity.entity.guid!,
    );
    await _omdkLocalData.fileManager.saveFile(
      file.readAsBytesSync(),
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
    switch (entityType) {
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
        syncStatus: SyncStatus.toUpload,
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
        selectedAttachment: fileEntity,
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
    } on Exception {
      rethrow;
    }
  }

  void removeFile(Attachment a, File f) {
    final updatedAttachmentList = [...state.attachmentList..remove(a)];
    emit(
      state.copyWith(
        selectedAttachment: updatedAttachmentList.firstOrNull,
        attachmentList: updatedAttachmentList,
        fileList: [...state.fileList..remove(f)],
      ),
    );
  }

  Future<Entity> get _entity async {
    final dbRequest = await _entityRepo.readLocalItem(itemID: entityGuid);
    return dbRequest.fold(
      (entity) => entity,
      (failure) => throw Exception(),
    );
  }

  EntityRepo<Entity> get _entityRepo => switch (entityType) {
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
