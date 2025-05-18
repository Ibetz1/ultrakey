import 'package:flutter/material.dart';

class ContainedSwitch extends StatelessWidget {
  const ContainedSwitch({
    required this.value,
    this.label,
    this.update,
    super.key,
  });

  final bool value;
  final Widget? label;
  final void Function(bool v)? update;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        label ?? Container(),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            activeColor: Theme.of(context).colorScheme.secondary,
            onChanged: (v) {
              update?.call(v);
            },
          ),
        ),
      ],
    );
  }
}
