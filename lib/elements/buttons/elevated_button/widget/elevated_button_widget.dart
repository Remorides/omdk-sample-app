import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/buttons/elevated_button/elevated_button.dart';

class OMDKElevatedButton extends StatelessWidget {
  /// Create [OMDKElevatedButton] instance
  const OMDKElevatedButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.cubit,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  final ElevatedButtonCubit? cubit;
  final void Function() onPressed;
  final void Function()? onLongPress;
  final void Function(bool)? onHover;
  final void Function(bool)? onFocusChange;
  final ButtonStyle? style;
  final bool autofocus;
  final bool enabled;
  final String text;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return cubit != null
        ? BlocProvider.value(
            value: cubit!,
            child: _child,
          )
        : BlocProvider(
            create: (_) => ElevatedButtonCubit(enabled: enabled),
            child: _child,
          );
  }

  Widget get _child => _OMDKElevatedButton(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        style: style,
        autofocus: autofocus,
        focusNode: focusNode,
        text: text,
      );
}

class _OMDKElevatedButton extends StatelessWidget {
  const _OMDKElevatedButton({
    required this.onPressed,
    required this.text,
    super.key,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.autofocus = false,
    this.focusNode,
  });

  final void Function() onPressed;
  final void Function()? onLongPress;
  final void Function(bool)? onHover;
  final void Function(bool)? onFocusChange;
  final ButtonStyle? style;
  final bool autofocus;
  final String text;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ElevatedButtonCubit cubit) => cubit.state);
    return ElevatedButton(
      key: key,
      onPressed: state.enabled ? onPressed : null,
      onLongPress: state.enabled ? onLongPress : null,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      autofocus: autofocus,
      focusNode: focusNode,
      child: Text(text),
    );
  }
}
