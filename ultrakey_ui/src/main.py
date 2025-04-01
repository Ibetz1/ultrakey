from gui import *
from ui_interface import *
import account

# if __name__ == "__main__":
#     app = Application()
#     gui: GUI = GUI()
#     gui.main_window.setWindowIcon(gui.icons["icon"])

#     gui.access_token = account.load_token()
#     account.login_user(gui)

#     gui.show()
#     app.start()

from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import webbrowser
import urllib.parse
import threading
import time

class TokenHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_url = urlparse(self.path)
        if parsed_url.path != "/callback":
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")
            return

        query_params = parse_qs(parsed_url.query)
        access_token = query_params.get("access_token", [None])[0]

        if access_token:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b"<html><body><h1>Login complete</h1><p>You can close this window.</p></body></html>")

            threading.Thread(target=lambda: (time.sleep(1), self.server.shutdown())).start()
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Missing access_token")

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

def start_token_server():
    port = 49152
    server_address = ("localhost", port)
    httpd = HTTPServer(server_address, TokenHandler)
    print(f"[*] Listening for token on http://localhost:{port}/callback ...")
    httpd.serve_forever()

if __name__ == "__main__":
    open_discord_oauth()
    server_thread = threading.Thread(target=start_token_server)
    server_thread.start()
    server_thread.join()