import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

const double huge = 999999999999999;
const int numCols = 3;
const int numSticks = 4;
const int sliderRange = 360;

const String runtimeMode = "StaticExecutable"; // "PackedExecutable"

const String emulatorPath =
    "C:\\Users\\Ianbe.IANSPC\\Desktop\\ultrakey_flutter\\ultrakey_emu\\bin\\ultrakey_emu.exe";
const String configFolderName = "configs";
const String scriptsFolderName = "scripts";

int countArrayInstances<T>(List<T> array, T inst) {
  return array.where((v) => v == inst).length;
}

int? extractTrailingNumber(String input) {
  final match = RegExp(r'(\d+)$').firstMatch(input);
  return match != null ? int.parse(match.group(1)!) : null;
}

String stripTrailingNumber(String input) {
  return input.replaceFirst(RegExp(r'\d+$'), '');
}

double mapSlider(
  double val,
  double inMin,
  double inMax,
) =>
    inMin + val * (inMax - inMin) / sliderRange;

double unmapSlider(
  double val,
  double inMin,
  double inMax,
) =>
    (val - inMin) * sliderRange / (inMax - inMin);

void printf(Object? obj) {
  if (kDebugMode) {
    print(obj);
  }
}

void monitorFolder(
  String folderPath, {
  void Function(String, int)? onUpdate,
}) {
  final dir = Directory(folderPath);

  if (!dir.existsSync()) {
    printf("folder does not exist");
    return;
  }

  dir.watch(recursive: false).listen((event) {
    onUpdate?.call(event.path, event.type);
  });
}

Future<String> readTextFromFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    return await file.readAsString();
  } else {
    throw Exception('File does not exist: $path');
  }
}

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

K? getKeyByValue<K, V>(Map<K, V> map, V value) {
  for (final entry in map.entries) {
    if (entry.value == value) {
      return entry.key;
    }
  }
  return null;
}

List<String> listFilenames(String folderPath) {
  final dir = Directory(folderPath);

  if (!dir.existsSync()) return [];

  return dir
      .listSync()
      .whereType<File>()
      .map((file) => p.basename(file.path))
      .toList();
}

String getRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
      .join();
}

void openFileSmart(String filePath) async {
  final file = File(filePath);

  if (!await file.exists()) {
    printf('File does not exist: $filePath');
    return;
  }

  try {
    final result = await Process.run('code', [filePath], runInShell: true);

    if (result.exitCode != 0) {
      printf('VS Code not found or failed. Opening with default editor...');
      await Process.run('start', [filePath], runInShell: true);
    }
  } catch (e) {
    printf('Error launching VS Code: $e');
    await Process.run('start', [filePath], runInShell: true);
  }
}