import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldDateRange extends StatelessWidget {
  /// Create [FieldDateRange] instance
  const FieldDateRange({
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
  final DateTimeRange? initialDate;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? fieldNote;
  final String? suffixText;
  final SimpleTextCubit? cubit;
  final bool isInputTextEnabled;
  final bool isActionEnabled;
  final void Function()? onTap;
  final void Function(SimpleTextCubit)? onBuildedCubit;
  final void Function(DateTimeRange)? onChanged;
  final void Function(DateTimeRange?)? onSubmit;
  final bool isRequired;

  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final wCubit = cubit ??
        SimpleTextCubit(
          initialText: formatDataRange(initialDate),
          isActionEnabled: isActionEnabled,
          isInputTextEnabled: isInputTextEnabled,
        );
    return FieldStringWithAction(
      key: key,
      labelText: labelText,
      focusNode: focusNode,
      isInputTextEnabled: isInputTextEnabled,
      isRequired: isRequired,
      isActionEnabled: isActionEnabled,
      actionIcon: const Icon(CupertinoIcons.calendar),
      fieldNote: fieldNote,
      suffixText: suffixText,
      cubit: wCubit,
      onBuildedCubit: onBuildedCubit,
      onTapAction: () async => showDateRangePicker(
        context: context,
        firstDate: firstDate ?? DateTime(1970),
        lastDate: lastDate ?? DateTime(2100),
      ).then((dates) {
        if (dates != null) {
          wCubit.setText(formatDataRange(dates));
          onChanged?.call(dates);
        }
      }),
    );
  }

  String? formatDataRange(DateTimeRange? dataRange) {
    final dataStart = dataRange?.start;
    final dataEnd = dataRange?.end;
    return '${dataStart?.day}/${dataStart?.month}/${dataStart?.year} - ${dataEnd?.day}/${dataEnd?.month}/${dataEnd?.year}';
  }
}
