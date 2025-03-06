part of 'auth_bloc.dart';

/// [AuthState]
@immutable
class AuthState extends Equatable {
  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user = AuthenticatedUser.empty,
  });

  /// Default state on start app
  const AuthState.unknown() : this._();

  /// Failed to get session from otp provided
  const AuthState.otpFails()
      : this._(
          status: AuthStatus.otpFailed,
          user: AuthenticatedUser.empty,
        );

  /// Conflict status in openedSession
  const AuthState.conflict()
      : this._(
          status: AuthStatus.conflicted,
          user: AuthenticatedUser.empty,
        );

  /// User authenticated
  const AuthState.authenticated(
    AuthenticatedUser user,
  ) : this._(
          status: AuthStatus.authenticated,
          user: user,
        );

  /// User authenticated but token expired
  const AuthState.tokenExpired(
      AuthenticatedUser user,
      ) : this._(
    status: AuthStatus.tokenExpired,
    user: user,
  );

  /// Session found but request user to login again
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  /// value to show authStatus
  final AuthStatus status;

  /// user authenticated
  final AuthenticatedUser user;

  @override
  List<Object> get props => [
        status,
        user,
      ];
}
