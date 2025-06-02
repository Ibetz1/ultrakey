import 'dart:async';
import 'package:flutter/material.dart';
import 'package:launcher/models/auth.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/runner.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/minimal_dropdown.dart';
import 'package:launcher/widgets/styled_container.dart';

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
    _configListener = ConfigController.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _configListener.cancel();
    super.dispose();
  }

  Future<void> _startEmu() async {
    // await _saveConfig();

    // await ConfigLoader.runSelected();

    // _forwardEvent("emuState", UltrakeyRunner.running);
  }

  Future<void> _stopEmu() async {
    // UltrakeyRunner.stop();

    // _forwardEvent("emuState", UltrakeyRunner.running);
  }

  Future<void> _createConfig() async {
    final name = await _showNameDialog('Create Config');
    if (name == null || name.isEmpty) return;

    final bool success = await ConfigLoader.create(name);
    if (!success) {
      _showError('Error creating config');
    }

    ConfigController.notify();
  }

  Future<void> _saveConfig() async {
    if (ConfigLoader.selected == null) return;

    final bool success = ConfigLoader.save(ConfigLoader.selected!);
    if (!success) {
      _showError('Error saving config.');
    }

    ConfigController.notify();
  }

  Future<void> _renameConfig() async {
    if (ConfigLoader.selected == null) return;

    final newName = await _showNameDialog('Rename Config');
    if (newName == null || newName.isEmpty || ConfigLoader.selected == null) {
      return;
    }

    final success = await ConfigLoader.rename(ConfigLoader.selected!, newName);
    if (!success) {
      _showError('Error renaming config');
    }

    ConfigController.notify();
  }

  Future<void> _deleteConfig() async {
    if (ConfigLoader.selected == null) return;

    final success = ConfigLoader.delete(ConfigLoader.selected!);
    if (!success) {
      _showError('Cannot delete config.');
    }

    ConfigController.notify();
  }

  void _selectConfig(Config? cfg) async {
    ConfigController.updateStream.push(() {
      ConfigLoader.setSelected(cfg);
    });
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
                      AuthServer.updateStream.push(() {
                        AuthStorage.delToken();
                        AuthServer.state = AuthState.awaitingLogin;
                      });
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
                    child: MinimalDropdown<Config>(
                      expanded: true,
                      items: ConfigLoader.list(),
                      displayText: (v) => v.name,
                      onChanged: _selectConfig,
                      initialValue: ConfigLoader.getSelected(),
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
