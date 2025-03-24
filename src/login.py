from gui import *

def login_hook(widget: Button):
    print("login")

if __name__ == "__main__":
    ui: GUI = GUI()
    ui.main_window.resize(500, 500)
    ui.main_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

    pixmaps = assets.load_pix_maps()
    icons = assets.load_icons()
    ui.main_window.setWindowIcon(icons["icon"])
 
    button = ui.add_widget(Button("Login Through Discord", callback=login_hook))

    ui.show()