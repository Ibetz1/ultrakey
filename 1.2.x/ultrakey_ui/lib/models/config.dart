import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:path/path.dart' as p;
import 'package:ultrakey_ui/models/value_update_event.dart';

class Config {
  static int? ltBinding,
      rtBinding,
      lsBinding = VirtualKey.keyNone.value,
      rsBinding = VirtualKey.keyNone.value;

  static double _sensitivity = 0.01;
  static double _smoothing = 0.95;
  static double _keepaliveStrength = 0.3;
  static double _stabilizerStrength = 0.032;
  static int _keepaliveSpeed = 50;
  static int _stabilizerSpeed = 120;
  static Map<String, List<int>> leftAnalogBindings = {};
  static Map<String, List<int>> rightAnalogBindings = {};
  static Map<String, String> taggedBindings = {};
  static Map<String, int> valueBindings = {};
  static Map<String, int> buttonBindings = {};
  static Map<String, int> toggleBindings = {};
  static List<String> scripts = [];
  static bool keepalive = false;
  static bool stabilizer = false;
  static bool passthrough = false;
  static bool threshold = false;

  static double get sensitivity => unmapSlider(_sensitivity, 0.001, 0.1, range: 100);
  static set sensitivity(double v) => _sensitivity = mapSlider(v, 0.001, 0.1, range: 100);

  static double get smoothing => unmapSlider(_smoothing, 0.1, 1, range: 100);
  static set smoothing(double v) => _smoothing = mapSlider(v, 0.1, 1, range: 100);

  static double get stabilizerStrength =>
      unmapSlider(_stabilizerStrength, 0.01, 0.15);
  static set stabilizerStrength(double v) =>
      _stabilizerStrength = mapSlider(v, 0.01, 0.15);

  static double get keepaliveStrength =>
      unmapSlider(_keepaliveStrength, 0.01, 0.5);
  static set keepaliveStrength(double v) =>
      _keepaliveStrength = mapSlider(v, 0.01, 0.5);

  static int get stabilizerSpeed =>
      unmapSlider(_stabilizerSpeed.toDouble(), 0, 360).toInt();
  static set stabilizerSpeed(int v) =>
      _stabilizerSpeed = mapSlider(v.toDouble(), 0, 360).toInt();

  static int get keepaliveSpeed =>
      unmapSlider(_keepaliveSpeed.toDouble(), 0, 360).toInt();
  static set keepaliveSpeed(int v) =>
      _keepaliveSpeed = mapSlider(v.toDouble(), 0, 360).toInt();

  static StreamController updateNotifier = StreamController.broadcast();
  static ValueUpdateStream updateStream = ValueUpdateStream();

  static StreamSubscription listen(void Function(dynamic) callback) {
    return updateNotifier.stream.listen(callback);
  }

  static void notify() {
    updateNotifier.add(null);
  }

  static Map<String, int> stickRemapping = {
    "Keyboard": VirtualKey.keyKeyboard.value,
    "Mouse": VirtualKey.keyMouse.value,
    "Unbind": VirtualKey.keyNone.value,
  };

  static Map<String, int> toggleRemapping = {
    "toggleTap": 0,
    "toggleHold": 1,
    "untoggleHold": 2,
  };

  static List<List<int>> analogDirections = [
    [0, 1],
    [-1, 0],
    [0, -1],
    [1, 0],
  ];

  static const Map<String, int> gridLengths = {
    "toggleTap": numCols,
    "toggleHold": numCols,
    "untoggleHold": numCols,
    "ls": numSticks,
    "rs": numSticks,
    "dpadUp": numCols,
    "dpadDown": numCols,
    "dpadLeft": numCols,
    "dpadRight": numCols,
    "start": numCols,
    "back": numCols,
    "leftThumb": numCols,
    "rightThumb": numCols,
    "leftShoulder": numCols,
    "rightShoulder": numCols,
    "a": numCols,
    "b": numCols,
    "x": numCols,
    "y": numCols,
    "leftTrigger": 1,
    "rightTrigger": 1,
  };

  static Map<String, List<int>> makeGrid() {
    return {
      for (final entry in gridLengths.entries)
        entry.key: List.filled(entry.value, VirtualKey.keyNone.value),
    };
  }

