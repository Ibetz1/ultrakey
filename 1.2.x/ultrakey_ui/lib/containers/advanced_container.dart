import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/slider_container.dart';

class AdvancedContainer extends StatefulWidget {
  const AdvancedContainer({super.key});

  @override
  State<AdvancedContainer> createState() => _AdvancedContainerState();
}

class _AdvancedContainerState extends State<AdvancedContainer> {
  late StreamSubscription _configListener;
  Config cfg = ConfigLoader.getSelected() ?? Config();

  @override
  void initState() {
    _configListener = ConfigController.listen(
      (_) => setState(() {
        cfg = ConfigLoader.getSelected() ?? Config();
      }),
    );

    super.initState();
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
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
            child: SliderContainer.fromConfigVar(
              cfg.stabilizeStrength,
              label: "Stabilizer Strength",
              update: (v) => ConfigController.updateStream.push(() {
                cfg.stabilizeStrength.value = v;
              }),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer.fromConfigVar(
              cfg.stabilizeSpeed,
              label: "Stabilizer Speed",
              update: (v) => ConfigController.updateStream.push(() {
                cfg.stabilizeSpeed.value = v;
              }),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer.fromConfigVar(
              cfg.keepaliveStrength,
              label: "Keepalive Strength",
              update: (v) => ConfigController.updateStream.push(() {
                cfg.keepaliveStrength.value = v;
              }),
            ),
          ),
          Padding(
            padding: WidgetRatios.widgetPadding(),
            child: SliderContainer.fromConfigVar(
              cfg.keepaliveSpeed,
              label: "Keepalive Speed",
              update: (v) => ConfigController.updateStream.push(() {
                cfg.keepaliveSpeed.value = v;
              }),
            ),
          ),
        ],
      ),
    );
  }
}
