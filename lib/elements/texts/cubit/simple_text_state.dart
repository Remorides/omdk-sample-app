part of 'simple_text_cubit.dart';

final class SimpleTextState extends Equatable {
  /// Create [SimpleTextState] instance
  const SimpleTextState({
    required this.controller,
    this.isActionEnabled = true,
    this.isInputTextEnabled = true,
    this.obscureText = false,
    this.text,
    this.errorText,
  });

  final TextEditingController controller;
  final String? text;
  final FieldTextError? errorText;
  final bool isInputTextEnabled;
  final bool isActionEnabled;
  final bool obscureText;

  SimpleTextState copyWith({
    TextEditingController? controller,
    String? text,
    FieldTextError? errorText,
    bool? isInputTextEnabled,
    bool? isActionEnabled,
    bool? obscureText,
  }) {
    return SimpleTextState(
      controller: controller ?? this.controller,
      errorText: errorText,
      isInputTextEnabled: isInputTextEnabled ?? this.isInputTextEnabled,
      isActionEnabled: isActionEnabled ?? this.isActionEnabled,
      obscureText: obscureText ?? this.obscureText,
    );
  }

  @override
  List<Object?> get props => [
        controller,
        errorText,
        isInputTextEnabled,
        isActionEnabled,
        obscureText,
      ];
}
