var express = require("express");
var router = express.Router();

const { Pool } = require("pg");
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432
});

// const pool = new Pool({
// connectionString: process.env.DATABASE_URL
// });

router.post("/", function(req, res, next) {
  console.log("at login");
  var email = req.body.email;
  var search_text = req.body.search_text;
  const query = `CALL search('${email}','${search_text}')`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send("success");
    }
  });
});
module.exports = router;
