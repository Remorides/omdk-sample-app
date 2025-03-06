part of 'login_cubit.dart';

/// Login form bloc
@immutable
final class LoginState {
  /// [LoginState] instance with default data
  const LoginState({
    this.status = LoadingStatus.initial,
    this.companyCode = '',
    this.username = '',
    this.password = '',
    this.errorText = '',
    this.rememberMe = false,
  });

  /// Login status enums is used to notify error in authentication
  /// or provide authentication progress status
  final LoadingStatus status;

  /// User company code
  final String companyCode;

  /// User username
  final String username;

  /// User password
  final String password;

  /// User password
  final String errorText;

  /// remeber me
  final bool rememberMe;

  /// Update state with input data
  LoginState copyWith({
    LoadingStatus? status,
    String? companyCode,
    String? username,
    String? password,
    String? errorText,
    bool? rememberMe,
  }) {
    return LoginState(
      status: status ?? this.status,
      companyCode: companyCode ?? this.companyCode,
      username: username ?? this.username,
      password: password ?? this.password,
      errorText: errorText ?? this.errorText,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
