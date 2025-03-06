import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class FieldMultiPoolList<T> extends StatelessWidget {
  FieldMultiPoolList({
    required this.listItem,
    required this.labelText,
    required this.onSelected,
    super.key,
    this.focusNode,
    this.cubit,
    this.isEnabled = true,
    this.isRequired = false,
    this.selectedItems,
    this.fieldNote,
    this.hint,
    this.validator,
  });

  final String labelText;
  final List<T> listItem;
  final List<T>? selectedItems;
  final bool isEnabled;
  final bool isRequired;
  final MultiPoolListCubit<T>? cubit;
  final FocusNode? focusNode;
  final void Function(List<T>) onSelected;
  final String? fieldNote;
  final String? hint;
  final String? Function(List<T>?)? validator;

  final _controller = MultiSelectController<T>();

  @override
  Widget build(BuildContext context) {
    return cubit != null
        ? BlocProvider.value(value: cubit!, child: _child)
        : BlocProvider(
            create: (_) => MultiPoolListCubit<T>(
              isEnabled: isEnabled,
              listItem: listItem,
              selectedItems: selectedItems ?? [],
            ),
            child: _child,
          );
  }

  Widget get _child => _FieldMultiPoolList<T>(
        controller: _controller,
        isRequired: isRequired,
        labelText: labelText,
        focusNode: focusNode,
        onSelected: onSelected,
        fieldNote: fieldNote,
        validator: validator,
        hint: hint,
      );
}

class _FieldMultiPoolList<T> extends StatelessWidget {
  const _FieldMultiPoolList({
    required this.controller,
    required this.labelText,
    required this.onSelected,
    required this.isRequired,
    this.focusNode,
    this.fieldNote,
    this.hint,
    this.validator,
  });

  final MultiSelectController<T> controller;
  final String labelText;
  final FocusNode? focusNode;
  final void Function(List<T>) onSelected;
  final String? fieldNote;
  final String? hint;
  final String? Function(List<T>?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiPoolListCubit<T>, MultiPoolListState<T>>(
      listener: (context, state) {
        controller.setItems(
          state.selectedItems
              .map(
                (i) => DropdownItem<T>(
                  value: i!,
                  label: '$i',
                ),
              )
              .toList(),
        );
      },
      buildWhen: (previous, current) => previous.isEnabled != current.isEnabled,
      builder: (context, state) => Container(
        margin: const EdgeInsets.only(top: 20),
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
            Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: !state.isEnabled ? 0.5 : 1,
                    child: AbsorbPointer(
                      absorbing: !state.isEnabled,
                      child: MultiDropdown<Object>(
                        focusNode: focusNode,
                        items: state.listItem
                            .map(
                              (map) => DropdownItem<Object>(
                                value: map!,
                                label: '$map',
                                selected: state.selectedItems.any(
                                  (i) => i==map,
                                ),
                              ),
                            )
                            .toList(),
                        fieldDecoration: FieldDecoration(
                          hintText: '$hint',
                          showClearIcon: false,
                        ),
                        chipDecoration: ChipDecoration(
                          deleteIcon: Icon(
                            Icons.close,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            size: 14,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          labelStyle:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          selectedIcon: Icon(
                            Icons.check_box,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (values) => validator
                            ?.call(values?.map((i) => i.value as T).toList()),
                        onSelectionChange: (list) =>
                            onSelected.call(list.map((i) => i as T).toList()),
                      ),
                    ),
                  ),
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}