  static Map<String, List<int>> makeCounts() {
    return {
      for (final entry in gridLengths.entries)
        entry.key: List.filled(entry.value, 0),
    };
  }

  static void popluateGrid() {
    for (String keyCode in buttonBindings.keys) {
      int? buttonCode = buttonBindings[keyCode];
      if (buttonCode == null) {
        continue;
      }
      String? buttonName = GamepadCode.fromValue(buttonCode)?.name;
      if (buttonName == null) {
        continue;
      }
      if (grid.containsKey(buttonName)) {
        for (int i = 0; i < grid[buttonName]!.length; ++i) {
          if (grid[buttonName]![i] == VirtualKey.keyNone.value) {
            grid[buttonName]![i] = int.parse(keyCode);
            break;
          }
        }
      }
    }

    for (String keyCode in toggleBindings.keys) {
      int? mode = toggleBindings[keyCode];
      if (mode == null) {
        continue;
      }
      String? name = getKeyByValue(toggleRemapping, mode);
      if (name == null) {
        continue;
      }
      if (grid.containsKey(name)) {
        for (int i = 0; i < grid[name]!.length; ++i) {
          if (grid[name]![i] == VirtualKey.keyNone.value) {
            grid[name]![i] = int.parse(keyCode);
            break;
          }
        }
      }
    }

    for (String keyCode in leftAnalogBindings.keys) {
      List<int>? dir = leftAnalogBindings[keyCode];
      if (dir == null) {
        continue;
      }
      int index = analogDirections.indexWhere(
        (element) =>
            element.length == 2 && element[0] == dir[0] && element[1] == dir[1],
      );
      grid["ls"]![index] = int.parse(keyCode);
    }

    for (String keyCode in rightAnalogBindings.keys) {
      List<int>? dir = rightAnalogBindings[keyCode];
      if (dir == null) {
        continue;
      }
      int index = analogDirections.indexWhere(
        (element) =>
            element.length == 2 && element[0] == dir[0] && element[1] == dir[1],
      );
      grid["rs"]![index] = int.parse(keyCode);
    }

    grid["leftTrigger"] = [ltBinding ?? VirtualKey.keyNone.value];
    grid["rightTrigger"] = [rtBinding ?? VirtualKey.keyNone.value];
  }

  static Map<String, List<int>> grid = makeGrid();
  static Map<String, List<int>> gridCount = makeCounts();

  static void reset() {
    ltBinding = null;
    rtBinding = null;
    lsBinding = VirtualKey.keyKeyboard.value;
    rsBinding = VirtualKey.keyMouse.value;

    _sensitivity = 0.24;
    _smoothing = 0.95;
    _keepaliveStrength = 0.3;
    _stabilizerStrength = 0.032;
    _keepaliveSpeed = 50;
    _stabilizerSpeed = 120;
    leftAnalogBindings = {};
    rightAnalogBindings = {};
    taggedBindings = {};
    valueBindings = {};
    buttonBindings = {};
    toggleBindings = {};
    scripts = [];
    keepalive = false;
    stabilizer = false;
    passthrough = false;
    threshold = false;

    grid = makeGrid();
    gridCount = makeCounts();
  }

  static bool stickEnabled(int? stick) {
    if (stick != null) {
      return toStickLabel(stick) == stickRemapping.keys.first;
    }

    return false;
  }

  static String toStickLabel(int? keyCode) {
    return stickRemapping.map((a, b) => MapEntry(b, a))[keyCode] ??
        stickRemapping.keys.first;
  }

  static void setGrid(String id, int col, int val) {
    if (grid.containsKey(id) && col < (grid[id]?.length ?? 0)) {
      grid[id]?[col] = val;
    }
  }

  static int getGrid(String id, int col) {
    if (grid.containsKey(id) && col < (grid[id]?.length ?? 0)) {
      return grid[id]?[col] ?? VirtualKey.keyNone.value;
    }

    return VirtualKey.keyNone.value;
  }

  static int scanGridRepeats() {
    int count = 0;

    final allValues = grid.values
        .expand((list) => list)
        .where((v) => v != VirtualKey.keyNone.value)
        .toList();

    final Map<int, int> frequency = {};
    for (var value in allValues) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }

