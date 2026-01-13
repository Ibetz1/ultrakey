import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:launcher/models/bimap.dart';
import 'package:launcher/models/binding_grid.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/conf_version.dart';
import 'package:launcher/models/script.dart';
import 'package:launcher/models/utils.dart';
import 'package:path/path.dart' as p;
import 'package:launcher/models/value_update_event.dart';
import 'package:uuid/uuid.dart';

Map<VK, StickDir> mapSticks(String key, Map<String, dynamic> data) =>
    Map<String, dynamic>.from(data[key] ?? {}).map((k, v) => MapEntry(
        VK.from(int.parse(k)), StickDir.fromList(data: List<int>.from(v))));

final uuid = Uuid();

class ConfigVar {
  ConfigVar(
    this.minTarget,
    this.maxTarget, {
    required double ival,
    this.range = sliderRange,
  }) : _value = ival;

  final double minTarget;
  final double maxTarget;
  final double range;
  double _value;

  double get value => unmapSlider(_value, minTarget, maxTarget);
  set value(double v) => _value = mapSlider(v, minTarget, maxTarget);

  double get displayValue => mapSlider(_value, minTarget, maxTarget);
  set directValue(double? v) => _value = v ?? _value;
  double get directValue => _value;
}

class StickDir {
  const StickDir(
    this.dx,
    this.dy,
  );

  static StickDir fromList({
    required List<int> data,
  }) {
    assert(data.length > 1);
    return StickDir(data[0], data[1]);
  }

  final int dx;
  final int dy;

  List<int> toList() => [dx, dy];

  @override
  bool operator ==(Object other) =>
      other is StickDir && dx == other.dx && dy == other.dy;

  @override
  int get hashCode => Object.hash(dx, dy);
}

class Config {
  String name;
  String id;
  SecurityType type = SecurityType.public;
  ConfigVersion version = ConfigVersion.kbmLatest;

  Config({this.name = "UNKNOWN"}) : id = uuid.v4();
  static Config fromJson(String json) => Config()..deserialize(json);

  static BiMap<String, VK> stickBindings = BiMap.from({
    "Keyboard": VK.keyKeyboard,
    "Mouse": VK.keyMouse,
    "Unbind": VK.keyNone,
  });

  static List<StickDir> analogDirections = [
    StickDir(0, 1),
    StickDir(-1, 0),
    StickDir(0, -1),
    StickDir(1, 0),
  ];

  VK lsBinding = VK.keyNone;
  VK rsBinding = VK.keyNone;

  Map<VK, StickDir> leftAnalogBindings = {};
  Map<VK, StickDir> rightAnalogBindings = {};

  BindingGrid<VK, GamepadCode> buttonBindings = BindingGrid.populated(
    columns: 3,
    nil: VK.keyNone,
    keys: GamepadCode.values,
  );

  BindingGrid<VK, ToggleMode> toggleBindings = BindingGrid.populated(
    columns: 3,
    nil: VK.keyNone,
    keys: ToggleMode.values,
  );

  BindingGrid<VK, GamepadTrigger> triggerBindings = BindingGrid.populated(
    columns: 1,
    nil: VK.keyNone,
    keys: GamepadTrigger.values,
  );

  List<Script> scripts = [];
  final Map<String, VK> taggedBindings = {};
  final Map<String, ConfigVar> sliderBindings = {};
  final Map<String, bool> booleanBindings = {};

  bool keepalive = false;
  bool stabilizer = false;
  bool passthrough = false;

  final ConfigVar sensitivity = ConfigVar(0.001, 0.1, range: 100.0, ival: 0.01);
  final ConfigVar smoothing = ConfigVar(0.1, 1.0, range: 100.0, ival: 0.95);
  final ConfigVar stabilizeStrength = ConfigVar(0.01, 0.15, ival: 0.3);
  final ConfigVar keepaliveStrength = ConfigVar(0.01, 0.5, ival: 0.032);
  final ConfigVar stabilizeSpeed = ConfigVar(0.0, 360.0, ival: 50);
  final ConfigVar keepaliveSpeed = ConfigVar(0.0, 360.0, ival: 120);

  bool containsScript(Script other) {
    for (Script scr in scripts) {
      if (scr.name == other.name) {
        return true;
      }
    }

    return false;
  }

  void addScript(Script scr) {
    if (!containsScript(scr)) {
      scripts.add(scr);
      scr.insertBindingInstances(this);
    }
  }

  void removeScript(Script scr) {
    if (containsScript(scr)) {
      scripts.remove(scr);
      scr.removeBindingInstances(this);
    }
  }

