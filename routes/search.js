var express = require("express");
var router = express.Router();

const { Pool } = require("pg");
// const pool = new Pool({
//   user: "postgres",
//   host: "localhost",
//   database: "postgres",
//   password: "password",
//   port: 5432
// });

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

router.post("/add", function(req, res, next) {
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

router.get("/history/:email", function(req, res, next) {
  const query = `SELECT * FROM SearchHistory NATURAL JOIN SEARCHES WHERE email='${req.params.email}';`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.post("/clear", function(req, res, next) {
  var email = req.body.email;
  const query = `DELETE FROM Searches WHERE email='${email}';`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send("success");
    }
  });
});

router.get("/project/:searchtext", function(req, res, next) {
  var search_text = req.params.searchtext;
  const query = `SELECT * FROM projects WHERE project_name LIKE '%${search_text}%';`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.get("/user/:searchtext", function(req, res, next) {
  var search_text = req.params.searchtext;
  const query = `SELECT * FROM users WHERE email LIKE '%${search_text}%';`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.get("/popsearches", function(req, res, next) {
  const query = `SELECT search_text, COUNT(*) FROM SearchHistory GROUP BY search_text ORDER BY COUNT(*) DESC LIMIT 2;`;
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

module.exports = router;
