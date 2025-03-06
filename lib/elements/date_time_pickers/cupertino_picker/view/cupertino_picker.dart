import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class OMDKCupertinoPicker extends StatelessWidget {
  /// Create [OMDKCupertinoPicker] instance
  const OMDKCupertinoPicker({
    super.key,
    this.isEnabled = true,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.bloc,
    this.labelText,
    this.focusNode,
    this.onChanged,
    this.initialValue,
  });

  final bool isEnabled;
  final String? labelText;
  final CupertinoDatePickerMode mode;
  final DateTimeCupertinoBloc? bloc;
  final FocusNode? focusNode;
  final void Function(DateTime?)? onChanged;
  final DateTime? initialValue;

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider.value(value: bloc!, child: _child)
        : BlocProvider(
            create: (context) => DateTimeCupertinoBloc()
              ..add(SetDate(initialValue))
              ..add(isEnabled ? EnableField() : DisableField()),
            child: _child,
          );
  }

  Widget get _child => _CupertinoPicker(
        mode: mode,
        labelText: labelText,
        key: key,
        focusNode: focusNode,
        onChanged: onChanged,
      );
}

class _CupertinoPicker extends StatefulWidget {
  const _CupertinoPicker({
    required this.mode,
    super.key,
    this.labelText,
    this.focusNode,
    this.onChanged,
  });

  final String? labelText;
  final CupertinoDatePickerMode mode;
  final FocusNode? focusNode;
  final void Function(DateTime?)? onChanged;

  @override
  State<_CupertinoPicker> createState() => _CupertinoPickerState();
}

class _CupertinoPickerState extends State<_CupertinoPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DateTimeCupertinoBloc, DateTimeCupertinoState>(
      listener: (context, state) {
        _controller.value = TextEditingValue(
          text: switch (widget.mode) {
            CupertinoDatePickerMode.time =>
              state.currentDate?.toString() ?? '',
            CupertinoDatePickerMode.date =>
              state.currentDate?.toString() ?? '',
            CupertinoDatePickerMode.dateAndTime =>
              state.currentDate?.toString() ?? '',
            CupertinoDatePickerMode.monthYear => throw UnimplementedError(),
          },
        );
      },
      builder: (context, state) => Column(
        children: [
          if (widget.labelText != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.labelText!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          if (widget.labelText != null) const Space.vertical(5),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDialog(context, widget.mode),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _controller,
                      canRequestFocus: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIconColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (state.loadingStatus == LoadingStatus.failure)
            Positioned(
              bottom: 5,
              child: Text(
                state.errorText ?? '!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).inputDecorationTheme.errorStyle,
              ),
            ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, CupertinoDatePickerMode mode) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          height: size.height * 0.27,
          child: CupertinoDatePicker(
            use24hFormat: true,
            mode: mode,
            onDateTimeChanged: (date) {
              context.read<DateTimeCupertinoBloc>().add(SetDate(date));
              widget.onChanged?.call(date);
            },
          ),
        );
      },
    );
  }
}
