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

// const pool = new Pool({
//   connectionString: process.env.DATABASE_URL
// });

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

router.post("/register", function(req, res, next) {
  var name = req.body.name;
  var email = req.body.email;
  var contact = req.body.contact;
  var password = req.body.password;

  var query = `CALL register('${email}','${name}','${contact}','${password}');`;
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

router.get("/featuredbackers", function(req, res, next) {
  var query = "SELECT * FROM get_featured_backers();";
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});

router.get("/featuredcreators", function(req, res, next) {
  var query = "SELECT * FROM get_featured_creators();";
  pool.query(query, (error, data) => {
    if (error) {
      res.send(error);
    } else {
      res.send(data.rows);
    }
  });
});
