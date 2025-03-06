import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldInt extends StatelessWidget {
  /// Create [FieldInt] instance
  const FieldInt({
    required this.labelText,
    this.focusNode,
    super.key,
    this.onSubmit,
    this.onChanged,
    this.initialValue,
    this.cubit,
    this.nextFocusNode,
    this.isEnabled = true,
    this.isRequired = false,
    this.withBorder = true,
    this.autofocus = false,
    this.onTap,
    this.onCursorPosition,
    this.placeholder,
    this.textAlign = TextAlign.start,
    this.fieldNote,
    this.suffixText,
  });

  final String labelText;
  final SimpleTextCubit? cubit;
  final bool isEnabled;
  final bool isRequired;
  final bool autofocus;
  final bool withBorder;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final void Function(int?)? onChanged;
  final void Function(int?)? onSubmit;
  final void Function()? onTap;
  final void Function(int)? onCursorPosition;
  final int? initialValue;
  final String? placeholder;
  final TextAlign textAlign;
  final String? fieldNote;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final wCubit = cubit ??
        SimpleTextCubit(
          initialText: initialValue?.toString(),
          isInputTextEnabled: isEnabled,
        );
    return BlocProvider.value(
      value: wCubit,
      child: SimpleTextField(
        key: key,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        isRequired: isRequired,
        onChanged: (newValue) {
          if (newValue == null) {
            onChanged?.call(null);
            return;
          }
          final parsedValue = int.tryParse(newValue);
          if (parsedValue != null) onChanged?.call(parsedValue);
        },
        onSubmit: (newValue) {
          if (newValue == null){
            onSubmit?.call(null);
            return;
          }
          final parsedValue = int.tryParse(newValue);
          if (parsedValue != null) onSubmit?.call(parsedValue);
        },
        textAlign: textAlign,
        labelText: labelText,
        placeholder: placeholder,
        textFocusNode: focusNode,
        nextFocusNode: nextFocusNode,
        withBorder: withBorder,
        onTap: onTap,
        fieldNote: fieldNote,
        suffixText: suffixText,
      ),
    );
  }
}
