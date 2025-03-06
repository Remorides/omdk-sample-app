import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_repo/omdk_repo.dart';

part 'auth_event.dart';

part 'auth_state.dart';

/// Authentication bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// create [AuthBloc] instance
  AuthBloc({
    required AuthRepo authRepo,
    required OMDKLocalData localData,
  })  : _authRepo = authRepo,
        _localData = localData,
        super(const AuthState.unknown()) {
    on<_AuthStatusChanged>(_onAuthStatusChanged);
    on<LogoutRequested>(_onAuthLogoutRequested);
    on<RestoreSession>(_onRestoreSession);
    on<ValidateOTP>(_onOTPValidate);
    _authStatusSubscription = _authRepo.status.listen(
      (status) => add(_AuthStatusChanged(status)),
    );
  }

  /// Current logged user guid in string format
  String? get loggedUserGUID => state.user.guid;

  final AuthRepo _authRepo;
  final OMDKLocalData _localData;

  // Subscription stream to notify session status changes
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    return super.close();
  }

  Future<void> _onRestoreSession(
    RestoreSession event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepo.restoreLastSession();
  }

  Future<void> _onAuthStatusChanged(
    _AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        emit(const AuthState.unauthenticated());
      case AuthStatus.tokenExpired:
        final user = _authRepo.user;
        if (user == null) {
          emit(const AuthState.unauthenticated());
          return;
        }
        emit(AuthState.tokenExpired(user));
      case AuthStatus.authenticated:
        final user = _authRepo.user;
        if (user == null) {
          emit(const AuthState.unauthenticated());
        } else {
          try {
            await _initIsarDB(user.guid);
            emit(AuthState.authenticated(user));
          } on Exception catch (_) {
            emit(const AuthState.unauthenticated());
          }
        }
      case AuthStatus.unknown:
        emit(const AuthState.unknown());
      case AuthStatus.otpFailed:
        emit(const AuthState.otpFails());
      case AuthStatus.conflicted:
        emit(const AuthState.conflict());
    }
  }

  Future<void> _initIsarDB(String userGuid) async {
    await _localData.isarManager.initUserDB(
      isarSchemas: [
        AssetSchema,
        AttachmentSchema,
        NodeSchema,
        NotificationSchema,
        ScheduledActivitySchema,
        UserSchema,
        OSchemaSchema,
        //TemplateActivitySchema,
        GroupSchema,
        MappingMapSchema,
        MappingVersionSchema,
        OrganizationNodeSchema,
        SparePartGroupSchema,
        WarehouseSchema,
        ToolSchema,
        FlowSchema,
      ],
      userGUID: userGuid,
    );
  }

  Future<void> _onOTPValidate(
    ValidateOTP event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepo.validateOTP(authOTP: AuthOTP(otp: event.otp));
  }

  Future<void> _onAuthLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final tokenData = _authRepo.tokenData;
    await _authRepo.logOut(closeIsarDB: true);
    if (tokenData?['CompanyCode'] is String) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(
        '${tokenData?['CompanyCode']}_${loggedUserGUID}_Node',
      );
      await FirebaseMessaging.instance.unsubscribeFromTopic(
        '${tokenData?['CompanyCode']}_${loggedUserGUID}_Asset',
      );
    }
  }
}
