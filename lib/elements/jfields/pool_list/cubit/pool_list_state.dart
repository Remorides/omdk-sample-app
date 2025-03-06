part of 'pool_list_cubit.dart';

@immutable
final class PoolListState<T> extends Equatable {
  const PoolListState({
    required this.listItem,
    required this.isEnabled,
    this.selectedItem,
    this.errorText = '',
    this.status = LoadingStatus.initial,
  });

  final LoadingStatus status;
  final List<T?> listItem;
  final T? selectedItem;
  final String errorText;
  final bool isEnabled;

  PoolListState<T> copyWith({
    LoadingStatus? status,
    List<T>? listItem,
    T? selectedItem,
    String? errorText,
    bool? isEnabled,
  }) =>
      PoolListState(
        status: status ?? this.status,
        listItem: listItem ?? this.listItem,
        selectedItem: selectedItem ?? this.selectedItem,
        errorText: errorText ?? this.errorText,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  @override
  List<Object?> get props => [
        status,
        listItem,
        selectedItem,
        isEnabled,
        errorText,
      ];
}
