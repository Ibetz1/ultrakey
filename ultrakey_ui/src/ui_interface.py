from gui import *
import assets
from bindings import *
from functools import partial
from utils import *
import shutil
from emulator import Emulator
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineSettings
from PyQt6.QtCore import QUrl
from urllib.parse import urlparse, parse_qs
import urllib.parse
import webbrowser
import account
import re
from watchdog.events import FileModifiedEvent

CONTAINER_EXTENSION = ".uk"
CONFIG_EXTENSION = ".ukc"
SCRIPT_EXTENSION = ".lua"

class LogoutButton(Button):
    def __init__(self, gui):
        super().__init__("Logout", callback=self.logout)
        self.setObjectName("Flagged")
        self.gui=gui

    def logout(self, widget: Button):
        account.logout_user(self.gui)

class ConfigContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Configurations", parent=parent)
        
        self.gui: UltraKeyUI = gui
        self.config_folder = os.path.abspath("./configs/")
        self.config_file = "conf"
        self.selected_config = None

        self.init_ui()

    def init_ui(self):
        input_actions: Row = self.add_widget(Row())
        self.logout = input_actions.add_widget(LogoutButton(self.gui.gui))

        self.dropdown = input_actions.add_widget(Dropdown([], callback=self.select_config))
        self.new_button = input_actions.add_widget(Button("New", callback=self.new_config))
        self.import_button = input_actions.add_widget(Button("Import", callback=self.import_config))
        self.save_button = input_actions.add_widget(Button("Save", callback=self.save_config))
        self.rename_button = input_actions.add_widget(Button("Rename", callback=self.rename_config))
        self.remove_button = input_actions.add_widget(Button("Delete", callback=self.delete_config))
        self.remove_button.setObjectName("Flagged")
        self.new_button.setMaximumWidth(65)
        self.save_button.setMaximumWidth(65)
        self.remove_button.setMaximumWidth(65)
        self.import_button.setMaximumWidth(65)
        self.rename_button.setMaximumWidth(65)
        self.logout.setMaximumWidth(65)

        buttons: Row = self.add_widget(Row())
        self.start_button = buttons.add_widget(Button("Start Emulator", callback=self.start_config))
        self.dropdown.addItems(get_containers(self.config_folder, CONTAINER_EXTENSION))
        self.check_button_status()

    def rename_config(self, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Config Name")
        if ok and name.strip() and self.selected_config != None:
            available = get_containers(self.config_folder, CONTAINER_EXTENSION)
            path = os.path.abspath(self.config_folder + "/" + self.selected_config)

            if self.selected_config in available:
                (new_path, new_name) = get_new_file_name(self.config_folder, name, CONTAINER_EXTENSION)
                
                try:
                    os.rename(path, new_path)
                    new_available = get_containers(self.config_folder, CONTAINER_EXTENSION)
                    self.dropdown.set_items(new_available)

                    if new_name in new_available:
                        self.dropdown.setCurrentText(new_name)
                except:
                    print("failed to rename file")

        self.check_button_status()

    def new_config(self, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Config Name")
        if ok and name.strip():
            (path, name) = new_folder(self.config_folder, name, CONTAINER_EXTENSION)
            self.dropdown.set_items(get_containers(self.config_folder, CONTAINER_EXTENSION))
            self.dropdown.setCurrentText(name)

            path = os.path.abspath(path + "/" + self.config_file + CONFIG_EXTENSION)

            with open(path, "wb+") as f:
                byte_data = InputRemapper().export_bytes()
                f.write(byte_data)

        self.check_button_status()

    def select_config(self, widget: Dropdown):
        self.selected_config = widget.currentText()

        available = get_containers(self.config_folder, CONTAINER_EXTENSION)

        if self.selected_config in available:
            path = os.path.abspath(self.config_folder + "/" + self.selected_config)

            configurations = get_containers(path, CONFIG_EXTENSION)

            if (self.config_file + CONFIG_EXTENSION in configurations):
                conf_path = os.path.abspath(path + "/" + self.config_file + CONFIG_EXTENSION)

                try:
                    with open(conf_path, "rb") as f:
                        byte_data = f.read()
                        self.gui.bindings.import_bytes(byte_data)
                        self.gui.map_bindings_ui()
                except:
                    print("failed to open file in select config")
        else:
            self.select_config = None

        if self.selected_config == "":
            self.selected_config = None

        print("selected conf", self.selected_config)
        self.check_button_status()

    def save_config(self, widget: Button):
        if self.selected_config == None:
            self.new_config(widget)
            return
        
        available = get_containers(self.config_folder, CONTAINER_EXTENSION)

        if self.selected_config in available:
            path = os.path.abspath(self.config_folder + "/" + self.selected_config)
            
            configurations = get_containers(path, CONFIG_EXTENSION)

            if (self.config_file + CONFIG_EXTENSION in configurations):
                conf_path = os.path.abspath(path + "/" + self.config_file + CONFIG_EXTENSION)

                try:
                    with open(conf_path, "wb+") as f:
                        byte_data = self.gui.bindings.export_bytes()
                        f.write(byte_data)
                except:
                    print("failed to open file in save config")

        self.check_button_status()

    def import_config(self, widget: Button):
        print("import config")
        selector: FolderSelector = FolderSelector()
        path = selector.show_dialog()

        if path != None:
            if path.lower().endswith(CONTAINER_EXTENSION):
                name = os.path.basename(path)
                dest = os.path.abspath(self.config_folder + "/" + name)
                
                try:
                    if path == dest:
                        return
                    
                    if os.path.exists(dest):
                        shutil.rmtree(dest)
        
                    shutil.copytree(path, dest)
                    containers = get_containers(self.config_folder, CONTAINER_EXTENSION)
                    self.dropdown.set_items(containers)
                    self.dropdown.setCurrentText(name)
                except:
                    print("failed to copy files")
            else:
                print("invalid file path")

        self.check_button_status()

    def delete_config(self, widget: Button):
        if self.selected_config == None:
            self.new_config(widget)
            return
        
        available = get_containers(self.config_folder, CONTAINER_EXTENSION)

        if self.selected_config in available:
            path = os.path.abspath(self.config_folder + "/" + self.selected_config)

            try:
                shutil.rmtree(path)
                self.dropdown.set_items(get_containers(self.config_folder, CONTAINER_EXTENSION))
            except:
                print("failed to delete config")

        self.check_button_status()

    def start_config(self, widget: Button):
        if (self.selected_config == None):
            return

        self.save_config(widget)

        path = os.path.abspath(self.config_folder + f"/{self.selected_config}/{self.config_file}{CONFIG_EXTENSION}")

        self.gui.emulator.start(path)

    def check_button_status(self, save_en = True):
        print("curcfg", self.selected_config)

        if self.selected_config == None:
            self.dropdown.setDisabled(True)
            self.remove_button.setDisabled(True)
            self.save_button.setDisabled(True)
            self.start_button.setDisabled(True)
            self.dropdown.setDisabled(True)
        else:
            if save_en:
                self.dropdown.setDisabled(False)
                self.new_button.setDisabled(False)
                self.remove_button.setDisabled(False)
                self.import_button.setDisabled(False)
                self.save_button.setDisabled(False)
                self.start_button.setDisabled(False)
                self.dropdown.setDisabled(False)
            else:
                self.save_button.setDisabled(True)
                self.start_button.setDisabled(True)

class ButtonContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Buttons", parent=parent)

        self.gui = gui

        self.init_ui()

    def init_ui(self):
        COLS = 3

        button_data = {}

        button_data[ButtonCode.GAMEPAD_A.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["a"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_A}
        ))
        button_data[ButtonCode.GAMEPAD_B.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["b"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_B}
        ))
        button_data[ButtonCode.GAMEPAD_X.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["x"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_X}
        ))
        button_data[ButtonCode.GAMEPAD_Y.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["y"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_Y}
        ))
        button_data[ButtonCode.GAMEPAD_LEFT_THUMB.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["left_joystick_press"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_LEFT_THUMB}
        ))
        button_data[ButtonCode.GAMEPAD_RIGHT_THUMB.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["right_joystick_press"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_RIGHT_THUMB}
        ))
        button_data[ButtonCode.GAMEPAD_LEFT_SHOULDER.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["left_bumper"], callback=self.button_changed,
            attr={"BUTTON": ButtonCode.GAMEPAD_LEFT_SHOULDER}
        ))
        button_data[ButtonCode.GAMEPAD_RIGHT_SHOULDER.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["right_bumper"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_RIGHT_SHOULDER}
        ))
        button_data[ButtonCode.GAMEPAD_DPAD_UP.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["dpad_up"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_DPAD_UP}
        ))
        button_data[ButtonCode.GAMEPAD_DPAD_DOWN.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["dpad_down"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_DPAD_DOWN}
        ))
        button_data[ButtonCode.GAMEPAD_DPAD_LEFT.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["dpad_left"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_DPAD_LEFT}
        ))
        button_data[ButtonCode.GAMEPAD_DPAD_RIGHT.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["dpad_right"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_DPAD_RIGHT}
        ))
        button_data[ButtonCode.GAMEPAD_BACK.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["view"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_BACK}
        ))
        button_data[ButtonCode.GAMEPAD_START.value] = self.add_widget(
            button_input_row(COLS, icon=self.gui.icons["menu"], callback=self.button_changed, 
            attr={"BUTTON": ButtonCode.GAMEPAD_START}
        ))

        self.button_data = button_data

    def button_changed(self, widget: InputBox):

        self.gui.bindings.button_bindings = {}

        flagged, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            button_code = item.get_attr("BUTTON")

            if button_code != None:
                self.gui.bindings.button_bindings[binding] = button_code.value

        save_en = len(flagged) < 1
        self.gui.config_container.check_button_status(save_en=save_en)

class StickContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Sticks", parent=parent)
        self.gui: UltraKeyUI = gui
        self.init_ui()

    def init_ui(self):
        slider_row = self.add_widget(Row())
        slider_row.add_widget(QLabel("Sensitivity"))
        self.sense_slider = slider_row.add_widget(
            Slider(callback=self.mouse_sensitivity_changed)
        )
        slider_row.add_widget(QLabel("Threshold"))
        self.threshold_mode = slider_row.add_widget(Dropdown(["OFF", "AUTO"], callback=self.mouse_thres_changed))

        icons = [
            self.gui.icons["left_joystick_up"], 
            self.gui.icons["left_joystick_down"], 
            self.gui.icons["left_joystick_left"], 
            self.gui.icons["left_joystick_right"]
        ]

        self.stick_data = {}

        self.ls_row = self.add_widget(stick_input_row(4, 
            icons,
            attributes=[{"DIR": [0, 1]}, {"DIR": [0, -1]}, {"DIR": [-1, 0]}, {"DIR":[1, 0]}],
            attr={"TABLE": "left_analog_bindings"},
            callback=self.stick_changed
        ))
        self.ls_bindings = self.ls_row.add_widget(Dropdown(
            options=["Keyboard", "Mouse","Unbind"],
            attr={"BINDING": "ls_binding", "ROW": self.ls_row}, 
            callback=self.stick_state_changed)
        )
        
        self.rs_row = self.add_widget(stick_input_row(4, 
            icons=icons,
            attributes=[{"DIR": [0, 1]}, {"DIR": [0, -1]}, {"DIR": [-1, 0]}, {"DIR":[1, 0]}],
            attr={"TABLE": "right_analog_bindings"},
            callback=self.stick_changed
        ))
        self.rs_bindings = self.rs_row.add_widget(Dropdown(
            options=["Keyboard", "Mouse", "Unbind"], 
            attr={"BINDING": "rs_binding", "ROW": self.rs_row},
            callback=self.stick_state_changed)
        )

        self.stick_data["left_analog_bindings"] = self.ls_row;
        self.stick_data["ls_binding"] = self.ls_bindings;
        self.stick_data["right_analog_bindings"] = self.rs_row;
        self.stick_data["rs_binding"] = self.rs_bindings;

    def mouse_sensitivity_changed(self, widget: Slider):
        self.gui.bindings.sensitivity = widget.value() / 1000

    def mouse_thres_changed(self, widget: Dropdown):
        self.gui.bindings.threshold = widget.currentIndex() > 0

    def stick_changed(self, widget: InputBox):
        if not isinstance(widget, InputBox):
            return

        self.gui.bindings.left_analog_bindings = {}
        self.gui.bindings.right_analog_bindings = {}

        flagged, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            table = item.get_attr("TABLE")
            direction = item.get_attr("DIR")

            if binding != None and table != None and direction != None and hasattr(self.gui.bindings, table):
                data = getattr(self.gui.bindings, table)
                data[binding] = direction

        save_en = len(flagged) < 1
        self.gui.config_container.check_button_status(save_en=save_en)

    def stick_state_changed(self, widget: Dropdown):
        print(self.gui.bindings.rs_binding)

        binding = widget.get_attr("BINDING")
        row = widget.get_attr("ROW")
        state = widget.currentIndex()
        value = 0

        if not isinstance(row, Row):
            print("invalid stick attributes")
            return

        valid_states = [
            VirtualKey.KEY_KEYBOARD.value,
            VirtualKey.KEY_MOUSE.value,
            VirtualKey.KEY_None.value,
        ]

        if state < len(valid_states):
            value = valid_states[state]

        if value != valid_states[0]:
            toggle_button_row(row, True)
        else:
            toggle_button_row(row, False)

        setattr(self.gui.bindings, binding, value)

class TriggerContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Triggers", parent=parent)
        # self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        self.gui = gui
        self.init_ui()

    def init_ui(self):
        trigger_data = {}

        trigger_data["lt_binding"] = self.add_widget(
            button_input_row(1, icon=self.gui.icons["left_trigger"], callback=self.triggers_changed, 
            attr={"BINDING": "lt_binding"}
        ))

        trigger_data["rt_binding"] = self.add_widget(
            button_input_row(1, icon=self.gui.icons["right_trigger"], callback=self.triggers_changed, 
            attr={"BINDING": "rt_binding"}
        ))

        self.trigger_data = trigger_data

    def triggers_changed(self, widget: InputBox):
        if not isinstance(widget, InputBox):
            return

        self.gui.bindings.lt_binding = 0
        self.gui.bindings.rt_binding = 0

        flagged, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            trigger = item.get_attr("BINDING")
            setattr(self.gui.bindings, trigger, binding)

        save_en = len(flagged) < 1
        self.gui.config_container.check_button_status(save_en=save_en)

class ToggleContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Toggles", parent=parent)
        self.gui = gui
        self.init_ui()

    def init_ui(self):
        COLS = 3
        toggle_data = {}

        toggle_data[0] = self.add_widget(button_input_row(COLS, text="Tap", callback=self.toggle_changed, attr={"BUTTON": 0}))
        toggle_data[1] = self.add_widget(button_input_row(COLS, text="Hold", callback=self.toggle_changed, attr={"BUTTON": 1}))
        toggle_data[2] = self.add_widget(button_input_row(COLS, text="Untoggle", callback=self.toggle_changed, attr={"BUTTON": 2}))

        self.toggle_data = toggle_data

    def toggle_changed(self, widget: InputBox):
        if not isinstance(widget, InputBox):
            return

        self.gui.bindings.toggle_bindings = {}

        flagged, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            button_code = item.get_attr("BUTTON")

            if button_code < 3:
                self.gui.bindings.toggle_bindings[binding] = button_code

        save_en = len(flagged) < 1
        self.gui.config_container.check_button_status(save_en=save_en)

class FlagBindingContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__(title="Bindings", parent=parent)
        self.gui: UltraKeyUI = gui
        self.load_ui()

    def load_ui(self):
        self.available_bindings: ScrollableList = self.add_widget(ScrollableList())

    def binding_row(self, text):
        label: QLabel = QLabel()
        label.setPixmap(self.gui.icons["bind"].pixmap(24, 24))
        label.setMinimumWidth(24)

        binding = self.available_bindings.add_item(
            button_input_row(
                1, 
                icon=self.gui.icons["keyboard"],
                callback=self.binding_changed,
            )
        )
        binding.set_attr("BINDING", text)

        binding.add_widget(label)
        bind_input = binding.add_widget(TextInput())
        bind_input.toggle_disable(True)
        bind_input.setText(text)

        bind_input.toggle_disable(True)
        bind_input.setMinimumWidth(128)

        return binding

    def value_row(self, text, minv=0, maxv=100):
        label: QLabel = QLabel()
        label.setPixmap(self.gui.icons["bind"].pixmap(24, 24))
        label.setMinimumWidth(24)

        icon: QLabel = QLabel()
        icon.setPixmap(self.gui.icons["value"].pixmap(24, 24))
        icon.setMinimumWidth(24)

        binding = self.available_bindings.add_item(Row())
        binding.add_widget(icon)
        slider = binding.add_widget(Slider(callback=self.value_changed))
        slider.slider.setMinimum(minv)
        slider.slider.setMaximum(maxv)

        binding.set_attr("BINDING", text)

        binding.add_widget(label)
        label.setAlignment(Qt.AlignmentFlag.AlignVCenter)
        bind_label = binding.add_widget(TextInput())
        bind_label.setText(text)
        bind_label.toggle_disable(True)

        return binding

    def binding_changed(self, widget: InputBox):
        flagged, unflagged = button_input_validator(self.available_bindings)
        save_en = len(flagged) < 1

        self.gui.bindings.flagged_bindings = {}

        for item in self.available_bindings.grid_data:
            if isinstance(item, Row):
                attr = item.get_attr("BINDING")
                if (attr != None and isinstance(item.grid_data[1], InputBox)):
                    box_data: InputBox = item.grid_data[1]
                    value = box_data.text()
                    key_code = QT_TO_VIRTUAL_KEY_MAP.get(value)

                    if key_code != None:
                        self.gui.bindings.flagged_bindings[key_code] = attr
        
        self.gui.config_container.check_button_status(save_en=save_en)

    def value_changed(self, widget: Slider):
        self.gui.bindings.value_bindings = {}

        for item in self.available_bindings.grid_data:
            if isinstance(item, Row):
                attr = item.get_attr("BINDING")
                if (attr != None and isinstance(item.grid_data[1], Slider)):
                    slider: Slider = item.grid_data[1]
                    v = slider.slider.value()

                    if (attr != None):
                        self.gui.bindings.value_bindings[attr] = v

    def assign_flags(self, used_flags):
        flagged_bindings = self.gui.bindings.flagged_bindings
        value_bindings = self.gui.bindings.value_bindings

        for name, widget in used_flags.items():
            if name in flagged_bindings.values():
                key_code = next((k for k, v in flagged_bindings.items() if v == name), None)
                key_label = VIRTUAL_TO_QT_KEY_MAP.get(int(key_code), None)
            
                if (key_label != None) and isinstance(widget, Row):
                    attr = widget.get_attr("BINDING")
                    binding_widget = widget.grid_data[1]
                    if attr != None and isinstance(binding_widget, InputBox):
                        binding_widget.setText(key_label)
            
            if name in value_bindings.keys() and isinstance(widget, Row):
                attr = widget.get_attr("BINDING")
                binding_widget = widget.grid_data[1]

                if (attr != None and isinstance(binding_widget, Slider)):
                    v = value_bindings.get(attr, None)
                    binding_widget.slider.setValue(v)

        self.binding_changed(None)
        self.value_changed(None)

    def load_flags(self):
        self.available_bindings.clear()

        used_flags = {}
        pattern = re.compile(
            r"--\[\s*(?:(?P<lval>-?\d+)\s*,\s*(?P<rval>-?\d+)|(?P<isbind>bind))\s*\]\s*"
            r"(?P<label>\w+)(?:\s*=\s*(?P<assignment>[^\n]+))?"
        )

        for path in self.gui.bindings.scripts:
            with open(path) as f:
                for line in f:
                    for match in pattern.finditer(line):
                        groups = match.groupdict()
                        vtype = 'bind' if groups.get('isbind', None) else 'range'
                        label = groups['label']
                        assignment = groups['assignment'].strip() if match['assignment'] else None
                        lvalue = int(groups['lval']) if groups['lval'] else None
                        rvalue = int(groups['rval']) if groups['rval'] else None
                        
                        if (vtype == "bind" and not label in used_flags):
                            used_flags[label] = self.binding_row(label)

                        elif (vtype == "range" and not label in used_flags):
                            used_flags[label] = self.value_row(label, lvalue or 0, rvalue or 100)
                            if (assignment != None):
                                val = int(assignment)
                                if not label in self.gui.bindings.value_bindings:
                                    self.gui.bindings.value_bindings[label] = val

        self.assign_flags(used_flags)

class ScriptContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Scripts", parent=parent)
        self.gui: UltraKeyUI = gui
        self.scripts: dict = {}
        self.load_ui()

    def load_ui(self):
        self.button_row = self.add_widget(Row())
        self.add_button = self.button_row.add_widget(Button("New", callback=self.add_script))
        self.add_button = self.button_row.add_widget(Button("Import", callback=self.import_script))
        self.available_scripts: ScrollableList = self.add_widget(ScrollableList())

    def script_entry(self, name: str) -> Row:
        container = Row()

        conf_container = self.gui.config_container
        config = os.path.join(conf_container.config_folder, conf_container.selected_config)
        path = os.path.join(config, strip_extension(name) + SCRIPT_EXTENSION)

        check_box = QCheckBox()
        container._layout.addWidget(check_box, alignment=Qt.AlignmentFlag.AlignVCenter)
        check_box.stateChanged.connect(lambda state: self.select_script(state, path))

        check_box.setChecked(path in self.gui.bindings.scripts)

        name_box: TextInput = container.add_widget(TextInput())
        name_box.toggle_disable(True)
        name_box.setText(name)
        open_button = container.add_widget(Button("Open", callback=partial(self.open_script, path)))
        rename_button = container.add_widget(Button("Rename", callback=partial(self.rename_script, path)))
        container.delete_button = container.add_widget(Button("Delete", callback=partial(self.delete_script, path)))
        container.delete_button.setObjectName("Flagged")
        container._layout.setAlignment(Qt.AlignmentFlag.AlignVCenter)

        return container
    
    def open_script(self, path, widget: Button):
        try:
            os.system(f"code {path}")
        except:
            print("failed to open script, please get VS code")
    
    def rename_script(self, path, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Config Name")
        if ok and name.strip():
            conf_container = self.gui.config_container
            config = os.path.join(conf_container.config_folder, conf_container.selected_config)

            (new_path, _) = get_new_file_name(config, name.strip(), SCRIPT_EXTENSION)

            try:
                os.rename(path, new_path)
            except:
                print("failed to rename")

        self.load_scripts()

    def delete_script(self, path, widget: Button):
        try:
            os.remove(path)
        except:
            print("failed to rename")

        self.load_scripts()

    def add_script(self, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Config Name")
        if ok and name.strip():
            conf_container = self.gui.config_container
            config = os.path.join(conf_container.config_folder, conf_container.selected_config)
            path = os.path.join(self.gui.config_container.config_folder, strip_extension(name) + SCRIPT_EXTENSION)

            (path, name) = get_new_file_name(config, name.strip(), SCRIPT_EXTENSION)

            with open(path, "wb+") as f:
                f.write(LUA_TEMPLATE.encode('utf-8'))

        self.load_scripts()

    def load_scripts(self):
        self.scripts = {}

        self.available_scripts.clear()

        conf_container = self.gui.config_container
        config = os.path.join(conf_container.config_folder, conf_container.selected_config)
        scripts: list = get_containers(config, "lua")

        for script in scripts:
            self.available_scripts.add_item(self.script_entry(script))

    def select_script(self, state, path):
        if state > 0:
            self.gui.bindings.scripts.append(path)
        else:
            self.gui.bindings.scripts.remove(path)

        self.gui.bindings.scripts = list(set(self.gui.bindings.scripts))

        self.gui.flag_bindings.load_flags()

    def import_script(self, widget: Button):
        selector: FolderSelector = FileSelector(extension="*.lua")
        path = selector.show_dialog()

        if path != None:
            path = os.path.abspath(path)
            if path.lower().endswith(SCRIPT_EXTENSION):
                name = strip_extension(os.path.basename(path))
                dest = os.path.abspath(self.gui.config_container.config_folder + f"/{self.gui.config_container.selected_config}")
                
                try:
                    if not dest in path:
                        (ndest, name) = get_new_file_name(dest, name, SCRIPT_EXTENSION)
                        shutil.copy2(path, ndest)

                except:
                    print("failed to copy files")
            else:
                print("invalid file path")

class UltraKeyUI(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.bindings: InputRemapper = InputRemapper()
        self.emulator: Emulator = Emulator()
        self.emulator.stop()
        self.gui = ui

        self.pixmaps = ui.pixmaps
        self.icons = ui.icons
        self.gui.main_window.setWindowIcon(self.icons["icon"])

        self.load_ui()
        self.script_list.load_scripts()
        ui.bind_on_exit(self.on_exit)

        start_watching_folder(self.config_container.config_folder, self.file_watchdog)

    def on_exit(self):
        self.emulator.stop()

    def load_ui(self):
        self.button_container: ButtonContainer = ButtonContainer(self)
        self.stick_container: StickContainer = StickContainer(self)
        self.trigger_container: TriggerContainer = TriggerContainer(self)
        self.toggle_container: ToggleContainer = ToggleContainer(self)
        self.flag_bindings: FlagBindingContainer = FlagBindingContainer(self)
        self.script_list: ScriptContainer = ScriptContainer(self)
        self.config_container: ConfigContainer = ConfigContainer(self)

        image_label = QLabel()
        pixmap = self.pixmaps["roller_graphic"].scaledToWidth(250, Qt.TransformationMode.SmoothTransformation)
        image_label.setPixmap(pixmap)
        image_label.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        image_label.setAlignment(Qt.AlignmentFlag.AlignLeft)
        
        self.add_widget(self.config_container)

        self.tabs: QTabWidget = self.add_widget(QTabWidget())
        self.controller_row = Row()

        self.setup_col: Column = self.controller_row.add_widget(Column())
        self.setup_col.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Preferred)
        self.setup_col.add_widget(self.stick_container)
        self.setup_col.add_widget(self.toggle_container)
        self.setup_col.add_widget(self.trigger_container)
        self.setup_col._layout.setAlignment(Qt.AlignmentFlag.AlignTop)

        self.buttons_col = self.controller_row.add_widget(Column())
        self.buttons_col.add_widget(self.button_container)

        self.script_row = Row()
        self.script_row._layout.addWidget(self.flag_bindings, stretch=0)
        self.script_row._layout.addWidget(self.script_list, stretch=0)

        self.tabs.addTab(self.controller_row, "Controller")
        self.tabs.addTab(self.script_row, "Scripts")

    def file_watchdog(self, event: FileModifiedEvent):
        if self.config_container.selected_config and self.config_container.selected_config in event.src_path:
            QTimer.singleShot(0, self.map_bindings_ui)

    def map_bindings_ui(self):
        for data in [
            self.button_container.button_data,
            self.toggle_container.toggle_data,
            self.trigger_container.trigger_data,
            self.stick_container.stick_data,
        ]:
            for _, widget in data.items():
                if isinstance(widget, Row):
                    for item in widget.grid_data:
                        if isinstance(item, InputBox):
                            item.setText("")
                        elif isinstance(item, TextInput):
                            item.setText("")

        for (binding_data, widget_data) in [
            (self.bindings.button_bindings, self.button_container.button_data),
            (self.bindings.toggle_bindings, self.toggle_container.toggle_data),
        ]:
            for keycode, buttoncode in binding_data.items():
                if int(keycode) in VIRTUAL_TO_QT_KEY_MAP and buttoncode in widget_data:
                    row: Row = widget_data[int(buttoncode)]
                    for item in row.grid_data:
                        if isinstance(item, InputBox) and item.text() == "":
                            item.setText(VIRTUAL_TO_QT_KEY_MAP[int(keycode)])
                            break
                            
        for binding, widget in {
            "lt_binding": self.trigger_container.trigger_data.get("lt_binding", None),
            "rt_binding": self.trigger_container.trigger_data.get("rt_binding", None)
        }.items() :
            keycode = getattr(self.bindings, binding) or None
            if isinstance(widget, Row) and keycode in VIRTUAL_TO_QT_KEY_MAP:
                for item in widget.grid_data:
                    if isinstance(item, InputBox) and item.text() == "":
                        item.setText(VIRTUAL_TO_QT_KEY_MAP[int(keycode)])

        valid_dropdown_states = {
            VirtualKey.KEY_KEYBOARD.value: 0,
            VirtualKey.KEY_MOUSE.value: 1,
            VirtualKey.KEY_None.value: 2,
        }

        for binding, widget in self.stick_container.stick_data.items():
            data = getattr(self.bindings, binding)

            if (isinstance(widget, Dropdown) and data in valid_dropdown_states):
                widget.setCurrentIndex(valid_dropdown_states[data])

            if isinstance(widget, Row) and isinstance(data, dict):
                widget_map = {
                    str(item.get_attr("DIR") or 0): item for item in widget.grid_data if isinstance(item, InputBox)
                }

                for binding, key in data.items() or {}:
                    input_box = widget_map.get(str(key), None)
                    if input_box and int(binding) in VIRTUAL_TO_QT_KEY_MAP:
                        keycode = VIRTUAL_TO_QT_KEY_MAP[int(binding)]
                        input_box.setText(keycode)

        sensitivty: Slider = self.stick_container.sense_slider
        threshold: Dropdown = self.stick_container.threshold_mode

        sensitivty.set_value(self.bindings.sensitivity * 1000)

        if (self.bindings.threshold):
            threshold.setCurrentIndex(1)
        else:
            threshold.setCurrentIndex(0)

        self.script_list.load_scripts()
        self.flag_bindings.load_flags()

class DiscordLogin(QWebEngineView):
    def __init__(self, ui: GUI, redirect=None):
        super().__init__()
        self.gui = ui
        self.redirect = redirect
        self.load_ui()

    def load_ui(self):
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.JavascriptEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.LocalStorageEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.PluginsEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.FullScreenSupportEnabled, True)
        self.page().profile().setHttpUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )

        # Discord OAuth2 settings
        client_id = '1353490529660309524'
        redirect_uri = urllib.parse.quote(assets.REDIRECT_URI, safe='')
        scope = 'identify+guilds+guilds.members.read'
        response_type = 'token'

        auth_url = (
            f"https://discord.com/oauth2/authorize"
            f"?client_id={client_id}"
            f"&redirect_uri={redirect_uri}"
            f"&response_type={response_type}"
            f"&scope={scope}"
        )

        self.urlChanged.connect(self.on_url_changed)
        self.setUrl(QUrl(auth_url))

    def on_url_changed(self, url: QUrl):
        url = url.toString()

        print("---------------", url)

        if ("access_token" in url):
            parsed_url = urlparse(url)
            fragment = parsed_url.fragment
            params = parse_qs(fragment)
            access_token = params.get('access_token', [None])[0]
            account.save_token(access_token)

            if callable(self.redirect):
                self.redirect(access_token)

        if ("access_denied" in url):
            self.gui.set_window(CredentialsWindow(self.gui))

    def cleanup(self):
        try:
            self.urlChanged.disconnect()
        except TypeError:
            pass

        self.page().deleteLater()
        self.deleteLater()

