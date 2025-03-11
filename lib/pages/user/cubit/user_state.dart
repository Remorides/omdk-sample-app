part of 'user_cubit.dart';

/// State of home page
@immutable
final class UserState {
  /// [UserState] instance with default data
  const UserState({
    this.item = null,
    this.status = LoadingStatus.initial,
    this.errorMessage = '',
  });

  /// List of elements
  final User? item;

  /// status of the page
  final LoadingStatus status;

  /// error message
  final String errorMessage;


  /// Update state with input data
  UserState copyWith({
    User? item,
    LoadingStatus? status,
    String? errorMessage,
  }) {
    return UserState(
      item: item ?? this.item,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}