import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class OMDKSimpleSlider extends StatelessWidget {
  const OMDKSimpleSlider({
    this.labelText,
    this.isEnabled = true,
    this.initialValue,
    this.divisions = 5,
    this.max = 100,
    this.onChanged,
  });

  final String? labelText;
  final double? initialValue;
  final bool isEnabled;
  final int divisions;
  final double max;
  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SimpleSliderCubit(initValue: initialValue),
      child: BlocBuilder<SimpleSliderCubit, SimpleSliderState>(
        builder: (context, state) => Opacity(
          opacity: state.isEnabled ? 1 : 0.5,
          child: AbsorbPointer(
            absorbing: !state.isEnabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (labelText != null) const Space.vertical(8),
                if (labelText != null)
                  Row(
                    children: [
                      const Space.horizontal(10),
                      Expanded(
                        child: Text(
                          labelText!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: state.value,
                        max: max,
                        divisions: divisions,
                        label: state.value.round().toString(),
                        onChanged: (double value) {
                          context.read<SimpleSliderCubit>().updateSlider(value);
                          onChanged?.call(value);
                        },
                      ),
                    ),
                    const Space.horizontal(10),
                    Text(
                      state.value.round().toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Space.horizontal(20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
