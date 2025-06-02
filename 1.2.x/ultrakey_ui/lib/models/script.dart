import 'dart:io';

import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/utils.dart';
import 'package:path/path.dart' as p;

String? getBindName(String input) {
  input = input.trim();
  final regex = RegExp(r'^--\[bind\]([A-Z0-9_]+)$');
  final match = regex.firstMatch(input);
  return match?.group(1);
}

Map<String, dynamic>? parseMinMaxBinding(String input) {
  input = input.trim();

  final regex = RegExp(r'^--\[(\d+),(\d+)\]([A-Z0-9_]+)=(\d+)$');
  final match = regex.firstMatch(input);

  if (match != null) {
    final min = int.parse(match.group(1)!);
    final max = int.parse(match.group(2)!);
    final name = match.group(3)!;
    final value = int.parse(match.group(4)!);

    return {
      'min': min,
      'max': max,
      'name': name,
      'value': value,
    };
  }

  return null;
}

class Script {
  Script({
    required this.source,
    required this.name,
    this.type = SecurityType.public,
  });

  static Future<Script?> fromPath(String path) async {
    File file = File(path);

    if (await file.exists()) {
      String source = await file.readAsString();
      return Script(
        name: p.basename(path),
        source: source,
      )..parse();
    }

    return null;
  }

  SecurityType type;
  final String name;
  final String source;
  final Map<String, VK> flaggedBindings = {};
  final Map<String, ConfigVar> sliderBindings = {};
  final Map<String, bool> booleanBindings = {};

  int countBindingInstance(
    Config cfg,
    String id,
    Map<String, dynamic> Function(Script) bindingTable,
  ) {
    int count = 0;

    for (Script scr in cfg.scripts) {
      if (bindingTable(scr).containsKey(id) && scr.name != name) count++;
    }

    return count;
  }

  void insertBindingInstances<T>(
    Config cfg,
  ) {
    for (String id in flaggedBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.flaggedBindings);
      if (count == 0) {
        cfg.flaggedBindings[id] = flaggedBindings[id] ?? VK.keyNone;
      }
    }

    for (String id in sliderBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.sliderBindings);
      if (count == 0 && sliderBindings[id] != null) {
        cfg.sliderBindings[id] = sliderBindings[id]!;
      }
    }

    for (String id in booleanBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.booleanBindings);
      if (count == 0 && booleanBindings[id] != null) {
        cfg.booleanBindings[id] = booleanBindings[id]!;
      }
    }
  }

  void removeBindingInstances<T>(
    Config cfg,
  ) {
    for (String id in flaggedBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.flaggedBindings);
      if (count == 0) {
        cfg.flaggedBindings.remove(id);
      }
    }

    for (String id in sliderBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.sliderBindings);
      if (count == 0) {
        cfg.sliderBindings.remove(id);
      }
    }

    for (String id in booleanBindings.keys) {
      int count = countBindingInstance(cfg, id, (scr) => scr.booleanBindings);
      if (count == 0) {
        cfg.booleanBindings.remove(id);
      }
    }
  }

  void parse() {
    try {
      List<String> lines = source.split("\n");

      for (String line in lines) {
        // parse bindings
        String? bindingName = getBindName(line);
        if (bindingName != null) {
          flaggedBindings[bindingName] = VK.keyNone;
          continue;
        }

        // parse booleans
        // TODO

        // parse sliders
        Map<String, dynamic>? parsedValue = parseMinMaxBinding(line);
        if (parsedValue != null) {
          double? min = parsedValue["min"]?.toDouble();
          double? max = parsedValue["max"]?.toDouble();
          double? value = parsedValue["value"]?.toDouble();
          String? name = parsedValue["name"]?.toString();

          if (min == null || max == null || value == null || name == null) {
            printf("couldnt parse script variable");
            continue;
          }

          sliderBindings[name] = ConfigVar(min, max, ival: value);

          continue;
        }
      }
    } catch (e) {
      printf("failed to parse script $e");
      return;
    }
  }
}

class ScriptLoader {
  static Map<String, Script> scripts = {};
  static String baseDirectory = p.join(
    Directory.current.path,
    scriptsFolderName,
  );

  static Future<void> importPath(String path) async {
    Script? scr = await Script.fromPath(path);

    if (scr != null) {
      scripts[p.basename(path)] = scr;
    }
  }

  static Future<void> importDir({String? path}) async {
    final dir = Directory(path ?? baseDirectory);
    if (!await dir.exists()) return;

    // import unpacked configs
    for (File file in dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.lua'),
        )) {
      final item = p.basename(file.path);
      await importPath(p.join(path ?? baseDirectory, item));
    }
  }

  static List<Script> scriptsFromNames(List<String> names) => scripts.values
      .where(
        (script) => names.contains(script.name),
      )
      .toList();

  static List<Script> list() => scripts.values.toList();
}
