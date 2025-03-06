import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldPoolListWithAction<T> extends StatelessWidget {
  /// Create [FieldPoolListWithAction] instance
  const FieldPoolListWithAction({
    required this.listItem,
    required this.labelText,
    required this.onTapAction,
    super.key,
    this.onChanged,
    this.cubit,
    this.hintText,
    this.selectedItem,
    this.isEnabled = false,
    this.isRequired = false,
    this.focusNode,
    this.fieldNote,
    this.isActionEnabled = false,
    this.dropdownIcon,
    this.actionText,
  });

  final List<T> listItem;
  final T? selectedItem;
  final String labelText;
  final String? hintText;
  final bool isEnabled;
  final bool isRequired;
  final PoolListWithActionCubit<T>? cubit;
  final void Function(T?)? onChanged;
  final FocusNode? focusNode;
  final String? fieldNote;
  final bool isActionEnabled;
  final void Function() onTapAction;
  final Icon? dropdownIcon;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return cubit != null
        ? BlocProvider.value(value: cubit!, child: _child)
        : BlocProvider(
            create: (_) => PoolListWithActionCubit(
              isEnabled: isEnabled,
              listItem: listItem,
              selectedItem: selectedItem,
            ),
            child: _child,
          );
  }

  Widget get _child => _FieldPoolList<T>(
        key: key,
        focusNode: focusNode,
        onChanged: onChanged,
        labelText: labelText,
        isRequired: isRequired,
        fieldNote: fieldNote,
        onTapAction: onTapAction,
        isActionEnabled: isActionEnabled,
        dropdownIcon: dropdownIcon,
        hintText: hintText,
        actionText: actionText,
      );
}

class _FieldPoolList<T> extends StatelessWidget {
  const _FieldPoolList({
    required this.labelText,
    required this.isActionEnabled,
    required this.isRequired,
    required this.onTapAction,
    super.key,
    this.onChanged,
    this.hintText,
    this.focusNode,
    this.fieldNote,
    this.dropdownIcon,
    this.actionText,
  });

  final void Function(T?)? onChanged;
  final FocusNode? focusNode;
  final String labelText;
  final String? hintText;
  final String? fieldNote;
  final bool isActionEnabled;
  final bool isRequired;
  final void Function() onTapAction;
  final Icon? dropdownIcon;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
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
          _poolLoader,
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
          const Space.vertical(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_addAction(context)],
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
        ],
      ),
    );
  }

  Widget get _poolLoader =>
      BlocBuilder<PoolListWithActionCubit<T>, PoolListWithActionState<T>>(
        builder: (context, state) => Opacity(
          opacity: (!state.isEnabled || state.listItem.isEmpty) ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: !state.isEnabled || state.listItem.isEmpty,
            child: DropdownButtonFormField<T>(
              icon: dropdownIcon,
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
                    (map) => DropdownMenuItem(
                      value: map,
                      child: Text('$map'),
                    ),
                  )
                  .toList(),
              value: state.selectedItem,
              isExpanded: true,
              onChanged: (T? t) {
                context.read<PoolListWithActionCubit<T>>().changeSelected(t);
                onChanged?.call(t);
              },
            ),
          ),
        ),
      );

  Widget _addAction(BuildContext context) => OMDKElevatedButton(
        onPressed: onTapAction,
        enabled: isActionEnabled,
        text: actionText ?? context.l.btn_add,
      );
}
