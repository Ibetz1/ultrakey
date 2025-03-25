import sys
from PyQt6.QtWidgets import *
from PyQt6.QtGui import QKeyEvent, QIcon, QPixmap, QGuiApplication
from PyQt6.QtCore import *
import assets
from functools import partial

class Button(QPushButton):
    def __init__(self, text, callback=None, parent=None, attr={}):
        super().__init__(text, parent)
        if (callable(callback)):
            self.clicked.connect(lambda: callback(self))

        self.attr = attr
    
    def set_enabled(self, val):
        self.setEnabled(val)

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

class FolderSelector(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('Select Folder')
        self.setGeometry(100, 100, 300, 100)
        layout = QVBoxLayout()

        self.button = QPushButton('Select Folder', self)
        self.button.clicked.connect(self.showDialog)
        layout.addWidget(self.button)

        self.setLayout(layout)

    def showDialog(self):
        folder_path = QFileDialog.getExistingDirectory(self, 'Select Folder')
        if folder_path:
            return folder_path
        else:
            print('No folder selected.')
            return None

class Dropdown(QComboBox):
    def __init__(self, options, callback=None, parent=None, attr={}, base_items=[]):
        super().__init__(parent)
        self.addItems(options)
        self.base_items = base_items
        if callable(callback):
            self.currentIndexChanged.connect(lambda: callback(self))
        self.attr = attr
        self.addItems(self.base_items)

    def set_items(self, items):
        self.clear()
        self.addItems(items)
        self.addItems(self.base_items)

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)
    
class NoFocusLineEdit(QLineEdit):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.click_counter = 0
        self.setReadOnly(True)  # Prevent manual text entry
        self.setAlignment(Qt.AlignmentFlag.AlignCenter)

    def mousePressEvent(self, event):
        super().mousePressEvent(event)

    def focusInEvent(self, event):
        if self.isReadOnly():
            event.ignore()
        else:
            super().focusInEvent(event)
            self.click_counter = 1

    def focusOutEvent(self, event):
        """Deselects text when losing focus."""
        self.deselect()
        super().focusOutEvent(event)
        self.click_counter = 0

class InputBox(NoFocusLineEdit):
    def __init__(self, callback=None, parent=None, attr = {}):
        super().__init__(parent)
        self.installEventFilter(self)
        self.callback = callback
        self.attr = attr
        self.parent = parent
        self.used_values = {}
        self.flagged = False

    def flag(self, flag=True):
        """Sets the background color of an entry to red if flag is True, else resets it."""
        if (flag):
            self.setStyleSheet("background-color: red;")
            self.flagged = flag
        else:
            self.setStyleSheet("")
            self.flagged = flag
        return self.flagged

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

    def toggle_disbled(self, disable=True):
        """Completely disables/enables all input boxes, blocking all interactions."""
        self.setDisabled(disable)  # Grays out the input box
        self.setReadOnly(disable)  # Prevents text input

    def eventFilter(self, source: NoFocusLineEdit, event):
        def change_value(text):
            if text == None:
                source.clear()
            else:
                source.setText(text)

            if (callable(self.callback)):
                self.callback(self)
    
        if event.type() == QEvent.Type.KeyPress:
            key = event.key()
            key_text = event.text().upper()

            if key == Qt.Key.Key_Backspace or key == Qt.Key.Key_Delete:
                change_value(None)
                return True

            special_keys = {
                Qt.Key.Key_Enter: 'ENTER',
                Qt.Key.Key_Return: 'ENTER',
                Qt.Key.Key_Space: 'SPACE',
                Qt.Key.Key_Tab: 'TAB',
                Qt.Key.Key_Escape: 'ESCAPE',
                Qt.Key.Key_Left: 'LEFT',
                Qt.Key.Key_Right: 'RIGHT',
                Qt.Key.Key_Up: 'UP',
                Qt.Key.Key_Down: 'DOWN',
                Qt.Key.Key_Control: "CTRL",
                Qt.Key.Key_Alt: "ALT",
                Qt.Key.Key_Shift: "SHIFT",
                Qt.Key.Key_CapsLock: "CAPS",
                Qt.Key.Key_F1: "F1",
                Qt.Key.Key_F2: "F2",
                Qt.Key.Key_F3: "F3",
                Qt.Key.Key_F4: "F4",
                Qt.Key.Key_F5: "F5",
                Qt.Key.Key_F6: "F6",
                Qt.Key.Key_F7: "F7",
                Qt.Key.Key_F8: "F8",
                Qt.Key.Key_F9: "F9",
                Qt.Key.Key_F10: "F10",
            }

            if key in special_keys:
                change_value(special_keys[key])
            elif key_text.isprintable() and len(key_text) == 1:
                change_value(key_text)
            else:
                change_value(None)

            return True

        elif event.type() == QEvent.Type.MouseButtonPress:
            print(source.click_counter)

            if source.click_counter > 0:
                button = event.button()
                mouse_buttons = {
                    Qt.MouseButton.LeftButton: "LEFT_CLICK",
                    Qt.MouseButton.RightButton: "RIGHT_CLICK",
                    Qt.MouseButton.MiddleButton: "MIDDLE_CLICK",
                }
                button_name = mouse_buttons.get(button, None)
                if button_name:
                    change_value(button_name)
                    return True

            source.click_counter += 1

        return super().eventFilter(source, event)