class CredentialsWindow(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.gui = ui
        self.layout.setSpacing(40)
        self.layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        self.load_ui()

    def load_ui(self):
        # self.add_widget(QLabel("Sign in with discord"))
        image_label = QLabel()
        pixmap = self.gui.pixmaps["signin"].scaledToWidth(250, Qt.TransformationMode.SmoothTransformation)
        image_label.setPixmap(pixmap)
        image_label.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        image_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.add_widget(image_label)
        self.swap_button = self.add_widget(Button("Sign In With Discord", callback=self.open_login))

    def on_load(self):
        self.gui.main_window.setMinimumSize(400, 400)
        self.gui.main_window.adjustSize()
        return super().on_load()

    def open_login(self, widget: Button):
        self.gui.set_window(DiscordLogin(self.gui, redirect=partial(account.check_login_status, self.gui)))
        self.gui.main_window.setGeometry(QRect(0, 0, 800, 800))

class PurchaseWindow(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.gui = ui
        self.layout.setSpacing(10)
        self.layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.load_ui()

    def on_load(self):
        self.gui.main_window.setMinimumSize(400, 400)
        self.gui.main_window.adjustSize()
        return super().on_load()

    def load_ui(self):
        self.add_widget(QLabel("Please Purchase Ultrakey"))
        self.swap_button = self.add_widget(Button("Purchase", callback=self.open_purchase))
        self.refresh_button = self.add_widget(Button("Refresh", callback=self.refresh))
        self.logout_button = self.add_widget(LogoutButton(self.gui))

    def open_purchase(self, widget: Button):
        webbrowser.open("https://discord.gg/4v9Pq6x23d")

    def refresh(self, widget: Button):
        account.login_user(self.gui)