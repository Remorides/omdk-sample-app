import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldPoolList<T> extends StatelessWidget {
  /// Create [FieldPoolList] instance
  const FieldPoolList({
    required this.listItem,
    required this.labelText,
    this.onChanged,
    super.key,
    this.cubit,
    this.hintText,
    this.selectedItem,
    this.isEnabled = true,
    this.isRequired = false,
    this.focusNode,
    this.fieldNote,
    this.backgroundColor,
  });

  final List<T?> listItem;
  final T? selectedItem;
  final String? hintText;
  final String labelText;
  final bool isEnabled;
  final bool isRequired;
  final PoolListCubit<T>? cubit;
  final void Function(T?)? onChanged;
  final FocusNode? focusNode;
  final String? fieldNote;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return cubit != null
        ? BlocProvider.value(value: cubit!, child: _child)
        : BlocProvider(
            create: (_) => PoolListCubit(
              isEnabled: isEnabled,
              listItem: listItem,
              selectedItem: selectedItem,
            ),
            child: _child,
          );
  }

  Widget get _child => _FieldPoolList<T>(
        key: key,
        isRequired: isRequired,
        focusNode: focusNode,
        onChanged: onChanged,
        labelText: labelText,
        hintText: hintText,
        fieldNote: fieldNote,
        backgroundColor: backgroundColor,
      );
}

class _FieldPoolList<T> extends StatelessWidget {
  const _FieldPoolList({
    required this.labelText,
    required this.isRequired,
    this.onChanged,
    super.key,
    this.focusNode,
    this.hintText,
    this.fieldNote,
    this.backgroundColor,
  });

  final void Function(T?)? onChanged;
  final FocusNode? focusNode;
  final String labelText;
  final String? hintText;
  final String? fieldNote;
  final bool isRequired;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final state = context.select((PoolListCubit<T> cubit) => cubit.state);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                labelText.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const Space.vertical(5),
        Opacity(
          opacity: !state.isEnabled ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: !state.isEnabled,
            child: DropdownButtonFormField<T>(
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                enabled: state.isEnabled,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: Theme.of(context).inputDecorationTheme.border?.copyWith(
                      borderSide: Theme.of(context)
                          .inputDecorationTheme
                          .border
                          ?.borderSide
                          .copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
              ),
              items: state.listItem
                  .map(
                    (map) => DropdownMenuItem<T>(
                      value: map,
                      child: Text('$map'),
                    ),
                  )
                  .toList(),
              value: state.selectedItem,
              isExpanded: true,
              onChanged: (t) {
                context.read<PoolListCubit<T>>().changeSelected(t);
                onChanged?.call(t);
              },
            ),
          ),
        ),
        if (isRequired)
          Row(
            children: [
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
        if (fieldNote != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  '$fieldNote',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        if (state.status == LoadingStatus.failure)
          Positioned(
            bottom: 5,
            child: Text(
              state.errorText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).inputDecorationTheme.errorStyle,
            ),
          ),
      ],
    );
  }
}
