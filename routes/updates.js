var express = require("express");
var router = express.Router();
const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
  // user: "postgres",
  // host: "localhost",
  // database: "postgres",
  // password: "password",
  // port: 5432
});

pool.connect();
router.get("/:project", function(req, res, next) {
  const query = `SELECT * FROM Updates WHERE project_name = ${req.params.project};`;

  console.log(query);
  pool.query(query, (error, data) => {
    if (error) {
      console.log(error);
      res.status(500).send("Failed to retrieve updates.");
    } else {
      res.status(200).send(data.rows);
    }
  });
});

router.post("/create", function(req, res, next) {
  var project_name = req.body.project_name;
  var update_title = req.body.update_title;
  var update_description = req.body.update_description;
  var query = `INSERT INTO Updates VALUES('${project_name}','${update_title}','${update_description}');`;
  console.log(query);
  pool.query(query, (error, data) => {
    if (error) {
      console.log(error);
      res.send(error);
    } else {
      res.send("success");
    }
  });
});

module.exports = router;