    grid.forEach((key, valueList) {
      gridCount[key] = valueList.map((v) {
        return v == VirtualKey.keyNone.value ? 0 : (frequency[v] ?? 0);
      }).toList();
    });

    return count;
  }

  static int countValueInstances(String id, int col) {
    return gridCount[id]?[col] ?? 0;
  }

  static Map<String, int> formatGridBindings(Map<String, int> mapping) {
    Map<String, int> formatted = {};

    mapping.forEach((id, value) {
      for (final binding in grid[id] ?? []) {
        if (binding != VirtualKey.keyNone.value) {
          formatted[binding.toString()] = value;
        }
      }
    });

    return formatted;
  }

  static Map<String, List<int>> generateAnalogBindings(String id) {
    final bindings = <String, List<int>>{};
    final directionList = grid[id];
    if (directionList == null) return bindings;

    for (int i = 0; i < directionList.length; ++i) {
      final key = directionList[i];
      if (key != VirtualKey.keyNone.value) {
        bindings[key.toString()] = analogDirections[i];
      }
    }

    return bindings;
  }

  static String serialize() {
    Config.toggleBindings = Config.formatGridBindings(Config.toggleRemapping);
    Config.buttonBindings = Config.formatGridBindings(GamepadCode.idMapping);

    Config.leftAnalogBindings = Config.generateAnalogBindings("ls");
    Config.rightAnalogBindings = Config.generateAnalogBindings("rs");

    Config.ltBinding = Config.grid["leftTrigger"]?[0];
    Config.rtBinding = Config.grid["rightTrigger"]?[0];

    String encoding = JsonEncoder.withIndent('   ').convert({
      "keepalive": Config.keepalive,
      "passthrough": Config.passthrough,
      "keepalive_speed": Config._keepaliveSpeed,
      "stabilizer": Config.stabilizer,
      "threshold": Config.threshold,
      "keepalive_strength": Config._keepaliveStrength,
      "left_analog_bindings": Config.leftAnalogBindings,
      "right_analog_bindings": Config.rightAnalogBindings,
      "ls_binding": Config.lsBinding ?? VirtualKey.keyNone.value,
      "lt_binding": Config.ltBinding ?? VirtualKey.keyNone.value,
      "rs_binding": Config.rsBinding ?? VirtualKey.keyNone.value,
      "rt_binding": Config.rtBinding ?? VirtualKey.keyNone.value,
      "stabilizer_speed": Config._stabilizerSpeed,
      "stabilizer_strength": Config._stabilizerStrength,
      "stick_sensitivity": Config._sensitivity,
      "stick_smoothing": Config._smoothing,
      "scripts": Config.scripts,
      "button_bindings": Config.buttonBindings,
      "toggle_bindings": Config.toggleBindings,
      "tagged_bindings": Config.taggedBindings,
      "value_bindings": Config.valueBindings
    });

    printStatus();
    return encoding;
  }

  static void deserialize(String val) {
    reset();
    Map<String, dynamic> jsonData = jsonDecode(val);

    keepalive = jsonData["keepalive"] ?? keepalive;
    stabilizer = jsonData["stabilizer"] ?? stabilizer;
    threshold = jsonData["threshold"] ?? threshold;
    passthrough = jsonData["passthrough"] ?? passthrough;
    _sensitivity = jsonData["stick_sensitivity"] ?? sensitivity;
    _smoothing = jsonData["stick_smoothing"] ?? smoothing;
    _stabilizerSpeed = jsonData["stabilizer_speed"] ?? _stabilizerSpeed;
    _stabilizerStrength =
        jsonData["stabilizer_strength"] ?? _stabilizerStrength;
    _keepaliveSpeed = jsonData["keepalive_speed"] ?? _keepaliveSpeed;
    _keepaliveStrength = jsonData["keepalive_strength"] ?? _keepaliveStrength;
    List<String> scriptPaths = List<String>.from(jsonData['scripts']);
    scripts = ScriptLoader.validateScripts(scriptPaths);

    buttonBindings = Map<String, int>.from(jsonData["button_bindings"]);
    toggleBindings = Map<String, int>.from(jsonData["toggle_bindings"]);
    ltBinding = jsonData["lt_binding"] ?? ltBinding;
    rtBinding = jsonData["rt_binding"] ?? rtBinding;
    lsBinding = jsonData["ls_binding"] ?? lsBinding;
    rsBinding = jsonData["rs_binding"] ?? rsBinding;

    leftAnalogBindings =
        Map<String, dynamic>.from(jsonData["left_analog_bindings"]).map(
      (key, value) => MapEntry(key, List<int>.from(value)),
    );

    rightAnalogBindings =
        Map<String, dynamic>.from(jsonData["right_analog_bindings"]).map(
      (key, value) => MapEntry(key, List<int>.from(value)),
    );

    taggedBindings = Map<String, String>.from(jsonData["tagged_bindings"]);
    valueBindings = Map<String, int>.from(jsonData["value_bindings"]);

    popluateGrid();
    printStatus();
    ConfigLoader.saveConfig();
  }

  static void printStatus() {
    printf("---------------------");
    printf("ltBinding: ${Config.ltBinding}");
    printf("rtBinding: ${Config.rtBinding}");
    printf("lsBinding: ${Config.lsBinding}");
    printf("rsBinding: ${Config.rsBinding}");
    printf("sensitivity: ${Config._sensitivity}");
    printf("smoothing: ${Config._smoothing}");
    printf("keepaliveStrength: ${Config._keepaliveStrength}");
    printf("stabilizerStrength: ${Config._stabilizerStrength}");
    printf("keepaliveSpeed: ${Config._keepaliveSpeed}");
    printf("stabilizerSpeed: ${Config._stabilizerSpeed}");
    printf("leftAnalogBindings: ${Config.leftAnalogBindings}");
    printf("rightAnalogBindings: ${Config.rightAnalogBindings}");
    printf("taggedBindings: ${Config.taggedBindings}");
    printf("valueBindings: ${Config.valueBindings}");
    printf("buttonBindings: ${Config.buttonBindings}");
    printf("toggleBindings: ${Config.toggleBindings}");
    printf("scripts: ${Config.scripts}");
    printf("keepalive: ${Config.keepalive}");
    printf("stabilizer: ${Config.stabilizer}");
    printf("passthrough: ${Config.passthrough}");
    printf("threshold: ${Config.threshold}");
  }
}

