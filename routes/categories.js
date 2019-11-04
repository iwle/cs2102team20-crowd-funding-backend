var express = require("express");
var router = express.Router();

const { Pool } = require("pg");

const pool = new Pool({
  // connectionString: process.env.DATABASE_URL

  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432
});

router.get("/headers", function(req, res, next) {
  var sql_query = "SELECT * FROM Projects WHERE false";
  pool.query(sql_query, (err, data) => {
    res.send(data);
  });
});

router.get("/list", function(req, res, next) {
  var sql_query = "SELECT DISTINCT project_category FROM Projects";
  pool.query(sql_query, (err, data) => {
    res.send(data);
  });
});

module.exports = router;

// /* SQL Query */
// var sql_query = 'SELECT * FROM student_info';

// router.get('/', function(req, res, next) {
// 	pool.query(sql_query, (err, data) => {
// 		res.render('select', { title: 'Database Connect', data: data.rows });
// 	});
// });

// module.exports = router;