  String serialize() {
    String encoding = JsonEncoder.withIndent('   ').convert({
      "name": name,
      "id": id,
      "version": ConfigVersion.toLabel(version),
      "ls_binding": lsBinding.value,
      "rs_binding": rsBinding.value,
      "lt_binding": triggerBindings.row(GamepadTrigger.lt).first.value,
      "rt_binding": triggerBindings.row(GamepadTrigger.rt).first.value,
      "keepalive": keepalive,
      "passthrough": passthrough,
      "stabilizer": stabilizer,
      "keepalive_speed": keepaliveSpeed.directValue,
      "keepalive_strength": keepaliveStrength.directValue,
      "stabilizer_speed": stabilizeSpeed.directValue,
      "stabilizer_strength": stabilizeStrength.directValue,
      "stick_sensitivity": sensitivity.directValue,
      "stick_smoothing": smoothing.directValue,
      "scripts": scripts.map((item) => item.name).toList(),
      "left_analog_bindings": leftAnalogBindings.map(
        (k, v) => MapEntry(k.value.toString(), v.toList()),
      ),
      "right_analog_bindings": rightAnalogBindings.map(
        (k, v) => MapEntry(k.value.toString(), v.toList()),
      ),
      "button_bindings": Map.fromEntries(
        toggleBindings.flatten().entries.where((e) => e.key != VK.keyNone).map(
              (e) => MapEntry(e.key.value.toString(), e.value.value),
            ),
      ),
      "tagged_bindings": Map.fromEntries(
        taggedBindings.entries.where((e) => e.value != VK.keyNone).map(
              (e) => MapEntry(e.value.value.toString(), e.key),
            ),
      ),
      "value_bindings": sliderBindings.map(
        (k, v) => MapEntry(k, v.value.floor()),
      ),
      "toggle_bindings": Map.fromEntries(
        toggleBindings.flatten().entries.where((e) => e.key != VK.keyNone).map(
              (e) => MapEntry(e.key.value.toString(), e.value.value),
            ),
      ),
    });

    return encoding;
  }

  // json to config type
  void deserialize(String json) {
    Map<String, dynamic> data = jsonDecode(json);

    // config settings
    id = data["id"] ?? id;
    name = data["name"] ?? name;
    version = data["version"] ?? version;

    // sticks
    lsBinding = VK.from(data["ls_binding"] ?? lsBinding ?? VK.keyNone);
    rsBinding = VK.from(data["rs_binding"] ?? rsBinding ?? VK.keyNone);

    // values
    sensitivity.directValue = data["stick_sensitivity"]?.toDouble();
    smoothing.directValue = data["stick_smoothing"]?.toDouble();
    stabilizeSpeed.directValue = data["stabilizer_speed"]?.toDouble();
    stabilizeStrength.directValue = data["stabilizer_strength"]?.toDouble();
    keepaliveSpeed.directValue = data["keepalive_speed"]?.toDouble();
    keepaliveStrength.directValue = data["keepalive_strength"]?.toDouble();

    // toggles
    keepalive = data["keepalive"] ?? keepalive;
    stabilizer = data["stabilizer"] ?? stabilizer;
    passthrough = data["passthrough"] ?? passthrough;

    // trigger bindings
    triggerBindings.emplace(GamepadTrigger.lt, VK.from(data["lt_binding"]), 0);
    triggerBindings.emplace(GamepadTrigger.rt, VK.from(data["rt_binding"]), 0);

    // stick mapping
    leftAnalogBindings = mapSticks("left_analog_bindings", data);
    rightAnalogBindings = mapSticks("right_analog_bindings", data);

    // Button bindings
    Map<String, int>.from(data["button_bindings"] ?? {}).forEach((k, v) {
      GamepadCode? btn = GamepadCode.from(v);
      if (btn != null) buttonBindings.append(btn, VK.from(int.parse(k)));
    });

    // Toggle bindings
    Map<String, int>.from(data["toggle_bindings"] ?? {}).forEach((k, v) {
      ToggleMode? toggle = ToggleMode.from(v);
      if (toggle != null) toggleBindings.append(toggle, VK.from(int.parse(k)));
    });

    // associated scripts
    scripts = ScriptLoader.scriptsFromNames(
      List<String>.from(data["scripts"])
          .map(
            (el) => p.basename(el),
          )
          .toList(),
    )..forEach(
        (item) => item.insertBindingInstances(this),
      );

    // taggedBindings = Map<String, String>.from(jsonData["tagged_bindings"]);
    // valueBindings = Map<String, int>.from(jsonData["value_bindings"]);
  }
}

class ConfigLoader {
  static String baseDirectory = p.join(
    Directory.current.path,
    configFolderName,
  );

  static Map<String, Config> loadedConfigs = {};
  static String? _selected;
  static String? get selected => _selected;
  static set selected(String? v) =>
      _selected = (loadedConfigs.containsKey(v) ? v : null);

