import os
import requests
from flask import Flask, render_template, request

app = Flask(__name__)
signs = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"]
fortune_api = os.getenv("FORTUNE_API")


@app.route("/", methods=["post", "get"])
def index():
    content = {}
    if request.method == "POST":
      name = request.form.get("fname")
      sign = request.form.get("signs")
      content = get_fortune_for_the_day(name, sign)
    return render_template('index.html', signs=signs, content=content)


def get_fortune_for_the_day(name, sign):
  data = {
    "name": name,
    "sign": sign
  }
  res = requests.post(f'{fortune_api}/get-fortune', data=data)
  res.raise_for_status()
  return res.json()
