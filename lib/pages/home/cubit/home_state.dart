part of 'home_cubit.dart';

/// State of home page
@immutable
final class HomeState {
  /// [HomeState] instance with default data
  const HomeState({
    this.items = const [],
    this.status = LoadingStatus.initial,
    this.errorMessage = '',
  });

  /// List of elements
  final List<User> items;

  /// status of the page
  final LoadingStatus status;

  /// error message
  final String errorMessage;


  /// Update state with input data
  HomeState copyWith({
    List<User>? items,
    LoadingStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}