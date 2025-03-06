import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldString extends StatelessWidget {
  /// Create [FieldString] instance
  const FieldString({
    required this.labelText,
    super.key,
    this.focusNode,
    this.onSubmit,
    this.onChanged,
    this.initialText,
    this.cubit,
    this.nextFocusNode,
    this.isEnabled = true,
    this.isRequired = false,
    this.withBorder = true,
    this.autofocus = false,
    this.isObscurable = false,
    this.onTap,
    this.onBuildedCubit,
    this.placeholder,
    this.maxLines = 1,
    this.fieldNote,
    this.suffixText,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.padding = EdgeInsets.zero,
    this.autovalidateMode,
  });

  final String labelText;
  final SimpleTextCubit? cubit;
  final bool isEnabled;
  final bool isRequired;
  final bool autofocus;
  final bool isObscurable;
  final bool withBorder;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmit;
  final void Function()? onTap;
  final void Function(SimpleTextCubit)? onBuildedCubit;
  final String? initialText;
  final String? placeholder;
  final int maxLines;
  final String? fieldNote;
  final String? suffixText;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry padding;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final wCubit = cubit ??
        SimpleTextCubit(
          initialText: initialText,
          isInputTextEnabled: isEnabled,
        );
    onBuildedCubit?.call(wCubit);
    return BlocProvider.value(
      value: wCubit,
      child: Padding(
        padding: padding,
        child: SimpleTextField(
          key: key,
          autofocus: autofocus,
          isObscurable: isObscurable,
          isRequired: isRequired,
          labelText: labelText,
          placeholder: placeholder,
          textFocusNode: focusNode,
          nextFocusNode: nextFocusNode,
          withBorder: withBorder,
          onTap: onTap,
          onSubmit: onSubmit,
          onChanged: onChanged,
          maxLines: maxLines,
          fieldNote: fieldNote,
          suffixText: suffixText,
          validator: validator,
          autovalidateMode: autovalidateMode,
        ),
      ),
    );
  }
}