class ConfigLoader {
  static final String configDir =
      p.join(Directory.current.path, configFolderName);
  static List<String> _configs = [];
  static String? _selectedConfig;

  static Future<void> initConfigFolder() async {
    final dir = Directory(configDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await refreshConfigList();
  }

  static Future<void> refreshConfigList() async {
    final dir = Directory(configDir);
    if (!await dir.exists()) {
      _configs = [];
      return;
    }

    _configs = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => p.basename(f.path))
        .toList();

    if (_selectedConfig == null && _configs.isNotEmpty) {
      _selectedConfig = _configs.first;
    }
  }

  static List<String> getConfigs() => _configs;

  static String? getSelectedConfig() => _selectedConfig;

  static void setSelectedConfig(String? name) {
    _selectedConfig = name;
  }

  static Future<bool> createConfig(String name) async {
    if (name.isEmpty) return false;
    final file = File(p.join(configDir, '$name.json'));
    if (await file.exists()) return false;

    Config.reset();
    String data = Config.serialize();

    await file.writeAsString(data);
    await refreshConfigList();
    _selectedConfig = '$name.json';
    await refreshConfigList();
    return true;
  }

  static Future<bool> saveConfig() async {
    if (_selectedConfig == null) return false;
    File file = File(p.join(configDir, _selectedConfig));
    if (!await file.exists()) return false;
    if (_selectedConfig?.isEmpty ?? true) return false;

    String data = Config.serialize();

    await file.writeAsString(data);
    await refreshConfigList();
    return true;
  }

  static Future<bool> renameConfig(String oldName, String newName) async {
    final oldFile = File(p.join(configDir, oldName));
    final newFile = File(p.join(configDir, '$newName.json'));

    if (!await oldFile.exists() || await newFile.exists()) return false;

    await oldFile.rename(newFile.path);
    _selectedConfig = '$newName.json';
    await refreshConfigList();
    return true;
  }

