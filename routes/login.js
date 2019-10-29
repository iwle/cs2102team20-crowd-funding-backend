var express = require("express");
var router = express.Router();
const { Pool } = require("pg");

const pool = new Pool({
  //   connectionString: process.env.DATABASE_URL
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432
});

pool.connect();

router.post("/", function(req, res, next) {
  var email = req.body.email;
  var password_hash = req.body.password_hash;

  const query = `SELECT email, full_name, phone_number, amount FROM Users NATURAL JOIN Wallets WHERE email = '${email}' AND password_hash = '${password_hash}';`;

  pool.query(query, (error, data) => {
    if (error) {
      res.status(500).send("Internal Server Error.");
    } else {
      // There exists NO users entry with the given username and password.
      if (data.rows[0].count === "0") {
        res.status(404).send("Invalid User.");
      } else {
        // There exists a user entry with the given username and password.
        res.send(data.rows[0]);
      }
    }
  });
});

router.get("/", function(req, res, next) {
  res.send("Unauthorized");
});

module.exports = router;
