import 'dart:async';

import 'package:flutter/material.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/script.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/input_box.dart';
import 'package:launcher/widgets/slider_container.dart';
import 'package:launcher/widgets/styled_container.dart';

class ScriptRow extends StatelessWidget {
  const ScriptRow({
    required this.script,
    required this.cfg,
    this.showSelectionOptions = false,
    this.showPreviewOptions = false,
    super.key,
  });

  final Script script;
  final Config cfg;
  final bool showSelectionOptions;
  final bool showPreviewOptions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetRatios.widgetPadding(scale: 0.25),
      child: Row(
        children: [
          if (showSelectionOptions)
            Checkbox(
              value: cfg.containsScript(script),
              onChanged: (v) {
                if (script.type == SecurityType.public &&
                    cfg.type == SecurityType.public) {
                  ConfigController.updateStream.push(() {
                    if (v ?? false) {
                      cfg.addScript(script);
                    } else {
                      cfg.removeScript(script);
                    }
                  });
                }
              },
              fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return (script.type == SecurityType.public &&
                            cfg.type == SecurityType.public)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onTertiary;
                  }
                  return Colors.transparent;
                },
              ),
              side:
                  WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return BorderSide(
                    color: (script.type == SecurityType.public &&
                            cfg.type == SecurityType.public)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onTertiary,
                    width: 2,
                  );
                }
                return BorderSide(
                  color: (script.type == SecurityType.public &&
                          cfg.type == SecurityType.public)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onTertiary,
                  width: 2,
                ); // Border when unchecked
              }),
              hoverColor: Colors.transparent,
            ),
          Padding(
            padding: WidgetRatios.widgetPadding(scale: 0.5),
            child: Text(script.name.replaceAll(".lua", "")),
          ),
          Spacer(),
          if (showPreviewOptions &&
              script.type != SecurityType.secure &&
              cfg.type != SecurityType.secure) ...[
            SizedBox(
              width: WidgetRatios.defaultIconSize / 4,
            ),
            IconButton(
              onPressed: () {
                // TODO open editor
              },
              iconSize: WidgetRatios.defaultIconSize * 0.7,
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: WidgetRatios.defaultIconSize / 4,
            ),
          ],
          Icon(
            (script.type == SecurityType.secure) ? Icons.lock : Icons.public,
            color: ((script.type == SecurityType.secure ||
                        cfg.type == SecurityType.secure) &&
                    !cfg.containsScript(script))
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class ScriptSelectList extends StatefulWidget {
  const ScriptSelectList({super.key});

  @override
  State<ScriptSelectList> createState() => _ScriptSelectListState();
}

class _ScriptSelectListState extends State<ScriptSelectList> {
  late final StreamSubscription _configListener;
  Config cfg = ConfigLoader.getSelected() ?? Config();

  @override
  void initState() {
    super.initState();
    _configListener = ConfigController.listen((_) {
      setState(() {
        cfg = ConfigLoader.getSelected() ?? Config();
      });
    });
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Script> scripts = ScriptLoader.list()
      ..removeWhere(
        (scr) => (!cfg.containsScript(scr) && scr.type == SecurityType.secure),
      );

    return ListView.builder(
      itemCount: scripts.length,
      itemBuilder: (context, index) {
        Script scr = scripts[index];

        return ScriptRow(
          script: scr,
          cfg: cfg,
          showSelectionOptions: true,
        );
      },
    );
  }
}

class UiScriptControls extends StatefulWidget {
  const UiScriptControls({super.key});

  @override
  State<UiScriptControls> createState() => _UiScriptControlsState();
}

class _UiScriptControlsState extends State<UiScriptControls> {
  late final StreamSubscription _configListener;
  Config cfg = ConfigLoader.getSelected() ?? Config();

  @override
  void initState() {
    super.initState();
    _configListener = ConfigController.listen((_) {
      setState(() {
        cfg = ConfigLoader.getSelected() ?? Config();
      });
    });
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  Widget _scriptList(List<Script> scripts) => Padding(
        padding: WidgetRatios.widgetPadding(),
        child: StyledContainer(
          height: 600,
          child: Column(
            children: [
              Center(child: Text("Scripts")),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: scripts.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ScriptRow(
                        script: scripts[index],
                        cfg: cfg,
                        showPreviewOptions: true,
                        showSelectionOptions: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _bindingList() {
    Map<dynamic, dynamic> configBindings = {};

    configBindings.addAll(cfg.taggedBindings);
    configBindings.addAll(cfg.booleanBindings);
    configBindings.addAll(cfg.sliderBindings);

    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        height: 600,
        child: Column(
          children: [
            Text("Bindings"),
            Expanded(
              child: ListView.builder(
                  itemCount: configBindings.entries.length,
                  itemBuilder: (context, index) {
                    MapEntry<dynamic, dynamic> entry =
                        configBindings.entries.elementAt(
                      index,
                    );

                    // slider
                    return Padding(
                      padding: WidgetRatios.widgetPadding(),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(entry.key)),
                          if (entry.value is ConfigVar)
                            Expanded(
                              flex: 4,
                              child: SliderContainer.fromConfigVar(
                                entry.value,
                                update: (v) {
                                  ConfigController.updateStream.push(() {
                                    cfg.sliderBindings[entry.key]?.value = v;
                                  });
                                },
                              ),
                            ),
                          if (entry.value is VK)
                            Expanded(
                              flex: 4,
                              child: InputCaptureBox(
                                displayText: VK.displayName(
                                  cfg.taggedBindings[entry.key],
                                ),
                                onChanged: (v) {
                                  ConfigController.updateStream.push(() {
                                    cfg.taggedBindings[entry.key] = v;
                                  });
                                },
                              ),
                            )
                          // TODO boolean
                          // if (entru.value is bool)
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: _scriptList(ScriptLoader.scripts.values.toList()),
        ),
        Expanded(
          flex: 4,
          child: _bindingList(),
        ),
      ],
    );
  }
}
