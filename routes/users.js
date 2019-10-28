var express = require("express");
var router = express.Router();
const { Pool } = require("pg");

// const pool = new Pool({
//   // connectionString: process.env.DATABASE_URL
//   user: "postgres",
//   host: "localhost",
//   database: "postgres",
//   password: "password",
//   port: 5432
// });

// pool.connect();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

/* GET users listing. */
// router.get('/', function(req, res, next) {
//   res.send('respond with a resource');
// });

module.exports = router;

/* GET users */
router.get("/", function(req, res, next) {
  var query = "SELECT * FROM Users;";
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.post("/insert", function(req, res, next) {
  var name = req.body.name;
  var email = req.body.email;
  var contact = req.body.contact;
  var password = req.body.password;

  var query =
    "INSERT INTO Users(email, full_name, phone_number, password_hash) VALUES ('" +
    +"'" +
    name +
    "', '" +
    email +
    "', " +
    "'" +
    contact +
    "', " +
    "'" +
    password +
    "');";

  pool.query(query, (error, data) => {
    if (error) {
      res.send(query);
    } else {
      res.send("HELLOLLSL:Dkslasdasld");
    }
  });
});