  // create config, save and add to loaded configs
  static Future<bool> create(String name) async {
    Config cfg = Config(name: name);

    while (loadedConfigs.containsKey(cfg.id)) {
      cfg.id = Uuid().v4();
    }

    loadedConfigs[cfg.id] = cfg;
    _selected = cfg.id;
    return save(_selected);
  }

  // import config from path to json source
  static Future<void> importPath(String path) async {
    File file = File(path);

    if (await file.exists()) {
      String contents = await file.readAsString();

      Config cfg = Config.fromJson(contents);
      loadedConfigs[cfg.id] = cfg;
    }
  }

  static Future<void> importDir({String? path}) async {
    final dir = Directory(path ?? baseDirectory);
    if (!await dir.exists()) return;

    // import unpacked configs
    for (var file in dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.json'),
        )) {
      String basename = p.basename(file.path);
      await importPath(p.join(path ?? baseDirectory, basename));
    }

    _selected = _selected ?? list()[0].id;

    // TODO import packed configs
  }

  // delete config by id
  static bool delete(String id) {
    if (loadedConfigs.length < 2) {
      return false;
    }

    loadedConfigs.removeWhere((v, _) => v == id);
    // TODO delete json file (complicated, needs to unlink ids)
    _selected = list()[0].id;
    return save(_selected);
  }

  static Future<bool> rename(String id, String newName) async {
    if (loadedConfigs.containsKey(id)) {
      loadedConfigs[id]?.name = newName;
      return save(id);
    }

    return false;
  }

  // runs config by name
  static void run(String? id) {
    // map config from memory into the emulator
    String? serial = getConfig(id)?.serialize();
  
    if (serial != null) {
      print(serial);
    }
  }

  static void runSelected() {
    run(_selected);
  }

  // saves config by name to file
  static bool save(String? id) {
    if (id == null) {
      return false;
    }

    // export json data of _selected to its corresponding file
    // TODO implement saving

    return false;
  }

  // lists configs by reference
  static List<Config> list() {
    return loadedConfigs.values.toList();
  }

  // returns instance of stored config
  static Config? getConfig(String? id) {
    return loadedConfigs[id];
  }

  // returns instance of currently selected config
  static Config? getSelected() {
    return getConfig(_selected);
  }

  static void setSelected(Config? config) {
    if (loadedConfigs.containsValue(config)) {
      _selected = config?.id;
    } else {
      _selected = null;
    }
  }
}

class ConfigController {
  static StreamController updateNotifier = StreamController.broadcast();
  static ValueUpdateStream updateStream = ValueUpdateStream();

  static StreamSubscription listen(void Function(dynamic) callback) {
    return updateNotifier.stream.listen(callback);
  }

  static void notify() {
    updateNotifier.add(null);
  }
}

// class Config {
//   static int? ltBinding,
//       rtBinding,
//       lsBinding = VK.keyNone.value,
//       rsBinding = VK.keyNone.value;

//   static double _sensitivity = 0.01;
//   static double _smoothing = 0.95;
//   static double _keepaliveStrength = 0.3;
//   static double _stabilizerStrength = 0.032;
//   static int _keepaliveSpeed = 50;
//   static int _stabilizerSpeed = 120;
//   static Map<String, List<int>> leftAnalogBindings = {};
//   static Map<String, List<int>> rightAnalogBindings = {};
//   static Map<String, String> taggedBindings = {};
//   static Map<String, int> valueBindings = {};
//   static Map<String, int> buttonBindings = {};
//   static Map<String, int> toggleBindings = {};
//   static List<String> scripts = [];
//   static bool keepalive = false;
//   static bool stabilizer = false;
//   static bool passthrough = false;

//   static double get sensitivity =>
//       unmapSlider(_sensitivity, 0.001, 0.1, range: 100);
//   static set sensitivity(double v) =>
//       _sensitivity = mapSlider(v, 0.001, 0.1, range: 100);

//   static double get smoothing => unmapSlider(_smoothing, 0.1, 1, range: 100);
//   static set smoothing(double v) =>
//       _smoothing = mapSlider(v, 0.1, 1, range: 100);

//   static double get stabilizerStrength =>
//       unmapSlider(_stabilizerStrength, 0.01, 0.15);
//   static set stabilizerStrength(double v) =>
//       _stabilizerStrength = mapSlider(v, 0.01, 0.15);

//   static double get keepaliveStrength =>
//       unmapSlider(_keepaliveStrength, 0.01, 0.5);
//   static set keepaliveStrength(double v) =>
//       _keepaliveStrength = mapSlider(v, 0.01, 0.5);

//   static int get stabilizerSpeed =>
//       unmapSlider(_stabilizerSpeed.toDouble(), 0, 360).toInt();
//   static set stabilizerSpeed(int v) =>
//       _stabilizerSpeed = mapSlider(v.toDouble(), 0, 360).toInt();

