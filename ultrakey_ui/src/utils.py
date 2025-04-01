from functools import partial
from gui import Container, Row, InputBox, QLabel, QPixmap
from bindings import *
import os
from assets import *
import requests
import assets
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time

def button_input_validator(container: Container):
    key_table = {k: [] for k, _ in QT_TO_VIRTUAL_KEY_MAP.items()}

    if getattr(container, "grid_data") != None:
        for row in container.grid_data:
            if isinstance(row, Row):
                for col in row.grid_data:
                    if isinstance(col, InputBox):
                        if col.text() in key_table:
                            key_table[col.text()].append(col)
                        col.flag(False)

    flagged = []
    unflagged = []
    for v in key_table.values():
        if len(v) > 1:
            flagged.extend(v)
        elif len(v) == 1:
            unflagged.extend(v)

    for widget in flagged:
        widget.flag(True)

    return (flagged, unflagged)

def button_input_row(cols, icon: QPixmap=None, text: str=None, callback=None, attr: dict = {}):
    row: Row = Row()
    if (icon):
        label: QLabel = QLabel()
        label.setPixmap(icon.pixmap(24, 24))
        label.setMinimumWidth(32)
        row.add_widget(label)

    if (text):
        label: QLabel = QLabel()
        label.setText(text)
        label.setMinimumWidth(56)
        row.add_widget(label)

    for _ in range(cols):
        row.add_widget(InputBox(callback=callback, attr=attr))

    return row

def stick_input_row(cols, icons: list[QPixmap] = None, attributes: list = None, callback: callable = None, attr: dict = {}):
    row: Row = Row()

    for col in range(cols):
        if icons != None and len(icons) > col:
            label: QLabel = QLabel()
            label.setPixmap(icons[col].pixmap(24, 24))
            label.setMinimumWidth(28)
            row.add_widget(label)

        local_attr = attr | attributes[col] if col < len(attributes) else {}
        row.add_widget(InputBox(callback=callback, attr=local_attr))

    return row

def toggle_button_row(row: Row, state: bool):
    for item in row.grid_data:
        if isinstance(item, InputBox):
            item.toggle_disabled(state)

def get_containers(path, ext):
    try:
        return [item for item in os.listdir(path) if ext in item]
    except:
        return []

def get_new_file_name(path, name, ext):
    name.replace(ext, "")
    existing = get_containers(path, ext)
    existing = [item for item in existing if name in item]

    if len(existing) > 0:
        name += "_" + str(len(existing))
    name += ext

    path = os.path.abspath(path + "/" + name)

    return (path, name)

def strip_extension(file):
    return os.path.splitext(file)[0]

def new_folder(path, name, ext):
    (path, name) = get_new_file_name(path, name, ext)
    os.mkdir(path)
    return (path, name)

class FolderChangeHandler(FileSystemEventHandler):
    def __init__(self, callback, throttle_interval=1.0):
        self.callback = callback
        self.throttle_interval = throttle_interval
        self._last_called = 0

    def on_any_event(self, event):
        if event.is_directory:
            return
        now = time.time()
        if now - self._last_called >= self.throttle_interval:
            self._last_called = now
            self.callback(event)

def start_watching_folder(folder_path, callback):
    event_handler = FolderChangeHandler(callback)
    observer = Observer()
    observer.schedule(event_handler, path=folder_path, recursive=True)
    observer.daemon = True
    observer.start()
    return observer

