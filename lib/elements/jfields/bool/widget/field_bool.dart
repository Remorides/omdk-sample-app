import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldBool extends StatelessWidget {
  /// Create [FieldBool] instance
  const FieldBool({
    required this.labelText,
    required this.onChanged,
    this.focusNode,
    this.cubit,
    super.key,
    this.fieldValue = true,
    this.isEnabled = true,
    this.isRequired = false,
  });

  final String labelText;
  final FieldBoolCubit? cubit;
  final bool fieldValue;
  final bool isEnabled;
  final bool isRequired;
  final FocusNode? focusNode;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return cubit != null
        ? BlocProvider.value(value: cubit!, child: _child)
        : BlocProvider(
            create: (context) => FieldBoolCubit(
              isEnabled: isEnabled,
              fieldValue: fieldValue,
            ),
            child: _child,
          );
  }

  Widget get _child => _FieldBool(
        labelText: labelText,
        focusNode: focusNode,
        onChanged: onChanged,
        isRequired: isRequired,
        key: key,
      );
}

class _FieldBool extends StatelessWidget {
  const _FieldBool({
    required this.labelText,
    required this.onChanged,
    required this.isRequired,
    super.key,
    this.focusNode,
  });

  final String labelText;
  final bool isRequired;
  final FocusNode? focusNode;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    final state = context.select((FieldBoolCubit cubit) => cubit.state);
    return Column(
      children: [
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Expanded(
                child: Text(
                  labelText.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
        const Space.vertical(3),
        Opacity(
          opacity: (!state.isEnabled) ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: !state.isEnabled,
            child: CheckboxListTile(
              value: state.fieldValue,
              focusNode: focusNode,
              enableFeedback: false,
              onChanged: (bool? b) {
                context.read<FieldBoolCubit>().toggle();
                onChanged(b);
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                labelText,
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              checkboxShape: RoundedRectangleBorder(
                side: Theme.of(context)
                        .inputDecorationTheme
                        .border
                        ?.borderSide
                        .copyWith(
                          color: isRequired
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ) ??
                    BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        Row(
          children: [
            if (isRequired)
              Expanded(
                child: Text(
                  context.l.a_mandatory,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