//   static int get keepaliveSpeed =>
//       unmapSlider(_keepaliveSpeed.toDouble(), 0, 360).toInt();
//   static set keepaliveSpeed(int v) =>
//       _keepaliveSpeed = mapSlider(v.toDouble(), 0, 360).toInt();

//   static StreamController updateNotifier = StreamController.broadcast();
//   static ValueUpdateStream updateStream = ValueUpdateStream();

//   static StreamSubscription listen(void Function(dynamic) callback) {
//     return updateNotifier.stream.listen(callback);
//   }

//   static void notify() {
//     updateNotifier.add(null);
//   }

//   static Map<String, int> stickRemapping = {
//     "Keyboard": VK.keyKeyboard.value,
//     "Mouse": VK.keyMouse.value,
//     "Unbind": VK.keyNone.value,
//   };

//   static Map<String, int> toggleRemapping = {
//     "toggleTap": 0,
//     "toggleHold": 1,
//     "untoggleHold": 2,
//   };

//   static List<List<int>> analogDirections = [
//     [0, 1],
//     [-1, 0],
//     [0, -1],
//     [1, 0],
//   ];

//   static const Map<String, int> gridLengths = {
//     "toggleTap": numCols,
//     "toggleHold": numCols,
//     "untoggleHold": numCols,
//     "ls": numSticks,
//     "rs": numSticks,
//     "dpadUp": numCols,
//     "dpadDown": numCols,
//     "dpadLeft": numCols,
//     "dpadRight": numCols,
//     "start": numCols,
//     "back": numCols,
//     "leftThumb": numCols,
//     "rightThumb": numCols,
//     "leftShoulder": numCols,
//     "rightShoulder": numCols,
//     "a": numCols,
//     "b": numCols,
//     "x": numCols,
//     "y": numCols,
//     "leftTrigger": 1,
//     "rightTrigger": 1,
//   };

//   static Map<String, List<int>> makeGrid() {
//     return {
//       for (final entry in gridLengths.entries)
//         entry.key: List.filled(entry.value, VK.keyNone.value),
//     };
//   }

//   static Map<String, List<int>> makeCounts() {
//     return {
//       for (final entry in gridLengths.entries)
//         entry.key: List.filled(entry.value, 0),
//     };
//   }

//   static void popluateGrid() {
//     for (String keyCode in buttonBindings.keys) {
//       int? buttonCode = buttonBindings[keyCode];
//       if (buttonCode == null) {
//         continue;
//       }
//       String? buttonName = GamepadCode.fromValue(buttonCode)?.name;
//       if (buttonName == null) {
//         continue;
//       }
//       if (grid.containsKey(buttonName)) {
//         for (int i = 0; i < grid[buttonName]!.length; ++i) {
//           if (grid[buttonName]![i] == VK.keyNone.value) {
//             grid[buttonName]![i] = int.parse(keyCode);
//             break;
//           }
//         }
//       }
//     }

//     for (String keyCode in toggleBindings.keys) {
//       int? mode = toggleBindings[keyCode];
//       if (mode == null) {
//         continue;
//       }
//       String? name = getKeyByValue(toggleRemapping, mode);
//       if (name == null) {
//         continue;
//       }
//       if (grid.containsKey(name)) {
//         for (int i = 0; i < grid[name]!.length; ++i) {
//           if (grid[name]![i] == VK.keyNone.value) {
//             grid[name]![i] = int.parse(keyCode);
//             break;
//           }
//         }
//       }
//     }

//     for (String keyCode in leftAnalogBindings.keys) {
//       List<int>? dir = leftAnalogBindings[keyCode];
//       if (dir == null) {
//         continue;
//       }
//       int index = analogDirections.indexWhere(
//         (element) =>
//             element.length == 2 && element[0] == dir[0] && element[1] == dir[1],
//       );
//       grid["ls"]![index] = int.parse(keyCode);
//     }

//     for (String keyCode in rightAnalogBindings.keys) {
//       List<int>? dir = rightAnalogBindings[keyCode];
//       if (dir == null) {
//         continue;
//       }
//       int index = analogDirections.indexWhere(
//         (element) =>
//             element.length == 2 && element[0] == dir[0] && element[1] == dir[1],
//       );
//       grid["rs"]![index] = int.parse(keyCode);
//     }

//     grid["leftTrigger"] = [ltBinding ?? VK.keyNone.value];
//     grid["rightTrigger"] = [rtBinding ?? VK.keyNone.value];
//   }

//   static Map<String, List<int>> grid = makeGrid();
//   static Map<String, List<int>> gridCount = makeCounts();

//   static void reset() {
//     ltBinding = null;
//     rtBinding = null;
//     lsBinding = VK.keyKeyboard.value;
//     rsBinding = VK.keyMouse.value;

