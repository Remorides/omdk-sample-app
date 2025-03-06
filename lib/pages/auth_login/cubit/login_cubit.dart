import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/common/enums/loading_status.dart';

part 'login_state.dart';

/// [Cubit] logic for login form widget
class LoginCubit extends Cubit<LoginState> {
  /// create [LoginCubit] instance
  LoginCubit({
    required AuthRepo authRepo,
    String? companyCode,
  })  : _authRepo = authRepo,
        super(LoginState(companyCode: companyCode ?? ''));

  final AuthRepo _authRepo;

  /// Metodo per cambiare il companyCode
  void companyCodeChanged(String companyCode) {
    emit(
      state.copyWith(
        companyCode: companyCode,
      ),
    );
  }

  /// Metodo per cambiare lo stato dell'username
  void usernameChanged(String username) {
    emit(
      state.copyWith(
        status: LoadingStatus.initial,
        username: username,
      ),
    );
  }

  /// Metodo per cambiare la password
  void passwordChanged(String password) {
    emit(
      state.copyWith(
        status: LoadingStatus.initial,
        password: password,
      ),
    );
  }

  /// Metodo per cambiare il rememberMe
  void rememberMeChanged(bool rememberMe) {
    emit(
      state.copyWith(
        rememberMe: rememberMe,
      ),
    );
  }

  /// Metodo per gestire i campi vuoti
  void _handleEmptyField() {
    emit(
      state.copyWith(
        status: LoadingStatus.failure,
        errorText: 'Some fields are empty, please check it and retry',
      ),
    );
  }

  /// Metodo per la login offline
  Future<void> loginOffline() async {
    /// perchè qua non faccio l'emit del status progress?
    try {
      await _authRepo
          .logInOffline(
        authLogin: AuthLogin(
          companyCode: state.companyCode,
          userName: state.username,
          password: state.password,
          clientTypeId: ClientType.Mobile.name,
        ).toJson(),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout reached'),
      );
      emit(state.copyWith(status: LoadingStatus.done));
    } on Exception {
      emit(
        state.copyWith(
          status: LoadingStatus.failure,
          errorText: 'Authentication failure, please try again',
        ),
      );
    }
  }

  /// Metodo per la submit del della login
  Future<void> login() async {
    if (state.companyCode.isEmpty ||
        state.username.isEmpty ||
        state.password.isEmpty) {
      _handleEmptyField();
      return;
    }

    emit(state.copyWith(status: LoadingStatus.inProgress));

    try {
      await _authRepo
          .logIn(
        authLogin: AuthLogin(
          companyCode: state.companyCode,
          userName: state.username,
          password: state.password,
          clientTypeId: ClientType.Mobile.name,
        ).toJson(),
        allowOfflineLogin: true,
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Timeout reached'),
      );

      emit(state.copyWith(status: LoadingStatus.done));
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        await loginOffline();
      } else if (e is DioException) {
        if (e.response?.statusCode == 409) {
          emit(
            state.copyWith(
              status: LoadingStatus.failure,
              errorText: '409 - Conflict',
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: LoadingStatus.failure,
              errorText: 'Authentication failure, please try again',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: LoadingStatus.failure,
            errorText: 'Authentication failure, please try again',
          ),
        );
      }
    }
  }
}