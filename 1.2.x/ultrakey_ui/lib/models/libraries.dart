import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Update the name to the actual DLL filename (e.g., ultrakey_emu.dll)
final DynamicLibrary _ultrakeyLib = DynamicLibrary.open('ultrakey_emu.dll');
final DynamicLibrary _driverToolsLib = DynamicLibrary.open('driver_tools.dll');

typedef EmuMainC = Void Function(Pointer<Utf8> config);
typedef EmuMainDart = void Function(Pointer<Utf8> config);

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

final EmuMainDart emuMain = _ultrakeyLib
    .lookup<NativeFunction<EmuMainC>>('emu_run_async')
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