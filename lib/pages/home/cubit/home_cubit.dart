import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/common/enums/loading_status.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';

part 'home_state.dart';

/// [Cubit] logic for home widget
class HomeCubit extends Cubit<HomeState> {
  /// [OperaUserRepo] for the api
  final OperaUserRepo userRepo;

  /// Constructor that initializes the Cubit and automatically loads the data
  HomeCubit({
    required this.userRepo,
  }) : super(const HomeState());

  /// loads data
  Future<void> loadItems() async {
    // update status into progress
    emit(state.copyWith(status: LoadingStatus.inProgress));

    final apiRequest = await userRepo.getAPIItems(0, 50);
    // menage the result
    apiRequest.fold(
      (pagedData) {
        // Success
        emit(
          state.copyWith(
            items: pagedData,
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
}
