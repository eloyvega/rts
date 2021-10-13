const express = require("express");
var morgan = require('morgan')
const os = require("os");
const packageInfo = require("./package.json");

const app = express();
app.use(morgan('combined'))
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const categories = ["love", "money", "work"];
const values = ["Great", "Good", "Meh...", "Not so good", "Watch out!"];

// Endpoint for health check
app.get("/", (req, res) => {
  res.send("Healthy");
});

// Get fortune data
app.post("/api/get-fortune", (req, res) => {
  const lucky_numbers = getLuckyNumbers(req.body);
  const fortunes = getFortunes(req.body);

  const response = {
    metadata: [
      {
        name: packageInfo.name,
        version: packageInfo.version,
        os_arch: os.arch(),
        hostname: os.hostname(),
        lang: "NodeJS",
      },
    ],
    data: {
      lucky_numbers,
      fortunes,
    },
  };

  res.send(response);
});

const getLuckyNumbers = ({ name = "default", sign }) => {
  return Array.from({ length: 4 }, () => Math.floor(Math.random() * 100));
};

const getFortunes = ({ name = "default", sign }) => {
  const fortunes = {};
  for (category of categories) {
    fortunes[category] = values[Math.floor(Math.random() * values.length)];
  }
  return fortunes;
};

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