//     _sensitivity = 0.24;
//     _smoothing = 0.95;
//     _keepaliveStrength = 0.3;
//     _stabilizerStrength = 0.032;
//     _keepaliveSpeed = 50;
//     _stabilizerSpeed = 120;
//     leftAnalogBindings = {};
//     rightAnalogBindings = {};
//     taggedBindings = {};
//     valueBindings = {};
//     buttonBindings = {};
//     toggleBindings = {};
//     scripts = [];
//     keepalive = false;
//     stabilizer = false;
//     passthrough = false;

//     grid = makeGrid();
//     gridCount = makeCounts();
//   }

//   static bool stickEnabled(int? stick) {
//     if (stick != null) {
//       return toStickLabel(stick) == stickRemapping.keys.first;
//     }

//     return false;
//   }

//   static String toStickLabel(int? keyCode) {
//     return stickRemapping.map((a, b) => MapEntry(b, a))[keyCode] ??
//         stickRemapping.keys.first;
//   }

//   static void setGrid(String id, int col, int val) {
//     if (grid.containsKey(id) && col < (grid[id]?.length ?? 0)) {
//       grid[id]?[col] = val;
//     }
//   }

//   static int getGrid(String id, int col) {
//     if (grid.containsKey(id) && col < (grid[id]?.length ?? 0)) {
//       return grid[id]?[col] ?? VK.keyNone.value;
//     }

//     return VK.keyNone.value;
//   }

//   static int scanGridRepeats() {
//     int count = 0;

//     final allValues = grid.values
//         .expand((list) => list)
//         .where((v) => v != VK.keyNone.value)
//         .toList();

//     final Map<int, int> frequency = {};
//     for (var value in allValues) {
//       frequency[value] = (frequency[value] ?? 0) + 1;
//     }

//     grid.forEach((key, valueList) {
//       gridCount[key] = valueList.map((v) {
//         return v == VK.keyNone.value ? 0 : (frequency[v] ?? 0);
//       }).toList();
//     });

//     return count;
//   }

//   static int countValueInstances(String id, int col) {
//     return gridCount[id]?[col] ?? 0;
//   }

//   static Map<String, int> formatGridBindings(Map<String, int> mapping) {
//     Map<String, int> formatted = {};

//     mapping.forEach((id, value) {
//       for (final binding in grid[id] ?? []) {
//         if (binding != VK.keyNone.value) {
//           formatted[binding.toString()] = value;
//         }
//       }
//     });

//     return formatted;
//   }

//   static Map<String, List<int>> generateAnalogBindings(String id) {
//     final bindings = <String, List<int>>{};
//     final directionList = grid[id];
//     if (directionList == null) return bindings;

//     for (int i = 0; i < directionList.length; ++i) {
//       final key = directionList[i];
//       if (key != VK.keyNone.value) {
//         bindings[key.toString()] = analogDirections[i];
//       }
//     }

//     return bindings;
//   }

//   static String serialize() {
//     Config.toggleBindings = Config.formatGridBindings(Config.toggleRemapping);
//     Config.buttonBindings = Config.formatGridBindings(GamepadCode.idMapping);

//     Config.leftAnalogBindings = Config.generateAnalogBindings("ls");
//     Config.rightAnalogBindings = Config.generateAnalogBindings("rs");

//     Config.ltBinding = Config.grid["leftTrigger"]?[0];
//     Config.rtBinding = Config.grid["rightTrigger"]?[0];

//     String encoding = JsonEncoder.withIndent('   ').convert({
//       "keepalive": Config.keepalive,
//       "passthrough": Config.passthrough,
//       "keepalive_speed": Config._keepaliveSpeed,
//       "stabilizer": Config.stabilizer,
//       "keepalive_strength": Config._keepaliveStrength,
//       "left_analog_bindings": Config.leftAnalogBindings,
//       "right_analog_bindings": Config.rightAnalogBindings,
//       "ls_binding": Config.lsBinding ?? VK.keyNone.value,
//       "lt_binding": Config.ltBinding ?? VK.keyNone.value,
//       "rs_binding": Config.rsBinding ?? VK.keyNone.value,
//       "rt_binding": Config.rtBinding ?? VK.keyNone.value,
//       "stabilizer_speed": Config._stabilizerSpeed,
//       "stabilizer_strength": Config._stabilizerStrength,
//       "stick_sensitivity": Config._sensitivity,
//       "stick_smoothing": Config._smoothing,
//       "scripts": Config.scripts,
//       "button_bindings": Config.buttonBindings,
//       "toggle_bindings": Config.toggleBindings,
//       "tagged_bindings": Config.taggedBindings,
//       "value_bindings": Config.valueBindings
//     });

//     printStatus();
//     return encoding;
//   }

//   static void deserialize(String val) {
//     reset();
//     Map<String, dynamic> jsonData = jsonDecode(val);

