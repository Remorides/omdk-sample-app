import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'simple_slider_state.dart';

class SimpleSliderCubit extends Cubit<SimpleSliderState> {
  SimpleSliderCubit({double? initValue, bool isEnabled = true})
      : super(
          SimpleSliderState(value: initValue ?? 0, isEnabled: isEnabled),
        );

  void updateSlider(double value) => emit(state.copyWith(value: value));

  void enableSlider() => emit(state.copyWith(isEnabled: true));

  void disabledSlider() => emit(state.copyWith(isEnabled: false));
}
