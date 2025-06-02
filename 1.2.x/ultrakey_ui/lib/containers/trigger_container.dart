import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/input_grid.dart';
import 'package:launcher/widgets/styled_container.dart';

class TriggerBindings extends StatefulWidget {
  const TriggerBindings({
    super.key,
  });

  @override
  State<TriggerBindings> createState() => _TriggerBindingsState();
}

class _TriggerBindingsState extends State<TriggerBindings> {
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
    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Trigger Bindings"),
            InputCaptureGrid(
              columns: cfg.triggerBindings.columns,
              values: generateKeyGrid(
                cfg.triggerBindings,
                GamepadTrigger.icons.keys,
              ),
              iconData: GamepadTrigger.icons,
              onChanged: (row, binding, col) {
                ConfigController.updateStream.push(() {
                  cfg.triggerBindings.emplace(row, binding, col);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
