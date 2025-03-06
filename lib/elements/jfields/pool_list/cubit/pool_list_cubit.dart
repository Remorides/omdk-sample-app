import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:omdk_sample_app/common/enums/enums.dart';

part 'pool_list_state.dart';

class PoolListCubit<T> extends Cubit<PoolListState<T>> {
  /// Create [PoolListCubit] instance
  PoolListCubit({
    required List<T?> listItem,
    bool isEnabled = true,
    T? selectedItem,
  }) : super(
          PoolListState(
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
  void changeSelected(T? s) => emit(state.copyWith(selectedItem: s));
}
