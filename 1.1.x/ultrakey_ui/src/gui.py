import sys
from PyQt6.QtWidgets import *
from PyQt6.QtGui import QKeyEvent, QIcon, QPixmap, QGuiApplication, QPainter, QPen, QColor, QConicalGradient
from PyQt6.QtCore import *
import assets
from functools import partial
import string
import random

class LoadingSpinner(QWidget):
    def __init__(self, parent=None, radius=30, thickness=6):
        super().__init__(parent)
        self.radius = radius
        self.thickness = thickness
        self.angle = 0

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.rotate)
        self.timer.start(16)  # ~60 FPS

        self.setFixedSize(radius * 2 + thickness * 2, radius * 2 + thickness * 2)

    def rotate(self):
        self.angle = (self.angle + 3) % 360
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        center = self.rect().center()
        gradient = QConicalGradient(QPointF(center), -self.angle)

        # Setup gradient color stops
        gradient.setColorAt(0.0, QColor("#38C6F3"))
        gradient.setColorAt(1.0, QColor(0, 0, 0, 0))

        pen = QPen()
        pen.setWidth(self.thickness)
        pen.setBrush(gradient)
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)

        painter.setPen(pen)
        painter.drawArc(
            self.thickness,
            self.thickness,
            self.radius * 2,
            self.radius * 2,
            0,
            360 * 16  # full circle (angle in 1/16 deg)
        )

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
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Select Folder')
        self.setGeometry(100, 100, 300, 100)
        layout = QVBoxLayout()

        self.button = QPushButton('Select Folder', self)
        self.button.clicked.connect(self.show_dialog)
        layout.addWidget(self.button)

        self.setLayout(layout)

    def show_dialog(self):
        folder_path = QFileDialog.getExistingDirectory(self, 'Select Folder')
        if folder_path:
            return folder_path
        else:
            print('No folder selected.')
            return None

class FileSelector(QWidget):
    def __init__(self, extension='*.txt'):
        super().__init__()
        self.extension = extension
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Select File')
        self.setGeometry(100, 100, 300, 100)
        layout = QVBoxLayout()

        self.button = QPushButton(f'Select {self.extension} File', self)
        self.button.clicked.connect(self.show_dialog)
        layout.addWidget(self.button)

        self.setLayout(layout)

    def show_dialog(self):
        dialog = QFileDialog(self)
        dialog.setFileMode(QFileDialog.FileMode.ExistingFile)
        dialog.setNameFilter(f"Files ({self.extension})")
        if dialog.exec():
            file_paths = dialog.selectedFiles()
            if file_paths:
                print(f"Selected file: {file_paths[0]}")
                return file_paths[0]
        print('No file selected.')
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

    def toggle_disabled(self, disable=True):
        """Completely disables/enables all input boxes, blocking all interactions."""
        self.setDisabled(disable)
        self.setReadOnly(disable)

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

    def toggle_disable(self, disable=True):
        """Completely disables/enables all input boxes, blocking all interactions."""
        # self.setDisabled(disable)  # Grays out the input box
        self.setReadOnly(disable)  # Prevents text input

class Slider(QWidget):
    value_changed = pyqtSignal(int) 

    def __init__(self, label_text=None, min_value=0, max_value=100, default_value=50, callback=None, parent=None):
        super().__init__(parent)
        layout = QHBoxLayout()
        layout.setContentsMargins(5, 5, 5, 5)
        layout.setSpacing(10)

        if label_text != None:
            self.label = QLabel(label_text)
        self.slider = QSlider(Qt.Orientation.Horizontal)
        self.slider.setMinimum(min_value)
        self.slider.setMaximum(max_value)
        self.slider.setValue(default_value)
        self.value_label = QLabel(str(default_value))
        self.callback = callback

        self.slider.valueChanged.connect(self.update)

        if label_text != None:
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

    def update(self, value):
        """Update the label when the slider value changes."""
        self.value_label.setText(str(value))
        self.value_changed.emit(value)

        if (callable(self.callback)):
            self.callback(self)

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
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)

    def add_widget(self, widget: QWidget):
        self.layout.addWidget(widget)
        self.grid_data.append(widget)
        return widget

class ScrollableList(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.grid_data: QWidget = []

        outer_layout = QVBoxLayout(self)

        self.scroll_area = QScrollArea()
        self.scroll_area.setWidgetResizable(True)

        self.content_widget = QWidget()
        self.content_layout = QVBoxLayout(self.content_widget)
        self.content_layout.setAlignment(Qt.AlignmentFlag.AlignTop)

        self.scroll_area.setWidget(self.content_widget)
        outer_layout.addWidget(self.scroll_area)

    def add_item(self, widget):
        self.content_layout.addWidget(widget)
        self.grid_data.append(widget)
        return widget

    def clear(self):
        while self.content_layout.count():
            item = self.content_layout.takeAt(0)
            widget = item.widget()
            if widget is not None:
                widget.setParent(None)

        self.grid_data = []

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

class BaseUI(QWidget):
    def __init__(self):
        super().__init__()
        self.layout: QVBoxLayout = QVBoxLayout()
        self.setLayout(self.layout)

    def clear_layout(self):
        while self.layout.count():
            item = self.layout.takeAt(0)
            widget = item.widget()
            if widget:
                widget.deleteLater()

    def on_load(self):
        pass

    def add_widget(self, widget):
        self.layout.addWidget(widget)
        return widget

    def cleanup(self):
        print("cleanup")

class GUI(QObject):
    def __init__(self, style_sheet=None):
        super().__init__()
        self.app = QApplication(sys.argv)
        self.main_window = QMainWindow()
        self.main_window.setWindowTitle(''.join(random.choices(string.ascii_letters + string.digits, k=5)))
        self.main_window.setObjectName("Window")
        self.access_token = ""

        self.pixmaps = assets.load_pix_maps()
        self.icons = assets.load_icons()

        self.window_cache: dict[str, QWidget] = {}

        if style_sheet:
            self.app.setStyleSheet(style_sheet)

    def bind_on_exit(self, on_exit):
        if callable(on_exit):
            self.app.aboutToQuit.connect(on_exit)

    def set_window(self, widget: QWidget):
        self.main_window.setCentralWidget(widget)
        self.main_window.adjustSize()
        QTimer.singleShot(0, self.center_window)
        self.main_window.setMinimumSize(self.main_window.sizeHint())
        if isinstance(widget, BaseUI):
            widget.on_load()

    def center_window(self):
        screen = QGuiApplication.primaryScreen()
        if screen:
            screen_geometry = screen.availableGeometry()
            window_geometry = self.main_window.frameGeometry()

            x = screen_geometry.center().x() - window_geometry.width() // 2
            y = screen_geometry.center().y() - window_geometry.height() // 2

            self.main_window.move(x, y)

    def show(self):
        self.main_window.show()
        sys.exit(self.app.exec())