import 'package:flutter/material.dart';
import 'package:ultrakey_ui/containers/button_container.dart';
import 'package:ultrakey_ui/containers/stick_container.dart';
import 'package:ultrakey_ui/containers/toggle_container.dart';
import 'package:ultrakey_ui/containers/trigger_container.dart';

class UiConfigControls extends StatelessWidget {
  const UiConfigControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StickOptions(),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ToggleBindings(),
                    ),
                    Expanded(
                      flex: 2,
                      child: TriggerBindings(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ButtonBindings(),
        ),
      ],
    );
  }
}