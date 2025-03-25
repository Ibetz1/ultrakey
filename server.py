from flask import Flask, request, redirect
import requests
import webbrowser
import urllib.parse
import os

app = Flask(__name__)

REDIRECT_URI = "https://ultrakey.onrender.com/callback"
SCOPE = "identify+guilds"
TOKEN_URL = "https://discord.com/api/oauth2/token"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")


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
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)