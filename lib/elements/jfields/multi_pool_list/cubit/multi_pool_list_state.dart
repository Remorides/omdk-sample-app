part of 'multi_pool_list_cubit.dart';

@immutable
final class MultiPoolListState<E> extends Equatable {
  const MultiPoolListState({
    required this.listItem,
    required this.isEnabled,
    required this.selectedItems,
    this.status = LoadingStatus.initial,
  });

  final LoadingStatus status;
  final List<E> listItem;
  final List<E> selectedItems;
  final bool isEnabled;

  MultiPoolListState<E> copyWith({
    LoadingStatus? status,
    List<E>? listItem,
    List<E>? selectedItems,
    String? errorText,
    bool? isEnabled,
  }) =>
      MultiPoolListState(
        status: status ?? this.status,
        listItem: listItem ?? this.listItem,
        selectedItems: selectedItems ?? this.selectedItems,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  @override
  List<Object?> get props => [
        status,
        listItem,
        selectedItems,
        isEnabled,
      ];
}
