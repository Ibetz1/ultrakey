import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/containers/advanced_container.dart';
import 'package:ultrakey_ui/models/assets.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/contained_switch.dart';
import 'package:ultrakey_ui/widgets/input_box.dart';
import 'package:ultrakey_ui/widgets/minimal_dropdown.dart';
import 'package:ultrakey_ui/widgets/slider_container.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class StickOptions extends StatefulWidget {
  const StickOptions({super.key});

  @override
  State<StickOptions> createState() => _StickOptionsState();
}

class _StickOptionsState extends State<StickOptions> {
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

  Widget generateStickRow(List<Widget> icons, String tag, int? binding) {
    return Row(
      children: [
        for (int i = 0; i < icons.length; ++i) ...[
          Padding(
            padding: EdgeInsets.all(4),
            child: icons[i],
          ),
          Expanded(
            child: InputCaptureBox(
              onChanged: (v) => _forwardEvent("$tag$i", v),
              displayText: VirtualKey.displayName(
                Config.getGrid(tag, i),
              ),
              conflict: !(Config.countValueInstances(tag, i) <= 1),
              enabled: Config.stickEnabled(binding),
            ),
          ),
        ],
        SizedBox(width: WidgetRatios.horizontalPadding),
        MinimalDropdown(
          onChanged: (v) => _forwardEvent("${tag}Type", v),
          items: Config.stickRemapping.keys.toList(),
          initialValue: Config.toStickLabel(binding ?? 0),
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
              ], "ls", Config.lsBinding),
            ),
            Padding(
              padding: WidgetRatios.widgetPadding(scale: 0.5),
              child: generateStickRow([
                rightJoystickUpImage,
                rightJoystickLeftImage,
                rightJoystickDownImage,
                rightJoystickRightImage,
              ], "rs", Config.rsBinding),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                // ContainedSwitch(
                //   value: Config.threshold,
                //   label: Text("Threshold"),
                //   update: (v) => _forwardEvent("threshold", v),
                // ),
                ContainedSwitch(
                  value: Config.passthrough,
                  label: Text("Passthrough"),
                  update: (v) => _forwardEvent("passthrough", v),
                ),
                ContainedSwitch(
                  value: Config.stabilizer,
                  label: Text("Stabilizer"),
                  update: (v) => _forwardEvent("stabilizer", v),
                ),
                ContainedSwitch(
                  value: Config.keepalive,
                  label: Text("Keepalive"),
                  update: (v) => _forwardEvent("keepalive", v),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: WidgetRatios.widgetPadding(),
                    child: SliderContainer(
                      value: Config.sensitivity.clamp(1, 100),
                      label: "Sensitivity",
                      minValue: 1,
                      maxValue: 100,
                      update: (v) => _forwardEvent("sensitivity", v.floor()),
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
              child: SliderContainer(
                value: Config.smoothing.clamp(1, 100),
                label: "Smoothing",
                minValue: 1,
                maxValue: 100,
                update: (v) => _forwardEvent("smoothing", v.floor()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
