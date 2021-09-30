const express = require("express");
const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const categories = ["love", "money", "work"];
const values = ["Great", "Good", "Meh...", "Not so good", "Watch out!"];

app.get("/", (req, res) => {
  res.send("Healthy");
});

app.post("/get-fortune", (req, res) => {
  const name = req.body.name || "default";
  const sign = req.body.sign;

  const lucky_numbers = getLuckyNumbers(name, sign);
  const fortunes = getFortunes(name, sign);

  const response = {
    lucky_numbers,
    fortunes,
  };

  res.send(response);
});

const getLuckyNumbers = (name, sign) => {
  return Array.from({ length: 6 }, () => Math.floor(Math.random() * 100));
};

const getFortunes = (name, sign) => {
  const fortunes = {};
  for (category of categories) {
    fortunes[category] = values[Math.floor(Math.random() * values.length)];
  }
  return fortunes;
};

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