//     keepalive = jsonData["keepalive"] ?? keepalive;
//     stabilizer = jsonData["stabilizer"] ?? stabilizer;
//     passthrough = jsonData["passthrough"] ?? passthrough;
//     _sensitivity = jsonData["stick_sensitivity"] ?? sensitivity;
//     _smoothing = jsonData["stick_smoothing"] ?? smoothing;
//     _stabilizerSpeed = jsonData["stabilizer_speed"] ?? _stabilizerSpeed;
//     _stabilizerStrength =
//         jsonData["stabilizer_strength"] ?? _stabilizerStrength;
//     _keepaliveSpeed = jsonData["keepalive_speed"] ?? _keepaliveSpeed;
//     _keepaliveStrength = jsonData["keepalive_strength"] ?? _keepaliveStrength;
//     List<String> scriptPaths = List<String>.from(jsonData['scripts']);
//     scripts = ScriptLoader.validateScripts(scriptPaths);

//     buttonBindings = Map<String, int>.from(jsonData["button_bindings"]);
//     toggleBindings = Map<String, int>.from(jsonData["toggle_bindings"]);
//     ltBinding = jsonData["lt_binding"] ?? ltBinding;
//     rtBinding = jsonData["rt_binding"] ?? rtBinding;
//     lsBinding = jsonData["ls_binding"] ?? lsBinding;
//     rsBinding = jsonData["rs_binding"] ?? rsBinding;

//     leftAnalogBindings =
//         Map<String, dynamic>.from(jsonData["left_analog_bindings"]).map(
//       (key, value) => MapEntry(key, List<int>.from(value)),
//     );

//     rightAnalogBindings =
//         Map<String, dynamic>.from(jsonData["right_analog_bindings"]).map(
//       (key, value) => MapEntry(key, List<int>.from(value)),
//     );

//     taggedBindings = Map<String, String>.from(jsonData["tagged_bindings"]);
//     valueBindings = Map<String, int>.from(jsonData["value_bindings"]);

//     popluateGrid();
//     printStatus();
//     ConfigLoader.saveConfig();
//   }

//   static void printStatus() {
//     printf("---------------------");
//     printf("ltBinding: ${Config.ltBinding}");
//     printf("rtBinding: ${Config.rtBinding}");
//     printf("lsBinding: ${Config.lsBinding}");
//     printf("rsBinding: ${Config.rsBinding}");
//     printf("sensitivity: ${Config._sensitivity}");
//     printf("smoothing: ${Config._smoothing}");
//     printf("keepaliveStrength: ${Config._keepaliveStrength}");
//     printf("stabilizerStrength: ${Config._stabilizerStrength}");
//     printf("keepaliveSpeed: ${Config._keepaliveSpeed}");
//     printf("stabilizerSpeed: ${Config._stabilizerSpeed}");
//     printf("leftAnalogBindings: ${Config.leftAnalogBindings}");
//     printf("rightAnalogBindings: ${Config.rightAnalogBindings}");
//     printf("taggedBindings: ${Config.taggedBindings}");
//     printf("valueBindings: ${Config.valueBindings}");
//     printf("buttonBindings: ${Config.buttonBindings}");
//     printf("toggleBindings: ${Config.toggleBindings}");
//     printf("scripts: ${Config.scripts}");
//     printf("keepalive: ${Config.keepalive}");
//     printf("stabilizer: ${Config.stabilizer}");
//     printf("passthrough: ${Config.passthrough}");
//   }
// }

// class ConfigLoader {
//   static final String configDir = p.join(
//     Directory.current.path,
//     configFolderName,
//   );
//   static List<String> _configs = [];
//   static String? _selectedConfig;

//   static Future<void> initConfigFolder() async {
//     final dir = Directory(configDir);
//     if (!await dir.exists()) {
//       await dir.create(recursive: true);
//     }
//     await refreshConfigList();
//   }

//   static Future<void> refreshConfigList() async {
//     final dir = Directory(configDir);
//     if (!await dir.exists()) {
//       _configs = [];
//       return;
//     }

//     _configs = dir
//         .listSync()
//         .whereType<File>()
//         .where((f) => f.path.endsWith('.json'))
//         .map((f) => p.basename(f.path))
//         .toList();

//     if (_selectedConfig == null && _configs.isNotEmpty) {
//       _selectedConfig = _configs.first;
//     }
//   }

//   static List<String> getConfigs() => _configs;

//   static String? getSelectedConfig() => _selectedConfig;

//   static void setSelectedConfig(String? name) {
//     _selectedConfig = name;
//   }

//   static Future<bool> createConfig(String name) async {
//     if (name.isEmpty) return false;
//     final file = File(p.join(configDir, '$name.json'));
//     if (await file.exists()) return false;

//     Config.reset();
//     String data = Config.serialize();

//     await file.writeAsString(data);
//     await refreshConfigList();
//     _selectedConfig = '$name.json';
//     await refreshConfigList();
//     return true;
//   }

