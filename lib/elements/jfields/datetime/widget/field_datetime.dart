import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldDateTime extends StatelessWidget {
  /// Create [FieldDateTime] instance
  const FieldDateTime({
    required this.labelText,
    this.focusNode,
    super.key,
    this.initialDate,
    this.nextFocusNode,
    this.fieldNote,
    this.isInputTextEnabled = false,
    this.isRequired = false,
    this.isActionEnabled = true,
    this.cubit,
    this.onChanged,
    this.onSubmit,
    this.onTap,
    this.onBuildedCubit,
    this.suffixText,
    this.firstDate,
    this.lastDate,
  });

  final String labelText;
  final DateTime? initialDate;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? fieldNote;
  final String? suffixText;
  final SimpleTextCubit? cubit;
  final bool isInputTextEnabled;
  final bool isActionEnabled;
  final bool isRequired;
  final void Function()? onTap;
  final void Function(SimpleTextCubit)? onBuildedCubit;
  final void Function(DateTime?)? onChanged;
  final void Function(String?)? onSubmit;

  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final wCubit = cubit ??
        SimpleTextCubit(
          initialText: initialDate?.toUtc().toString(),
          isActionEnabled: isActionEnabled,
          isInputTextEnabled: isInputTextEnabled,
        );
    return FieldStringWithAction(
      key: key,
      labelText: labelText,
      focusNode: focusNode,
      isRequired: isRequired,
      isInputTextEnabled: isInputTextEnabled,
      isActionEnabled: isActionEnabled,
      actionIcon: const Icon(CupertinoIcons.calendar),
      fieldNote: fieldNote,
      onSubmit: onSubmit,
      suffixText: suffixText,
      cubit: wCubit,
      onBuildedCubit: onBuildedCubit,
      onTapAction: () async => showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
      ).then((date) {
        if (date != null) {
          wCubit.setText(date.toString());
          onChanged?.call(date);
        }
      }),
    );
  }
}
