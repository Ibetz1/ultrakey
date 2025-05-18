import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/input_grid.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class ToggleBindings extends StatefulWidget {
  const ToggleBindings({
    super.key,
  });

  @override
  State<ToggleBindings> createState() => _ToggleBindingsState();
}

class _ToggleBindingsState extends State<ToggleBindings> {
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
      "toggleTap",
      "toggleHold",
      "untoggleHold",
    ];

    Map<String, Widget> iconData = {
      "toggleTap": SizedBox(
        width: 60,
        child: Center(child: Text("Tap")),
      ),
      "toggleHold": SizedBox(
        width: 60,
        child: Center(child: Text("Hold")),
      ),
      "untoggleHold": SizedBox(
        width: 60,
        child: Center(child: Text("Untoggle")),
      ),
    };

    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Toggle Bindings"),
            InputCaptureGrid(
              rows: idTable.length,
              onChanged: _forwardEvent,
              checkEnabled: (id, col) =>
                  Config.countValueInstances(id, col) <= 1,
              columns: 3,
              values: [
                List.generate(
                  numCols,
                  (col) => VirtualKey.displayName(
                    Config.getGrid("toggleTap", col),
                  ),
                ),
                List.generate(
                  numCols,
                  (col) => VirtualKey.displayName(
                    Config.getGrid("toggleHold", col),
                  ),
                ),
                List.generate(
                  numCols,
                  (col) => VirtualKey.displayName(
                    Config.getGrid("untoggleHold", col),
                  ),
                )
              ],
              iconData: iconData,
              idTable: idTable,
            ),
          ],
        ),
      ),
    );
  }
}