//   static Future<bool> saveConfig() async {
//     if (_selectedConfig == null) return false;
//     File file = File(p.join(configDir, _selectedConfig));
//     if (!await file.exists()) return false;
//     if (_selectedConfig?.isEmpty ?? true) return false;

//     String data = Config.serialize();

//     await file.writeAsString(data);
//     await refreshConfigList();
//     return true;
//   }

//   static Future<bool> renameConfig(String oldName, String newName) async {
//     final oldFile = File(p.join(configDir, oldName));
//     final newFile = File(p.join(configDir, '$newName.json'));

//     if (!await oldFile.exists() || await newFile.exists()) return false;

//     await oldFile.rename(newFile.path);
//     _selectedConfig = '$newName.json';
//     await refreshConfigList();
//     return true;
//   }

//   static Future<bool> deleteConfig(String name) async {
//     refreshConfigList();

//     if (_configs.length <= 1) {
//       return false;
//     }

//     final file = File(p.join(configDir, name));
//     if (await file.exists()) {
//       await file.delete();
//       if (_selectedConfig == name) _selectedConfig = null;
//       await refreshConfigList();
//       return true;
//     }
//     return false;
//   }

//   static String getSelectedConfigName() {
//     if (_selectedConfig == null) return '';
//     return p.basenameWithoutExtension(_selectedConfig!);
//   }

//   static String getSelectedConfigPath() {
//     return p.join(configDir, _selectedConfig);
//   }

//   static Future<void> load() async {
//     File file = File(p.join(configDir, _selectedConfig));
//     if (await file.exists()) {
//       final contents = await file.readAsString();
//       Config.deserialize(contents);
//     }
//   }

//   static Future<void> runSelected() async {
//     File file = File(p.join(configDir, _selectedConfig));
//     if (await file.exists()) {
//       String contents = await file.readAsString();

//       Map<String, dynamic> decoded = jsonDecode(contents);
//       Map<String, String> scriptSource = {};

//       List<dynamic> scripts = decoded["scripts"] ?? [];

//       for (String path in scripts) {
//         String name = p.basename(path);
//         String? source = await ScriptLoader.getScriptSource(path);
//         if (source != null) {
//           scriptSource[name] = source;
//         }
//       }

//       // get script source

//       UltrakeyRunner.start(contents, scriptSource);
//     }
//   }
// }

// class ScriptVariable {
//   ScriptVariable(
//     this.type,
//     this.value, {
//     this.valueMin = 0,
//     this.valueMax = sliderRange,
//   });

//   final int type;
//   final int value;
//   double valueMin;
//   double valueMax;
// }

// class ScriptLoader {
//   static final String scriptDir = p.join(
//     Directory.current.path,
//     scriptsFolderName,
//   );

//   static Map<String, ScriptVariable> scriptVariables = {};

//   static void watchScriptFolder(void Function(String, int) onChanged) {
//     monitorFolder(scriptDir, onUpdate: onChanged);
//   }

//   static List<String> listScripts() {
//     final dir = Directory(scriptDir);

//     if (!dir.existsSync()) return [];

//     return dir
//         .listSync()
//         .whereType<File>()
//         .where((file) => file.path.toLowerCase().endsWith('.lua'))
//         .map((file) => file.path.split(Platform.pathSeparator).last)
//         .toList();
//   }

//   static void selectScript(String name, {bool state = true}) {
//     final file = File(p.join(scriptDir, name));
//     if (file.existsSync()) {
//       printf('Script found: ${file.absolute.path}');
//       bool selected = Config.scripts.contains(file.path);
//       if (selected && state == false) {
//         Config.scripts.remove(file.path);
//       }

//       if (!selected && state == true) {
//         Config.scripts.add(file.path);
//       }
//     } else {
//       printf('Script not found: ${file.path}');
//     }
//   }

//   static String scriptAbsPath(String name) {
//     return p.join(scriptDir, name);
//   }

//   static Future<String?> getScriptSource(String scriptPath) async {
//     final file = File(scriptPath);
//     if (file.existsSync()) {
//       return await file.readAsString();
//     }

//     return null;
//   }

//   static bool scriptSelected(String scriptName) {
//     List<String> selectedPaths = Config.scripts;

//     List<String> selectedNames = selectedPaths
//         .map(
//           (path) => p.basename(path),
//         )
//         .toList();

//     return selectedNames.contains(scriptName);
//   }

//   static Future<Map<String, ScriptVariable>> parseScript(
//     String scriptPath,
//   ) async {
//     try {
//       String fileData = await readTextFromFile(scriptPath);
//       List<String> lines = fileData.split("\n");
//       Map<String, ScriptVariable> vars = {};

//       for (String line in lines) {
//         String? bindingName = getBindName(line);
//         if (bindingName != null) {
//           vars[bindingName] = ScriptVariable(
//             0,
//             int.parse(
//               Config.taggedBindings[bindingName] ??
//                   "${VK.keyNone.value}",
//             ),
//           );
//           continue;
//         }

