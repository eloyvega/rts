import os

import requests
from flask import Flask, render_template, request, url_for, redirect, session

from _version import version

app = Flask(__name__)
app.secret_key = "secret"
fortune_api = os.getenv("FORTUNE_API")


@app.route("/", methods=["get", "post"])
def index():
    content = session.get("content", None)
    data = {}
    metadata = []
    if content:
        data = content["data"]
        metadata = content["metadata"]
        session.clear()
    return render_template(
        "index.html", signs=SIGNS, data=data, metadata=metadata, version=version
    )


@app.route("/get_fortune/", methods=["post"])
def get_fortune():
    name = request.form.get("fname")
    sign = request.form.get("signs")
    session["content"] = get_fortune_for_the_day(name, sign)
    return redirect(url_for("index"))


def get_fortune_for_the_day(name, sign):
    data = {"name": name, "sign": sign}
    res = requests.post(f"{fortune_api}/api/get-fortune", data=data)
    res.raise_for_status()
    return res.json()


SIGNS = [
    "Aries",
    "Taurus",
    "Gemini",
    "Cancer",
    "Leo",
    "Virgo",
    "Libra",
    "Scorpio",
    "Sagittarius",
    "Capricorn",
    "Aquarius",
    "Pisces",
]
