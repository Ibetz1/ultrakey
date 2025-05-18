import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/input_grid.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class ButtonBindings extends StatefulWidget {
  const ButtonBindings({
    super.key,
  });

  @override
  State<ButtonBindings> createState() => _ButtonBindingsState();
}

class _ButtonBindingsState extends State<ButtonBindings> {
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
    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Button Bindings"),
            SingleChildScrollView(
              child: InputCaptureGrid(
                rows: GamepadCode.idTable.length,
                checkEnabled: (id, col) =>
                    Config.countValueInstances(id, col) <= 1,
                columns: 3,
                values: [
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("a", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("b", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("x", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("y", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("dpadUp", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("dpadDown", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("dpadLeft", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("dpadRight", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("start", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("back", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("leftThumb", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("rightThumb", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("leftShoulder", col),
                    ),
                  ),
                  List.generate(
                    numCols,
                    (col) => VirtualKey.displayName(
                      Config.getGrid("rightShoulder", col),
                    ),
                  ),
                ],
                onChanged: _forwardEvent,
                iconData: GamepadCode.icons,
                idTable: GamepadCode.idTable,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
