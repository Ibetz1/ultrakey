import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Update the name to the actual DLL filename (e.g., ultrakey_emu.dll)
final DynamicLibrary _ultrakeyLib = DynamicLibrary.open('ultrakey_emu.dll');
final DynamicLibrary _driverToolsLib = DynamicLibrary.open('driver_tools.dll');

// starts emulator with config
typedef EmuRunConfigC = Void Function(Pointer<Utf8> config);
typedef EmuRunConfigDart = void Function(Pointer<Utf8> config);

// starts emulator with no config
typedef EmuRunC = Void Function();
typedef EmuRunDart = void Function();

// pushes config to emulator
typedef EmuPushConfigC = Void Function(Pointer<Utf8> config);
typedef EmuPushConfigDart = void Function(Pointer<Utf8> config);

// pushes script source to emulator
typedef EmuPushScriptC = Void Function(Pointer<Utf8> script);
typedef EmuPushScriptDart = void Function(Pointer<Utf8> script);

// stops emulator
typedef EmuStopC = Void Function();
typedef EmuStopDart = void Function();

typedef FetchReqDriversC = Uint32 Function();
typedef FetchReqDriversDart = int Function();

typedef InstallVigemC = Void Function(Pointer<Utf8> folder);
typedef InstallVigemDart = void Function(Pointer<Utf8> folder);

typedef InstallInterceptionC = Void Function(Pointer<Utf8> folder);
typedef InstallInterceptionDart = void Function(Pointer<Utf8> folder);

typedef RequestAdminC = Void Function();
typedef RequestAdminDart = void Function();

typedef RestartPcC = Void Function();
typedef RestartPcDart = void Function();

final EmuRunConfigDart emuRunConfig = _ultrakeyLib
    .lookup<NativeFunction<EmuRunConfigC>>('emu_run_config_async')
    .asFunction();

final EmuRunDart emuRun =
    _ultrakeyLib.lookup<NativeFunction<EmuRunC>>('emu_run_async').asFunction();

final EmuPushConfigDart emuPushConfig = _ultrakeyLib
    .lookup<NativeFunction<EmuPushConfigC>>('emu_push_config')
    .asFunction();

final EmuPushScriptDart emuPushScript = _ultrakeyLib
    .lookup<NativeFunction<EmuPushScriptC>>('emu_push_script')
    .asFunction();

final EmuStopDart emuStop = _ultrakeyLib
    .lookup<NativeFunction<EmuStopC>>('emu_stop_async')
    .asFunction();

final FetchReqDriversDart fetchReqDrivers = _driverToolsLib
    .lookup<NativeFunction<FetchReqDriversC>>('fetch_req_drivers')
    .asFunction();

final InstallVigemDart installVigem = _driverToolsLib
    .lookup<NativeFunction<InstallVigemC>>('install_vigem')
    .asFunction();

final InstallInterceptionDart installInterception = _driverToolsLib
    .lookup<NativeFunction<InstallInterceptionC>>('install_interception')
    .asFunction();

final RequestAdminDart requestAdmin = _driverToolsLib
    .lookup<NativeFunction<RequestAdminC>>('get_admin')
    .asFunction();

final RestartPcDart restartPc = _driverToolsLib
    .lookup<NativeFunction<RestartPcC>>('restart_pc')
    .asFunction();
