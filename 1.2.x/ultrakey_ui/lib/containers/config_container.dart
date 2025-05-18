import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/auth.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/runner.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/minimal_dropdown.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class StateControls extends StatefulWidget {
  const StateControls({super.key});

  @override
  State<StateControls> createState() => _StateControlsState();
}

class _StateControlsState extends State<StateControls> {
  late final StreamSubscription _configListener;

  @override
  void initState() {
    super.initState();
    _configListener = Config.listen((_) {
      setState(() {});
    });
    ConfigLoader.refreshConfigList().then(
      (v) => _selectConfig(
        ConfigLoader.getSelectedConfig(),
      ),
    );
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  void _forwardEvent(String id, dynamic v) {
    Config.updateStream.push(id: id, value: v);
  }

  Future<void> _startEmu() async {
    await _saveConfig();

    UltrakeyRunner.start(
      ConfigLoader.getSelectedConfigPath(),
    );

    _forwardEvent("emuState", UltrakeyRunner.running);
  }

  Future<void> _stopEmu() async {
    UltrakeyRunner.stop();

    _forwardEvent("emuState", UltrakeyRunner.running);
  }

  Future<void> _createConfig() async {
    final name = await _showNameDialog('Create Config');
    if (name == null || name.isEmpty) return;

    final success = await ConfigLoader.createConfig(name);
    if (!success) {
      _showError('A config with that name already exists.');
    }
    _forwardEvent("createConfig", name);
  }

  Future<void> _saveConfig() async {
    final success = await ConfigLoader.saveConfig();
    if (!success) {
      _showError('A config with that name already exists.');
    }
    _forwardEvent("_saveConfig", null);
  }

  Future<void> _renameConfig() async {
    final current = ConfigLoader.getSelectedConfig();
    if (current == null) return;

    final newName = await _showNameDialog('Rename Config');
    if (newName == null || newName.isEmpty) return;

    final success = await ConfigLoader.renameConfig(current, newName);
    if (!success) {
      _showError('Rename failed. A config with that name may already exist.');
    }

    _forwardEvent("renameConfig", [current, newName]);
  }

  Future<void> _deleteConfig() async {
    final current = ConfigLoader.getSelectedConfig();
    if (current == null) return;

    final success = await ConfigLoader.deleteConfig(current);
    if (!success) {
      _showError('Cannot delete config.');
    }

    _forwardEvent("deleteConfig", current);
  }

  void _selectConfig(String? name) async {
    ConfigLoader.setSelectedConfig(name);
    await ConfigLoader.load();
    await ScriptLoader.syncScriptVars();
    _forwardEvent("selectConfig", name);
  }

  Future<String?> _showNameDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Config Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetRatios.widgetPadding(),
      child: StyledContainer(
        width: double.infinity,
        child: Column(
          children: [
            const Text("Config Controls"),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () {
                      AuthServer.updateStream.push(id: "logout", value: null);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: SizedBox(
                    width: 400,
                    child: MinimalDropdown(
                      expanded: true,
                      items: ConfigLoader.getConfigs(),
                      onChanged: _selectConfig,
                      initialValue: ConfigLoader.getSelectedConfig(),
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () => _saveConfig(),
                    iconSize: WidgetRatios.defaultIconSize,
                    icon: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () => _createConfig(),
                    iconSize: WidgetRatios.defaultIconSize,
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () => _renameConfig(),
                    iconSize: WidgetRatios.defaultIconSize,
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () => _deleteConfig(),
                    iconSize: WidgetRatios.defaultIconSize,
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () {
                      if (!UltrakeyRunner.running) {
                        _startEmu();
                      }
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: (UltrakeyRunner.running)
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () {
                      if (UltrakeyRunner.running) {
                        _stopEmu();
                      }
                    },
                    icon: Icon(
                      Icons.stop,
                      color: (UltrakeyRunner.running)
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                Padding(
                  padding: WidgetRatios.widgetPadding(scale: 0.5),
                  child: IconButton(
                    onPressed: () {
                      if (UltrakeyRunner.running) {
                        _startEmu();
                      }
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: (UltrakeyRunner.running)
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
