from gui import *
import assets
from bindings import *
from functools import partial
from utils import *
import shutil
from emulator import Emulator

CONTAINER_EXTENSION = ".uk"
CONFIG_EXTENSION = ".ukc"
SCRIPT_EXTENSION = ".lua"

class ScriptContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Scripts", parent=parent)
        self.gui = gui
        self.init_ui()

    def init_ui(self):
        input_actions: Row = self.add_widget(Row())

        self.dropdown: Dropdown = input_actions.add_widget(Dropdown([], base_items=["None"], callback=self.bind_script))
        self.new_button = input_actions.add_widget(Button("New", callback=self.new_script))
        self.rename_button = input_actions.add_widget(Button("Rename", callback=self.rename_script))
        self.edit_button = input_actions.add_widget(Button("Edit", callback=self.open_script))
        self.new_button.setMaximumWidth(65)
        self.rename_button.setMaximumWidth(65)
        self.edit_button.setMaximumWidth(65)

    def new_script(self, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Script Name")
        if ok and name.strip():
            print("new script", name)
            return

    def rename_script(self, widget: Button):
        name, ok = QInputDialog.getText(None, "Enter Name", "Enter New Script Name")
        if ok and name.strip():
            print("rename script", name)
            return

    def open_script(self, widget: Button):
        print("open script")

    def bind_script(self, widget: Dropdown):
        print("bind script")

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
        self.dropdown = input_actions.add_widget(Dropdown([], callback=self.select_config))
        self.new_button = input_actions.add_widget(Button("New", callback=self.new_config))
        self.import_button = input_actions.add_widget(Button("Import", callback=self.import_config))
        # self.rename_button = input_actions.add_widget(Button("Rename", callback=self.rename_config))
        self.save_button = input_actions.add_widget(Button("Save", callback=self.save_config))
        self.remove_button = input_actions.add_widget(Button("Delete", callback=self.delete_config))
        self.new_button.setMaximumWidth(65)
        # self.rename_button.setMaximumWidth(65)
        self.save_button.setMaximumWidth(65)
        self.remove_button.setMaximumWidth(65)
        self.import_button.setMaximumWidth(65)

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

            # make the config folder
            (path, name) = new_folder(self.config_folder, name, CONTAINER_EXTENSION)
            self.dropdown.set_items(get_containers(self.config_folder, CONTAINER_EXTENSION))
            self.dropdown.setCurrentText(name)

            # make the config file
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

                # try:
                with open(conf_path, "rb") as f:
                    byte_data = f.read()
                    self.gui.bindings.import_bytes(byte_data)
                    self.gui.map_bindings_ui()
                # except:
                    # print("failed to open file in select config")
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
        path = selector.showDialog()

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

        tasks = self.gui.emulator.find_emu_processes()

        if len(tasks) > 0:
            self.start_button.setText("Restart Emulator")
        else:
            self.start_button.setText("Start Emulator")

    def check_button_status(self):
        print("curcfg", self.selected_config)

        if self.selected_config == None:
            self.dropdown.setDisabled(True)
            self.remove_button.setDisabled(True)
            # self.rename_button.setDisabled(True)
            self.save_button.setDisabled(True)
            self.start_button.setDisabled(True)
            self.dropdown.setDisabled(True)
        else:
            self.dropdown.setDisabled(False)
            self.new_button.setDisabled(False)
            # self.rename_button.setDisabled(False)
            self.remove_button.setDisabled(False)
            self.import_button.setDisabled(False)
            self.save_button.setDisabled(False)
            self.start_button.setDisabled(False)
            self.dropdown.setDisabled(False)

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

        _, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            button_code = item.get_attr("BUTTON")

            if button_code != None:
                self.gui.bindings.button_bindings[binding] = button_code.value

class StickContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__("Sticks", parent=parent)
        self.gui: UltraKeyUI = gui
        self.init_ui()

    def init_ui(self):
        slider_row = self.add_widget(Row())
        self.sense_slider = slider_row.add_widget(
            Slider("Stick Sensitivity", callback=self.mouse_sensitivity_changed)
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

        _, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            table = item.get_attr("TABLE")
            direction = item.get_attr("DIR")

            if binding != None and table != None and direction != None and hasattr(self.gui.bindings, table):
                data = getattr(self.gui.bindings, table)
                data[binding] = direction

    def stick_state_changed(self, widget: Dropdown):
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

        _, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            trigger = item.get_attr("BINDING")
            setattr(self.gui.bindings, trigger, binding)

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

        _, unflagged = button_input_validator(self)

        for item in unflagged:
            binding = QT_TO_VIRTUAL_KEY_MAP.get(item.text(), None)
            button_code = item.get_attr("BUTTON")

            if button_code < 3:
                self.gui.bindings.toggle_bindings[binding] = button_code

class FlagBindingContainer(Container):
    def __init__(self, gui, parent=None):
        super().__init__(title="Mapped Bindings", parent=parent)
        self.gui: UltraKeyUI = gui
        self.init_ui()

    def binding_changed(self, widget: InputBox):
        _, unflagged = button_input_validator(self)

        self.gui.bindings.flagged_bindings = {}
        for item in unflagged:
            row = item.get_attr("INDEX")

            if row != None and row < len(self.row_data):
                mapping: TextInput = self.row_data[row][1]
                if item.text() in QT_TO_VIRTUAL_KEY_MAP and isinstance(mapping, TextInput):
                    key_code = QT_TO_VIRTUAL_KEY_MAP[item.text()]
                    self.gui.bindings.flagged_bindings[key_code] = mapping.text()

    def init_ui(self):
        ROWS = 14
        COLS=1

        self.row_data = {}

        def generate_row(index):
            label: QLabel = QLabel()
            label.setPixmap(self.gui.icons["bind"].pixmap(24, 24))
            label.setMinimumWidth(24)

            binding = self.add_widget(
                button_input_row(
                    COLS, 
                    icon=self.gui.icons["keyboard"], 
                    callback=self.binding_changed,
                    attr={"INDEX": index}
                )
            )
            binding.add_widget(label)
            bind_input = binding.add_widget(TextInput(callback=self.binding_changed))
            bind_input.setMinimumWidth(128)
            bind_input.set_attr("INDEX", index)

            self.row_data[index] = (binding, bind_input)

        for i in range(ROWS):
            generate_row(i)

class UltraKeyUI(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.bindings: InputRemapper = InputRemapper()
        self.emulator: Emulator = Emulator()
        self.gui = ui

        self.pixmaps = assets.load_pix_maps()
        self.icons = assets.load_icons()
        self.gui.main_window.setWindowIcon(self.icons["icon"])

        self.load_ui()

        ui.bind_on_exit(self.on_exit)

    def on_exit(self):
        self.emulator.terminate()

    def load_ui(self):
        # self.script_container = ScriptContainer(self)
        self.button_container = ButtonContainer(self)
        self.stick_container = StickContainer(self)
        self.trigger_container = TriggerContainer(self)
        self.toggle_container = ToggleContainer(self)
        self.flag_bindings = FlagBindingContainer(self)
        self.config_container = ConfigContainer(self)

        self.controls_row = self.add_widget(Row(spacing=50))
        self.controls_row.setSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Fixed)

        image_label = QLabel()
        pixmap = self.pixmaps["roller_graphic"].scaledToWidth(250, Qt.TransformationMode.SmoothTransformation)
        image_label.setPixmap(pixmap)
        image_label.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        image_label.setAlignment(Qt.AlignmentFlag.AlignLeft)

        self.icon_row = self.add_widget(Row())
        self.icon_row.add_widget(image_label)
        self.icon_row.add_widget(self.config_container)
        
        self.main_row = self.add_widget(Row())
        self.sticks_col: Column = self.main_row.add_widget(Column())
        self.sticks_col.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Preferred)
        self.sticks_col.add_widget(self.stick_container)
        self.sticks_col.add_widget(self.toggle_container)

        self.triggers_row: Row = self.sticks_col.add_widget(Row())

        self.triggers_row.add_widget(self.trigger_container)
        self.triggers_row._layout.setAlignment(Qt.AlignmentFlag.AlignTop)

        self.scripts_col = self.main_row.add_widget(Column())
        self.scripts_col.add_widget(self.button_container)
        self.main_row.add_widget(self.flag_bindings)

    def map_bindings_ui(self):
        for data in [
            self.button_container.button_data,
            self.toggle_container.toggle_data,
            self.trigger_container.trigger_data,
            self.stick_container.stick_data,
            {k: v[0] for k, v in self.flag_bindings.row_data.items() },
        ]:
            for _, widget in data.items():
                if isinstance(widget, Row):
                    for item in widget.grid_data:
                        if isinstance(item, InputBox):
                            item.setText("")
                        elif isinstance(item, TextInput):
                            item.setText("")
                elif isinstance(widget, Dropdown):
                    widget.setCurrentIndex(0)

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
                            


        for (_, widgets), (key_code, value) in zip(self.flag_bindings.row_data.items(), self.bindings.flagged_bindings.items()):
            row_widget = widgets[0]
            
            if int(key_code) in VIRTUAL_TO_QT_KEY_MAP:
                key_code = VIRTUAL_TO_QT_KEY_MAP[int(key_code)]
                for widget in row_widget.grid_data:
                    if isinstance(widget, InputBox):
                        widget.setText(key_code)
                    elif isinstance(widget, TextInput):
                        widget.setText(value)

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

        # mousethres_slider: Slider = self.stick_container.slider_data.get("threshold", None)