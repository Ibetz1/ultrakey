import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/input_grid.dart';
import 'package:launcher/widgets/styled_container.dart';

class ToggleBindings extends StatefulWidget {
  const ToggleBindings({
    super.key,
  });

  @override
  State<ToggleBindings> createState() => _ToggleBindingsState();
}

class _ToggleBindingsState extends State<ToggleBindings> {
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
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Toggle Bindings"),
            InputCaptureGrid(
              onChanged: (row, binding, col) {
                ConfigController.updateStream.push(() {
                  cfg.toggleBindings.emplace(row, binding, col);
                });
              },
              columns: cfg.toggleBindings.columns,
              values: generateKeyGrid(
                cfg.toggleBindings,
                ToggleMode.icons.keys,
              ),
              iconData: ToggleMode.icons,
            ),
          ],
        ),
      ),
    );
  }
}
