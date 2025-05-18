import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/input_box.dart';
import 'package:ultrakey_ui/widgets/slider_container.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class UiScriptControls extends StatefulWidget {
  const UiScriptControls({super.key});

  @override
  State<UiScriptControls> createState() => _UiScriptControlsState();
}

class _UiScriptControlsState extends State<UiScriptControls> {
  late final StreamSubscription _configListener;

  @override
  void initState() {
    super.initState();
    _configListener = Config.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  void _forwardEvent(String id, dynamic v) {
    Config.updateStream.push(id: id, value: v);
  }

  void _selectScript(String name, bool state) async {
    ScriptLoader.selectScript(name, state: state);
    await ScriptLoader.syncScriptVars();
    _forwardEvent("selectScript", name);
  }

  Widget _itemContainer({
    required Widget child,
    required String label,
  }) =>
      Padding(
        padding: WidgetRatios.widgetPadding(),
        child: StyledContainer(
          height: 400,
          child: Column(
            children: [
              Text(label),
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      );

  Widget _scriptList(List<String> scripts) => _itemContainer(
        label: "Available Scripts",
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: WidgetRatios.widgetPadding(scale: 0.5),
                    child: Checkbox(
                      value: ScriptLoader.scriptSelected(scripts[index]),
                      onChanged: (bool? value) =>
                          _selectScript(scripts[index], value ?? false),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: WidgetRatios.widgetPadding(scale: 0.5),
                      child: Text(scripts[index]),
                    ),
                  ),
                  Padding(
                    padding: WidgetRatios.widgetPadding(scale: 0.5),
                    child: SizedBox(
                      width: 80,
                      child: FilledButton(
                        onPressed: () {
                          openFileSmart(
                            ScriptLoader.scriptAbsPath(scripts[index]),
                          );
                        },
                        child: const Text("Open"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: scripts.length,
        ),
      );

  Widget _bindingList() => _itemContainer(
        label: "Script Bindings",
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            String key = ScriptLoader.scriptVariables.keys.toList()[index];
            ScriptVariable? variable = ScriptLoader.scriptVariables[key];

            if (variable == null) {
              return Container();
            }

            Widget displayVar = (variable.type == 0)
                ? InputCaptureBox(
                    displayText: VirtualKey.displayName(
                      int.parse(
                        getKeyByValue(
                              Config.taggedBindings,
                              key,
                            ) ??
                            VirtualKey.keyNone.value.toString(),
                      ),
                    ),
                    onChanged: (v) => _forwardEvent(
                      "changeTaggedBinding",
                      [v.toString(), key],
                    ),
                  )
                : SliderContainer(
                    value: Config.valueBindings[key]?.toDouble() ?? 0,
                    minValue: variable.valueMin,
                    maxValue: variable.valueMax,
                    update: (v) => _forwardEvent(
                      "changeValueBinding",
                      [key, v.toInt()],
                    ),
                  );

            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: WidgetRatios.widgetPadding(scale: 0.5),
                    child: SizedBox(
                      width: 150,
                      child: Text(key),
                    ),
                  ),
                  Padding(
                    padding: WidgetRatios.widgetPadding(scale: 0.5),
                    child: Icon(Icons.commit),
                  ),
                  Expanded(
                    child: Padding(
                      padding: WidgetRatios.widgetPadding(scale: 0.5),
                      child: displayVar,
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: ScriptLoader.scriptVariables.keys.length,
        ),
      );

  @override
  Widget build(BuildContext context) {
    List<String> scripts = ScriptLoader.listScripts();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _scriptList(scripts)),
        Expanded(child: _bindingList()),
      ],
    );
  }
}