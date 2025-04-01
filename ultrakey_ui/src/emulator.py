import ctypes
from ctypes import wintypes
import os
import subprocess
import sys
import time
import ctypes
from ctypes import wintypes

kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)

OpenEvent = kernel32.OpenEventA
OpenEvent.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.LPCSTR]
OpenEvent.restype = wintypes.HANDLE

SetEvent = kernel32.SetEvent
SetEvent.argtypes = [wintypes.HANDLE]
SetEvent.restype = wintypes.BOOL

ResetEvent = kernel32.ResetEvent
ResetEvent.argtypes = [wintypes.HANDLE]
ResetEvent.restype = wintypes.BOOL

EVENT_MODIFY_STATE = 0x0002

RUNNER_NAME = "launcher.exe"

def send_signal(signal_name: str, duration_ms=100):
    event_name = f"Global\\{signal_name}".encode('utf-8')

    try:
        hEvent = OpenEvent(EVENT_MODIFY_STATE, False, event_name)
        if not hEvent:
            raise ctypes.WinError(ctypes.get_last_error())

        if not SetEvent(hEvent):
            raise ctypes.WinError(ctypes.get_last_error())

        print(f"[Python] Signal '{signal_name}' sent.")

        time.sleep(duration_ms / 1000.0)

        if not ResetEvent(hEvent):
            raise ctypes.WinError(ctypes.get_last_error())
        print(f"[Python] Signal '{signal_name}' reset.")
    except Exception as e:
        print("event send failed:", e)

class Emulator:
    def __init__(self):
        if getattr(sys, 'frozen', False):
            runner_path = os.path.abspath(RUNNER_NAME)
            runner_dir = os.path.dirname(runner_path)
            print("set base dir", runner_dir)
            os.environ["PATH"] = runner_dir + os.pathsep + os.environ["PATH"]

    def stop(self):
        send_signal("UKSSP")

    def start(self, config_path):
        if getattr(sys, 'frozen', False):
            subprocess.Popen(
                [RUNNER_NAME, "ultrakey_emu.exe", config_path],
                creationflags=subprocess.CREATE_NEW_PROCESS_GROUP,
            )
        else:
            os.system(f"start ./emulator/ultrakey_emu.exe {config_path}")

        self.stop()
