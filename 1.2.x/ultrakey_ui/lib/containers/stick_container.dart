import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/containers/advanced_container.dart';
import 'package:launcher/models/assets.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/contained_switch.dart';
import 'package:launcher/widgets/input_box.dart';
import 'package:launcher/widgets/minimal_dropdown.dart';
import 'package:launcher/widgets/slider_container.dart';
import 'package:launcher/widgets/styled_container.dart';

class StickOptions extends StatefulWidget {
  const StickOptions({super.key});

  @override
  State<StickOptions> createState() => _StickOptionsState();
}

class _StickOptionsState extends State<StickOptions> {
  Config cfg = ConfigLoader.getSelected() ?? Config();
  late StreamSubscription _configListener;

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

  Widget generateStickRow(List<Widget> icons, String tag, VK? binding) {
    String getDisplayText(
      int index,
      Map<VK, StickDir> directionMap,
    ) {
      final direction = Config.analogDirections[index];
      return VK.displayName(
        directionMap.entries
            .firstWhere(
              (entry) => entry.value == direction,
              orElse: () => MapEntry(VK.keyNone, direction),
            )
            .key,
      );
    }

    return Row(
      children: [
        for (int i = 0; i < icons.length; ++i) ...[
          Padding(
            padding: EdgeInsets.all(4),
            child: icons[i],
          ),
          Expanded(
            child: InputCaptureBox(
              onChanged: (v) => ConfigController.updateStream.push(() {
                if (tag == "ls") {
                  cfg.leftAnalogBindings.removeWhere(
                    (k, v) => v == Config.analogDirections[i],
                  );
                  cfg.leftAnalogBindings[v] = Config.analogDirections[i];
                }

                if (tag == "rs") {
                  cfg.rightAnalogBindings.removeWhere(
                    (k, v) => v == Config.analogDirections[i],
                  );
                  cfg.rightAnalogBindings[v] = Config.analogDirections[i];
                }
              }),
              displayText: (tag == "ls")
                  ? getDisplayText(i, cfg.leftAnalogBindings)
                  : (tag == "rs")
                      ? getDisplayText(i, cfg.rightAnalogBindings)
                      : null,
              enabled: binding == VK.keyKeyboard,
            ),
          ),
        ],
        SizedBox(width: WidgetRatios.horizontalPadding),
        MinimalDropdown(
          displayText: (v) => v.toString(),
          onChanged: (v) {
            ConfigController.updateStream.push(() {
              if (tag == "ls") {
                cfg.lsBinding =
                    Config.stickBindings[v ?? ""] ?? VK.keyNone;
              }

              if (tag == "rs") {
                cfg.rsBinding =
                    Config.stickBindings[v ?? ""] ?? VK.keyNone;
              }
            });
          },
          items: Config.stickBindings.keys.toList(),
          initialValue: Config.stickBindings.reverse(
            binding ?? VK.keyNone,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        width: double.infinity,
        child: Column(
          children: [
            Text("Stick Controls"),
            Padding(
              padding: WidgetRatios.widgetPadding(scale: 0.5),
              child: generateStickRow([
                leftJoystickUpImage,
                leftJoystickLeftImage,
                leftJoystickDownImage,
                leftJoystickRightImage,
              ], "ls", cfg.lsBinding),
            ),
            Padding(
              padding: WidgetRatios.widgetPadding(scale: 0.5),
              child: generateStickRow([
                rightJoystickUpImage,
                rightJoystickLeftImage,
                rightJoystickDownImage,
                rightJoystickRightImage,
              ], "rs", cfg.rsBinding),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                ContainedSwitch(
                  value: cfg.passthrough,
                  label: Text("Passthrough"),
                  update: (v) => ConfigController.updateStream.push(() {
                    cfg.passthrough = v;
                  }),
                ),
                ContainedSwitch(
                  value: cfg.stabilizer,
                  label: Text("Stabilizer"),
                  update: (v) => ConfigController.updateStream.push(() {
                    cfg.stabilizer = v;
                  }),
                ),
                ContainedSwitch(
                  value: cfg.keepalive,
                  label: Text("Keepalive"),
                  update: (v) => ConfigController.updateStream.push(() {
                    cfg.keepalive = v;
                  }),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: WidgetRatios.widgetPadding(),
                    child: SliderContainer.fromConfigVar(
                      cfg.sensitivity,
                      label: "Sensitivity",
                      update: (v) => ConfigController.updateStream.push(() {
                        cfg.sensitivity.value = v;
                      }),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AdvancedContainer(),
                    );
                  },
                  child: Text("Advanced"),
                ),
              ],
            ),
            Padding(
              padding: WidgetRatios.widgetPadding(),
              child: SliderContainer.fromConfigVar(
                cfg.smoothing,
                label: "Smoothing",
                update: (v) => ConfigController.updateStream.push(() {
                  cfg.smoothing.value = v;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