class TextInput(QLineEdit):
    def __init__(self, callback=None, parent=None):
        super().__init__(parent)
        self.callback = callback
        self.attr = {}

        if (callable(callback)):
            self.textChanged.connect(lambda: callback(self))

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

class Slider(QWidget):
    value_changed = pyqtSignal(int)  # Signal emitted when the value changes

    def __init__(self, label_text="Slider", min_value=0, max_value=100, default_value=50, callback=None, parent=None):
        super().__init__(parent)
        layout = QHBoxLayout()
        layout.setContentsMargins(5, 5, 5, 5)
        layout.setSpacing(10)

        self.label = QLabel(label_text)
        self.slider = QSlider(Qt.Orientation.Horizontal)
        self.slider.setMinimum(min_value)
        self.slider.setMaximum(max_value)
        self.slider.setValue(default_value)
        self.value_label = QLabel(str(default_value))  # Show current slider value
        self.callback = callback

        self.slider.valueChanged.connect(self.update)

        layout.addWidget(self.label)
        layout.addWidget(self.slider)
        layout.addWidget(self.value_label)
        self.attr = {}

        self.setLayout(layout)

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

    def set_value(self, value):
        self.slider.setValue(int(value))
        self.update(value)

    def update(self, value):
        """Update the label when the slider value changes."""
        self.value_label.setText(str(value))
        self.value_changed.emit(value)

        if (callable(self.callback)):
            self.callback(self.slider)

class Row(QWidget):
    def __init__(self, parent=None, spacing=10):
        super().__init__(parent)
        self._layout: QHBoxLayout = QHBoxLayout()
        self._layout.setContentsMargins(0, 0, 0, 0)
        self._layout.setSpacing(spacing)
        self._layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.attr = {}
        self.grid_data = []
        self.setLayout(self._layout)

    def add_widget(self, widget):
        self._layout.addWidget(widget, alignment=Qt.AlignmentFlag.AlignTop)
        self.grid_data.append(widget)
        return widget

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

class Column(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._layout: QVBoxLayout = QVBoxLayout()
        self._layout.setContentsMargins(0, 0, 0, 0)
        self._layout.setSpacing(5)
        self._layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.attr = {}
        self.grid_data = []
        self.setLayout(self._layout)

    def add_widget(self, widget):
        self._layout.addWidget(widget)
        self.grid_data.append(widget)
        return widget

    def set_attr(self, key, val):
        self.attr[key] = val

    def get_attr(self, key):
        return self.attr.get(key, None)

class Container(QGroupBox):
    def __init__(self, title="Container", parent=None):
        super().__init__(title, parent)
        self.setFocusPolicy(Qt.FocusPolicy.ClickFocus)
        self.layout: QVBoxLayout = QVBoxLayout()
        self.layout.setContentsMargins(10, 10, 10, 10)
        self.layout.setSpacing(10)
        self.setLayout(self.layout)
        self.grid_data: QWidget = []
        self.title = title

        self.layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)

    def add_widget(self, widget: QWidget):
        self.layout.addWidget(widget)
        self.grid_data.append(widget)
        return widget

class Application(QApplication):
    def __init__(self):
        super().__init__(sys.argv)

        self.main_window = QMainWindow()
        self.main_window.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Preferred)

        self.setStyleSheet(
            assets.main_theme
        )

    def start(self):
        self.main_window.show()
        sys.exit(self.exec())

    def set_interface(self, ui: QWidget):
        self.main_window.setCentralWidget(ui)

class GUI:
    def __init__(self, style_sheet=None):
        self.app = QApplication(sys.argv)
        self.main_window = QMainWindow()
        self.main_window.setWindowTitle("Ultra Key")

        self.window_cache = {}

        if style_sheet:
            self.app.setStyleSheet(style_sheet)

    def bind_on_exit(self, on_exit):
        if callable(on_exit):
            self.app.aboutToQuit.connect(on_exit)

    def cache_window(self, name, widget):
        self.bind_on_exit(widget.cleanup)
        self.window_cache[name] = widget

    def set_window(self, name):
        self.main_window.setCentralWidget(self.window_cache[name])
        self.main_window.adjustSize()
        QTimer.singleShot(0, self.center_window)

    def center_window(self):
        screen = QGuiApplication.primaryScreen()
        if screen:
            screen_geometry = screen.availableGeometry()
            window_geometry = self.main_window.frameGeometry()

            print(window_geometry.width())
            print(window_geometry.height())

            # Calculate the top-left point to move the window to
            x = screen_geometry.center().x() - window_geometry.width() // 2
            y = screen_geometry.center().y() - window_geometry.height() // 2

            self.main_window.move(x, y)

    def show(self):
        self.main_window.show()
        sys.exit(self.app.exec())

class BaseUI(QWidget):
    def __init__(self):
        super().__init__()
        self.layout = QVBoxLayout()
        self.layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.setLayout(self.layout)

    def add_widget(self, widget):
        self.layout.addWidget(widget)
        return widget
    
    def cleanup(self):
        pass