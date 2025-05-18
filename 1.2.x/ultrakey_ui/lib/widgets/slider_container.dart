import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/utils.dart';

class SliderContainer extends StatefulWidget {
  const SliderContainer({
    required this.value,
    this.label,
    this.update,
    this.minValue = 0,
    this.maxValue = sliderRange,
    super.key,
  });

  final double value;
  final String? label;
  final int minValue;
  final int maxValue;
  final void Function(double)? update;

  @override
  State<SliderContainer> createState() => _SliderContainerState();
}

class _SliderContainerState extends State<SliderContainer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.label != null) Text(widget.label!),
        Expanded(
          child: Transform.scale(
            scale: 1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: Theme.of(context).colorScheme.secondary,
                thumbColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Slider(
                value: widget.value,
                min: widget.minValue.toDouble(),
                max: widget.maxValue.toDouble(),
                onChanged: (newValue) {
                  widget.update?.call(newValue);
                },
              ),
            ),
          ),
        ),
        Text("${widget.value.floor()}")
      ],
    );
  }
}
