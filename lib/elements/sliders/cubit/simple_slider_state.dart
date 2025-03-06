part of 'simple_slider_cubit.dart';

@immutable
final class SimpleSliderState {
  const SimpleSliderState({
    required this.value,
    required this.isEnabled,
  });

  final double value;
  final bool isEnabled;

  SimpleSliderState copyWith({
    double? value,
    bool? isEnabled,
  }) {
    return SimpleSliderState(
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
