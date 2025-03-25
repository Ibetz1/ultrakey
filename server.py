from flask import Flask, request, redirect
import requests
import webbrowser
import urllib.parse

app = Flask(__name__)

CLIENT_ID = "1353490529660309524"
CLIENT_SECRET = "j21t154HUpiui2md1d7jS9wUg_-fwOhU"
REDIRECT_URI = "http://localhost:5000/callback"
SCOPE = "identify+guilds"
TOKEN_URL = "https://discord.com/api/oauth2/token"

@app.route('/')
def index():
    return "<h1>Why are you here</h1>"

@app.route('/callback')
def callback():
    code = request.args.get("code")
    if not code:
        return "Missing code in redirect."

    # Exchange code for token
    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPE
    }
    headers = { "Content-Type": "application/x-www-form-urlencoded" }

    response = requests.post(TOKEN_URL, data=data, headers=headers)
    if response.status_code != 200:
        return f"Token request failed: {response.text}"

    tokens = response.json()
    access_token = tokens["access_token"]
    return f"<h1>Logged in!</h1><p>Access Token: {access_token}</p>"

if __name__ == "__main__":
    app.run(port=5000)