import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:win32/win32.dart';

final kernel32 = DynamicLibrary.open('kernel32.dll');

const eventModifyState = 0x0002;

final openEventA = kernel32.lookupFunction<
    IntPtr Function(
        Uint32 dwDesiredAccess, Int32 bInheritHandle, Pointer<Utf8> lpName),
    int Function(int dwDesiredAccess, int bInheritHandle,
        Pointer<Utf8> lpName)>('OpenEventA');

final setEvent = kernel32.lookupFunction<Int32 Function(IntPtr hEvent),
    int Function(int hEvent)>('SetEvent');

final resetEvent = kernel32.lookupFunction<Int32 Function(IntPtr hEvent),
    int Function(int hEvent)>('ResetEvent');

Future<void> sendSignal(String signalName, {int durationMs = 100}) async {
  final eventName = 'Global\\$signalName'.toNativeUtf8();
  try {
    final hEvent = openEventA(eventModifyState, 0, eventName);
    if (hEvent == 0) {
      throw WindowsException('OpenEvent failed');
    }

    if (setEvent(hEvent) == 0) {
      throw WindowsException('SetEvent failed');
    }

    await Future.delayed(Duration(milliseconds: durationMs));

    if (resetEvent(hEvent) == 0) {
      throw WindowsException('ResetEvent failed');
    }
  } catch (e) {
    printf('event send failed: $e');
  } finally {
    calloc.free(eventName);
  }
}

class WindowsException implements Exception {
  final String message;
  WindowsException(this.message);
  @override
  String toString() => 'WindowsException: $message';
}

int? childPid;
void launchWithTerminal(String exePath, List<String> arguments) async {
  final startupInfo = calloc<STARTUPINFO>();
  final processInfo = calloc<PROCESS_INFORMATION>();

  startupInfo.ref.cb = sizeOf<STARTUPINFO>();

  final args = arguments.map((arg) => '"$arg"').join(' ');
  final commandLineStr = '"$exePath" $args';
  final lpCommandLine = TEXT(commandLineStr);

  final success = CreateProcess(
    nullptr,
    lpCommandLine,
    nullptr,
    nullptr,
    FALSE,
    CREATE_NEW_CONSOLE,
    nullptr,
    nullptr,
    startupInfo,
    processInfo,
  );

  if (success != 0) {
    childPid = processInfo.ref.dwProcessId;
    print('Spawned PID: $childPid');
  } else {
    print('Failed to launch process: ${GetLastError()}');
  }

  calloc.free(lpCommandLine);
  calloc.free(startupInfo);
  calloc.free(processInfo);
}