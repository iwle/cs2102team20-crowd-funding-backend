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
router.get("/:email", function(req, res, next) {
    const query = `SELECT T1.project_name, T1.feedback_text, T1.rating_number,
     T1.feedback_date, T1.email 
     FROM feedbacks T1 INNER JOIN projects T2 ON T1.project_name = T2.project_name WHERE T2.email = '${req.params.email}';`;

     console.log(query);
    pool.query(query, (error, data) => {
      if (error) {
        console.log(error);
        res.status(500).send("Failed to retrieve feedback.");
      } else {
        res.status(200).send(data.rows);
      }
    });
  });
  
  router.post("/create", function(req, res, next) {
    var project_name = req.body.projectname;
    var feedback_text = req.body.feedback_text;
    var rating_number = req.body.rating_number;
    var email = req.body.email;
  
    var query = `CALL create_feedback('${project_name}','${feedback_text}','${rating_number}','${email}');`;
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
