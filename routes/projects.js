var express = require("express");
var router = express.Router();

const { Pool } = require("pg");
// const pool = new Pool({
// user: "postgres",
// host: "localhost",
// database: "postgres",
// password: "password",
// port: 5432
// });

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

router.get("/", function(req, res, next) {
  var sql_query = "SELECT * FROM Projects";
  pool.query(sql_query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.get("/hyper", function(req, res, next) {
  var sql_query = "SELECT * FROM get_hyper_projects();";
  pool.query(sql_query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.get("/fastfund", function(req, res, next) {
  var sql_query = "SELECT * FROM fast_funded_projects();";
  pool.query(sql_query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.post("/creator", function(req, res, next) {
  const query = `SELECT email FROM Projects WHERE project_name = '${req.body.project_name}';`;
  pool.query(query, (error, data) => {
    if (error) {
      res.status(500).send("Unable to retrieve project creator");
    } else {
      console.log(data);
      res.status(200).send(data.rows[0]);
    }
  });
});

module.exports = router;
