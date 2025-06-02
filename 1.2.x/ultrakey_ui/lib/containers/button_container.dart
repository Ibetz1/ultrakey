import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/input_grid.dart';
import 'package:launcher/widgets/styled_container.dart';

class ButtonBindings extends StatefulWidget {
  const ButtonBindings({
    super.key,
  });

  @override
  State<ButtonBindings> createState() => _ButtonBindingsState();
}

class _ButtonBindingsState extends State<ButtonBindings> {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Button Bindings"),
            SingleChildScrollView(
              child: InputCaptureGrid(
                columns: cfg.buttonBindings.columns,
                values: generateKeyGrid(
                  cfg.buttonBindings,
                  GamepadCode.icons.keys,
                ),
                onChanged: (row, binding, col) {
                  ConfigController.updateStream.push(() {
                    cfg.buttonBindings.emplace(row, binding, col);
                  });
                },
                iconData: GamepadCode.icons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
