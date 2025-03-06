import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_sample_app/elements/radio_buttons/multi_radio_buttons/multi_radio_button.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';

class PriorityButtons extends FormField<int> {
  PriorityButtons({
    required this.labelText,
    required this.focusNode,
    required this.priorities,
    required super.validator,
    super.key,
    this.cubit,
    this.nextFocusNode,
    this.isEnabled = true,
    this.onSelectedPriority,
    this.indexSelectedRadio,
  }) : super(
          autovalidateMode: AutovalidateMode.disabled,
          enabled: isEnabled,
          initialValue: indexSelectedRadio,
          builder: (field) {
            return cubit != null
                ? BlocProvider.value(
                    value: cubit,
                    child: _PriorityButtons(
                      labelText: labelText,
                      onSelectedPriority: onSelectedPriority,
                      focusNode: focusNode,
                      nextFocusNode: nextFocusNode,
                      errorText: field.errorText,
                      priorities: priorities ?? [],
                    ),
                  )
                : BlocProvider(
                    create: (_) => MrbCubit(
                      isEnabled: isEnabled,
                      selected: indexSelectedRadio,
                    ),
                    child: _PriorityButtons(
                      labelText: labelText,
                      onSelectedPriority: onSelectedPriority,
                      focusNode: focusNode,
                      nextFocusNode: nextFocusNode,
                      errorText: field.errorText,
                      priorities: priorities ?? [],
                    ),
                  );
          },
        );

  final String labelText;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool isEnabled;
  final MrbCubit? cubit;
  final int? indexSelectedRadio;
  final void Function(int?)? onSelectedPriority;
  final List<SimpleEntity>? priorities;
}

class _PriorityButtons extends StatelessWidget {
  const _PriorityButtons({
    required this.labelText,
    required this.focusNode,
    required this.priorities,
    this.onSelectedPriority,
    this.nextFocusNode,
    this.errorText,
  });

  final String labelText;
  final void Function(int?)? onSelectedPriority;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String? errorText;
  final List<SimpleEntity> priorities;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                labelText.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            for (final p in priorities)
              Expanded(
                child: priorityButton(context, p),
              ),
          ],
        ),
        if (errorText != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  errorText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget priorityButton(BuildContext context, SimpleEntity entity) =>
      RadioListTile<int>(
        title: Text(
          entity.name.toUpperCase(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: entity.color != null ? HexColor(entity.color!) : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
        value: entity.id,
        shape: const RoundedRectangleBorder(),
        controlAffinity: ListTileControlAffinity.trailing,
        groupValue: context.read<MrbCubit>().state.selectedRadio,
        onChanged: (value) {
          if (value != null) {
            context.read<MrbCubit>().switchRadio(value);
            onSelectedPriority?.call(value);
          }
        },
      );
}
