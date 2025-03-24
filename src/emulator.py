import subprocess
import psutil

PROCESS_NAME = "ukemut.exe"

class Emulator:
    def __init__(self):
        pass

    def find_emu_processes(self):
        emu_processes = []
        for proc in psutil.process_iter(['pid', 'name', 'exe']):
            try:
                if proc.info['name'] == PROCESS_NAME:
                    emu_processes.append(proc)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        return emu_processes

    def start(self, config_path):
        self.terminate()
        self.proc = subprocess.Popen([f"./emulator/{PROCESS_NAME}", config_path])

    def terminate(self):
        for proc in self.find_emu_processes():
            proc.terminate()