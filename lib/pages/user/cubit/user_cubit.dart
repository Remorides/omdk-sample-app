import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/common/enums/loading_status.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';

part 'user_state.dart';

/// [Cubit] logic for home widget
class UserCubit extends Cubit<UserState> {
  /// [OperaUserRepo] for the api
  final OperaUserRepo userRepo;
  final OMDKLocalData omdkLocalData;
  final OperaAttachmentRepo attachmentRepo;
  final OperaUtils operaUtils;

  /// Constructor that initializes the Cubit and automatically loads the data
  UserCubit({
    required this.userRepo,
    required this.omdkLocalData,
    required this.attachmentRepo,
    required this.operaUtils,
  }) : super(const UserState());

  /// loads data
  Future<void> loadItem(String guid) async {
    // update status into progress
    emit(state.copyWith(status: LoadingStatus.inProgress));

    final apiRequest = await userRepo.getAPIItem(guid: guid);
    // menage the result
    apiRequest.fold(
      (data) {
        // Success
        emit(
          state.copyWith(
            item: data,
            status: LoadingStatus.done,
            errorMessage: '',
          ),
        );
      },
      (failure) {
        // Error
        emit(
          state.copyWith(
            status: LoadingStatus.failure,
            errorMessage: failure.toString(),
          ),
        );
      },
    );
  }

  Future<void> changePhoto() async {
    final files = await omdkLocalData.mediaManager.pickFiles();
    if (files != null && files.isNotEmpty) {
      final apiRequest = await attachmentRepo.upload(file: files.first);
      // menage the result
      await apiRequest.fold(
        (data) async {
          final tempPartecipationList = List<JUserParticipation>.from(
            state.item?.partecipationsList ?? [],
          );

          final myPartecipation = await operaUtils.getUserParticipation();
          final meIndex =
              tempPartecipationList.indexMe(myPartecipation.user!.guid);
          if (meIndex != null) {
            tempPartecipationList[meIndex] = tempPartecipationList[meIndex]
                .copyWith(timeStamp: myPartecipation.timeStamp);
          } else {
            tempPartecipationList.add(myPartecipation);
          }

          // Success
          final newUser = state.item?.copyWith(
            entity: state.item?.entity.copyWith(
              photo: data.guid,
            ),
            attachmentsList: [
              ...state.item?.attachmentsList ?? <JAttachment>[],
              data.attachment
            ],
            partecipationsList: tempPartecipationList,
          );

          final userRequestApi = await userRepo.putAPIItem(newUser!);

          userRequestApi.fold(
              (user) =>
                  emit(state.copyWith(item: user, status: LoadingStatus.done)),
              (failure) => emit(state.copyWith(
                  errorMessage: "Error!", status: LoadingStatus.failure)),);
        },
        (failure) {
          emit(state.copyWith(
              errorMessage: "Error!", status: LoadingStatus.failure),);
        },
      );
    }
  }
}
