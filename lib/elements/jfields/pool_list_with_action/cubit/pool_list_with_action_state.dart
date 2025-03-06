part of 'pool_list_with_action_cubit.dart';

@immutable
final class PoolListWithActionState<E> extends Equatable {
  const PoolListWithActionState({
    required this.listItem,
    required this.isEnabled,
    this.selectedItem,
    this.status = LoadingStatus.initial,
  });

  final LoadingStatus status;
  final List<E> listItem;
  final E? selectedItem;
  final bool isEnabled;

  PoolListWithActionState<E> copyWith({
    LoadingStatus? status,
    List<E>? listItem,
    E? selectedItem,
    String? errorText,
    bool? isEnabled,
  }) =>
      PoolListWithActionState(
        status: status ?? this.status,
        listItem: listItem ?? this.listItem,
        selectedItem: selectedItem ?? this.selectedItem,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  @override
  List<Object?> get props => [
        status,
        listItem,
        selectedItem,
        isEnabled,
      ];
}
