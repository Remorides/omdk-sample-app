import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:omdk_sample_app/common/enums/enums.dart';
part 'multi_pool_list_state.dart';

class MultiPoolListCubit<E> extends Cubit<MultiPoolListState<E>> {
  /// Create [PoolListCubit] instance
  MultiPoolListCubit({
    required List<E> listItem,
    bool isEnabled = true,
    List<E> selectedItems = const [],
  }) : super(
    MultiPoolListState(
      listItem: listItem,
      selectedItems: selectedItems,
      isEnabled: isEnabled,
    ),
  );

  /// Set current tab on home page
  void enable() => emit(state.copyWith(isEnabled: true));

  /// Set current tab on home page
  void disable() => emit(state.copyWith(isEnabled: false));
}
