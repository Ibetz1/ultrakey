# frontend.py
import sys
import webbrowser
import requests
from PyQt6.QtWidgets import *
from PyQt6.QtCore import *

CLIENT_ID = "1353490529660309524"
REDIRECT_URI = "http://localhost:5000/callback"
SCOPE = "identify"

class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Login with Discord")
        self.layout = QVBoxLayout()
        self.label = QLabel("Not logged in.")
        self.button = QPushButton("Login with Discord")
        self.button.clicked.connect(self.login)
        self.layout.addWidget(self.label)
        self.layout.addWidget(self.button)
        self.setLayout(self.layout)

        # Timer to check login status
        self.timer = QTimer()
        self.timer.timeout.connect(self.check_status)
        self.timer.start(2000)

    def login(self):
        url = (
            f"https://discord.com/api/oauth2/authorize?client_id={CLIENT_ID}"
            f"&redirect_uri={REDIRECT_URI}"
            f"&response_type=code&scope={SCOPE}"
        )
        webbrowser.open(url)

    def check_status(self):
        try:
            r = requests.get("http://localhost:5000/status")
            data = r.json()
            if data["logged_in"]:
                self.label.setText(f"Logged in as {data['user']['username']}#{data['user']['discriminator']}")
        except Exception:
            pass

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = LoginWindow()
    window.show()
    sys.exit(app.exec())