  static Future<bool> deleteConfig(String name) async {
    refreshConfigList();

    if (_configs.length <= 1) {
      return false;
    }

    final file = File(p.join(configDir, name));
    if (await file.exists()) {
      await file.delete();
      if (_selectedConfig == name) _selectedConfig = null;
      await refreshConfigList();
      return true;
    }
    return false;
  }

  static String getSelectedConfigName() {
    if (_selectedConfig == null) return '';
    return p.basenameWithoutExtension(_selectedConfig!);
  }

  static String getSelectedConfigPath() {
    return p.join(configDir, _selectedConfig);
  }

  static Future<void> load() async {
    File file = File(p.join(configDir, _selectedConfig));
    if (await file.exists()) {
      final contents = await file.readAsString();
      Config.deserialize(contents);
    }
  }
}

class ScriptVariable {
  ScriptVariable(
    this.type,
    this.value, {
    this.valueMin = 0,
    this.valueMax = sliderRange,
  });

  final int type;
  final int value;
  double valueMin;
  double valueMax;
}

class ScriptLoader {
  static final String scriptDir = p.join(
    Directory.current.path,
    scriptsFolderName,
  );

  static Map<String, ScriptVariable> scriptVariables = {};

  static void watchScriptFolder(void Function(String, int) onChanged) {
    monitorFolder(scriptDir, onUpdate: onChanged);
  }

  static List<String> listScripts() {
    final dir = Directory(scriptDir);

    if (!dir.existsSync()) return [];

    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.lua'))
        .map((file) => file.path.split(Platform.pathSeparator).last)
        .toList();
  }

  static void selectScript(String name, {bool state = true}) {
    final file = File(p.join(scriptDir, name));
    if (file.existsSync()) {
      printf('Script found: ${file.absolute.path}');
      bool selected = Config.scripts.contains(file.path);
      if (selected && state == false) {
        Config.scripts.remove(file.path);
      }

      if (!selected && state == true) {
        Config.scripts.add(file.path);
      }
    } else {
      printf('Script not found: ${file.path}');
    }
  }

  static String scriptAbsPath(String name) {
    return p.join(scriptDir, name);
  }

  static bool scriptSelected(String scriptName) {
    List<String> selectedPaths = Config.scripts;

    List<String> selectedNames = selectedPaths
        .map((path) => path.split(Platform.pathSeparator).last)
        .toList();

    return selectedNames.contains(scriptName);
  }

  static Future<Map<String, ScriptVariable>> parseScript(
    String scriptPath,
  ) async {
    try {
      String fileData = await readTextFromFile(scriptPath);
      List<String> lines = fileData.split("\n");
      Map<String, ScriptVariable> vars = {};

      for (String line in lines) {
        String? bindingName = getBindName(line);
        if (bindingName != null) {
          vars[bindingName] = ScriptVariable(
            0,
            int.parse(
              Config.taggedBindings[bindingName] ??
                  "${VirtualKey.keyNone.value}",
            ),
          );
          continue;
        }

        Map<String, dynamic>? parsedValue = parseMinMaxBinding(line);
        if (parsedValue != null) {
          vars[parsedValue["name"]] = ScriptVariable(
            1,
            Config.valueBindings[parsedValue["name"]] ?? parsedValue["value"],
            valueMin: (parsedValue["min"] as int).toDouble(),
            valueMax: (parsedValue["max"] as int).toDouble(),
          );
          if (!Config.valueBindings.containsKey(parsedValue["name"])) {
            Config.valueBindings[parsedValue["name"]] = parsedValue["value"];
          }
          continue;
        }
      }
      return vars;
    } catch (e) {
      return {};
    }
  }

  static Future<void> syncScriptVars() async {
    scriptVariables.clear();
    for (String script in Config.scripts) {
      scriptVariables.addAll(
        await ScriptLoader.parseScript(script),
      );
    }
  }

  static Map<String, ScriptVariable> get scriptVars {
    return {};
  }

  static List<String> validateScripts(List<String> scripts) {
    List<String> fileNames = scripts
        .map(
          (path) => p.basename(path),
        )
        .toList();

    List<String> availableFiles = listFilenames(scriptDir);

    List<String> routedFiles = [];
    for (String fileName in fileNames) {
      if (availableFiles.contains(fileName)) {
        routedFiles.add(p.join(scriptDir, fileName));
      }
    }
    return routedFiles;
  }
}
