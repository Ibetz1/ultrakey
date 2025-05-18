import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/slider_container.dart';

class AdvancedContainer extends StatefulWidget {
  const AdvancedContainer({super.key});

  @override
  State<AdvancedContainer> createState() => _AdvancedContainerState();
}

class _AdvancedContainerState extends State<AdvancedContainer> {
  late StreamSubscription _configListener;

  @override
  void initState() {
    _configListener = Config.listen(
      (_) => setState(() {}),
    );

    super.initState();
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  void _forwardEvent(String id, dynamic v) {
    Config.updateStream.push(id: id, value: v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Advanced Settings"),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer(
              value: Config.stabilizerStrength,
              label: "Stabilizer Strength",
              update: (v) => _forwardEvent("stabilizerStrength", v.floor()),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer(
              value: Config.stabilizerSpeed.toDouble(),
              label: "Stabilizer Speed",
              update: (v) => _forwardEvent("stabilizerSpeed", v.floor()),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer(
              value: Config.keepaliveStrength,
              label: "Keepalive Strength",
              update: (v) => _forwardEvent("keepaliveStrength", v.floor()),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer(
              value: Config.keepaliveSpeed.toDouble(),
              label: "Keepalive Speed",
              update: (v) => _forwardEvent("keepaliveSpeed", v.floor()),
            ),
          ),
        ],
      ),
    );
  }
}