//         Map<String, dynamic>? parsedValue = parseMinMaxBinding(line);
//         if (parsedValue != null) {
//           vars[parsedValue["name"]] = ScriptVariable(
//             1,
//             Config.valueBindings[parsedValue["name"]] ?? parsedValue["value"],
//             valueMin: (parsedValue["min"] as int).toDouble(),
//             valueMax: (parsedValue["max"] as int).toDouble(),
//           );
//           if (!Config.valueBindings.containsKey(parsedValue["name"])) {
//             Config.valueBindings[parsedValue["name"]] = parsedValue["value"];
//           }
//           continue;
//         }
//       }
//       return vars;
//     } catch (e) {
//       return {};
//     }
//   }

//   static Future<void> syncScriptVars() async {
//     scriptVariables.clear();
//     for (String script in Config.scripts) {
//       scriptVariables.addAll(
//         await ScriptLoader.parseScript(script),
//       );
//     }
//   }

//   static List<String> validateScripts(List<String> scripts) {
//     List<String> fileNames = scripts
//         .map(
//           (path) => p.basename(path),
//         )
//         .toList();

//     List<String> availableFiles = listFilenames(scriptDir);

//     List<String> routedFiles = [];
//     for (String fileName in fileNames) {
//       if (availableFiles.contains(fileName)) {
//         routedFiles.add(p.join(scriptDir, fileName));
//       }
//     }
//     return routedFiles;
//   }
// }

// class DecodedConfig {
//   DecodedConfig({
//     required this.source,
//     required this.config,
//   });

//   final Map<String, String> source;
//   final String config;
// }

// class ConfigEncoder {
//   static const String noKey = "00000000";
//   static const String noServer = "00000000";

//   static encrypt.Key deriveKey(String keyString) {
//     final keyBytes = utf8.encode(keyString);
//     final hash = sha256.convert(keyBytes).bytes;
//     return encrypt.Key(Uint8List.fromList(hash));
//   }

//   static String? encryptData(String plaintext, String keyString) {
//     try {
//       final key = deriveKey(keyString);
//       final iv = encrypt.IV.fromSecureRandom(16);
//       final encrypter = encrypt.Encrypter(
//         encrypt.AES(key, mode: encrypt.AESMode.cbc),
//       );
//       final encrypted = encrypter.encrypt(plaintext, iv: iv);

//       final combined = iv.bytes + encrypted.bytes;
//       return base64Encode(combined);
//     } catch (e) {
//       return null;
//     }
//   }

//   static String? decryptData(String base64Data, String keyString) {
//     try {
//       final key = deriveKey(keyString);
//       final combined = base64Decode(base64Data);
//       final iv = encrypt.IV(combined.sublist(0, 16));
//       final ciphertext = combined.sublist(16);
//       final encrypter = encrypt.Encrypter(
//         encrypt.AES(key, mode: encrypt.AESMode.cbc),
//       );
//       final encrypted = encrypt.Encrypted(Uint8List.fromList(ciphertext));
//       return encrypter.decrypt(encrypted, iv: iv);
//     } catch (e) {
//       return null;
//     }
//   }

//   static String? encode({
//     String? serverId,
//     String? roleId,
//     required String config,
//     required Map<String, String> scripts,
//   }) {
//     String key = roleId ?? noKey;
//     String server = serverId ?? noServer;

//     String encoded = jsonEncode({
//       "key": key,
//       "config": config,
//       "scripts": jsonEncode(scripts),
//     });

//     String? encrypted = encryptData(encoded, key);

//     if (encrypted == null) {
//       return null;
//     }

//     String serialized = JsonEncoder.withIndent('   ').convert({
//       "server": server,
//       "config": encrypted,
//     });

//     return serialized;
//   }

//   static DecodedConfig? decode({
//     required String serial,
//     String? setKey,
//   }) {
//     Map<String, dynamic> jsonData = jsonDecode(serial);

//     if (!jsonData.containsKey("config")) {
//       return null;
//     }

//     String server = jsonData["server"] ?? "";
//     String key = setKey ?? noKey;

//     if (server != noServer) {
//       // derive key
//     }

//     String? decrypted = decryptData(jsonData["config"], key);

//     if (decrypted != null) {
//       Map<String, dynamic> decoded = jsonDecode(decrypted);

//       if ((decoded["key"] ?? false) != key) {
//         return null;
//       }

//       String config = decoded["config"] ?? "";
//       String scriptsJson = decoded["scripts"] ?? "";

//       Map<String, dynamic> source = jsonDecode(scriptsJson);

//       return DecodedConfig(
//         source: source.cast(),
//         config: config,
//       );
//     }

//     return null;
//   }
// }
