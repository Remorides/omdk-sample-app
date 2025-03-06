import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:omdk_sample_app/common/enums/enums.dart';

part 'pool_list_with_action_state.dart';

class PoolListWithActionCubit<E> extends Cubit<PoolListWithActionState<E>> {
  /// Create [PoolListWithActionCubit] instance
  PoolListWithActionCubit({
    required List<E> listItem,
    bool isEnabled = true,
    E? selectedItem,
  }) : super(
          PoolListWithActionState(
            listItem: listItem,
            selectedItem: selectedItem,
            isEnabled: isEnabled,
          ),
        );

  /// Enable widget
  void enable() => emit(state.copyWith(isEnabled: true));

  /// Disable widget
  void disable() => emit(state.copyWith(isEnabled: false));

  /// Change selected item
  void changeSelected(E? e) => emit(state.copyWith(selectedItem: e));
}
