import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/assets.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/input_grid.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class TriggerBindings extends StatefulWidget {
  const TriggerBindings({
    super.key,
  });

  @override
  State<TriggerBindings> createState() => _TriggerBindingsState();
}

class _TriggerBindingsState extends State<TriggerBindings> {
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
    List<String> idTable = [
      "leftTrigger",
      "rightTrigger",
    ];

    Map<String, Widget> iconData = {
      "leftTrigger": leftTriggerImage,
      "rightTrigger": rightTriggerImage,
    };

    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Trigger Bindings"),
            InputCaptureGrid(
              rows: idTable.length,
              columns: 1,
              checkEnabled: (id, col) =>
                  Config.countValueInstances(id, col) <= 1,
              values: [
                List.generate(
                  1,
                  (col) => VirtualKey.displayName(
                    Config.getGrid("leftTrigger", col),
                  ),
                ),
                List.generate(
                  1,
                  (col) => VirtualKey.displayName(
                    Config.getGrid("rightTrigger", col),
                  ),
                ),
              ],
              iconData: iconData,
              idTable: idTable,
              onChanged: _forwardEvent,
            ),
          ],
        ),
      ),
    );
  }
}