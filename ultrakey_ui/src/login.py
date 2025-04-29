import webbrowser
import urllib.parse
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import account
from PyQt6.QtCore import QTimer, QMetaObject, Qt
import assets
import os
import mimetypes

class TokenHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_url = urlparse(self.path)

        if parsed_url.path == "/uksignin.png":
            image_path = "assets/uksignin.png"
            if os.path.exists(image_path):
                self.send_response(200)
                mime_type, _ = mimetypes.guess_type(image_path)
                self.send_header('Content-type', mime_type or 'image/png')
                self.end_headers()
                with open(image_path, 'rb') as img:
                    self.wfile.write(img.read())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Image not found")
            return

        if parsed_url.path != "/callback":
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")
            return

        query_params = parse_qs(parsed_url.query)
        access_token = query_params.get("access_token", [""])[0]

        if access_token != "":
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()

            try:
                self.wfile.write(assets.read_file("assets/success.html"))
            except:
                self.wfile.write(b"<html><body><h1>Login Success</h1><p>You can close this window.</p></body></html>")
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(assets.read_file("assets/failed.html"))

            try:
                self.wfile.write(assets.read_file("assets/success.html"))
            except:
                self.wfile.write(b"<html><body><h1>Login Failed</h1><p>You can close this window.</p></body></html>")

        self.server.login_window.access_token_received.emit(access_token)
        threading.Thread(target=lambda: (time.sleep(1), self.server.shutdown())).start()

class GUIHTTPServer(HTTPServer):
    def __init__(self, server_address, RequestHandlerClass, login_window):
        super().__init__(server_address, RequestHandlerClass)
        self.login_window = login_window

def open_discord_oauth():
    client_id = '1353490529660309524'
    redirect_uri = urllib.parse.quote("https://ultrakey.onrender.com/callback", safe='')
    scope = 'identify guilds guilds.members.read'
    response_type = 'code'

    auth_url = (
        f"https://discord.com/oauth2/authorize"
        f"?client_id={client_id}"
        f"&redirect_uri={redirect_uri}"
        f"&response_type={response_type}"
        f"&scope={urllib.parse.quote(scope)}"
    )

    print(f"Opening browser to:\n{auth_url}")
    webbrowser.open(auth_url)

def start_token_server(login_window):
    port = 49152
    server_address = ("localhost", port)
    httpd = GUIHTTPServer(server_address, TokenHandler, login_window)
    print(f"[*] Listening for token on http://localhost:{port}/callback ...")
    httpd.serve_forever()

def await_access_token(login_window):
    open_discord_oauth()
    server_thread = threading.Thread(target=lambda: start_token_server(login_window))
    server_thread.start()

