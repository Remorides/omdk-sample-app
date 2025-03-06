import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldDouble extends StatelessWidget {
  /// Create [FieldDouble] instance
  const FieldDouble({
    required this.labelText,
    this.focusNode,
    super.key,
    this.onChanged,
    this.onSubmit,
    this.initialValue,
    this.cubit,
    this.nextFocusNode,
    this.isEnabled = true,
    this.isRequired = false,
    this.withBorder = true,
    this.autofocus = false,
    this.onTap,
    this.onBuildedCubit,
    this.onCursorPosition,
    this.placeholder,
    this.textAlign = TextAlign.start,
    this.fieldNote,
    this.suffixText,
    this.validator,
  });

  final String labelText;
  final SimpleTextCubit? cubit;
  final bool isEnabled;
  final bool isRequired;
  final bool autofocus;
  final bool withBorder;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final void Function(double?)? onChanged;
  final void Function(double?)? onSubmit;
  final void Function()? onTap;
  final void Function(SimpleTextCubit)? onBuildedCubit;
  final void Function(int)? onCursorPosition;
  final double? initialValue;
  final String? placeholder;
  final TextAlign textAlign;
  final String? fieldNote;
  final String? suffixText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final wCubit = cubit ??
        SimpleTextCubit(
          initialText: initialValue?.toString(),
          isInputTextEnabled: isEnabled,
        );
    onBuildedCubit?.call(wCubit);
    return BlocProvider.value(
      value: wCubit,
      child: SimpleTextField(
        key: key,
        autofocus: autofocus,
        isRequired: isRequired,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => onChanged?.call(double.tryParse('$v')),
        onSubmit: (v) => onSubmit?.call(double.tryParse('$v')),
        textAlign: textAlign,
        labelText: labelText,
        placeholder: placeholder,
        textFocusNode: focusNode,
        nextFocusNode: nextFocusNode,
        withBorder: withBorder,
        onTap: onTap,
        fieldNote: fieldNote,
        suffixText: suffixText,
        validator: validator,
      ),
    );
  }
}
