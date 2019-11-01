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

router.get("/:name", function(req, res, next) {
    const query = "SELECT * FROM projects WHERE project_name = " + "'" + req.params.name.split('_').join(' ') + "'";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows[0]);
        }
    });
});

router.get("/:name/rewards", function(req, res, next) {
    const query = "SELECT * FROM rewards WHERE project_name = " + "'" + req.params.name.split('_').join(' ') + "'";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.get("/:name/back/:email", function(req, res) {
    var project_name = req.params.name
    var email = req.params.email
    const query = `SELECT * FROM backingfunds WHERE project_name='${project_name}' AND email='${email}'`;
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when executing SQL");
        } else {
            res.status(200).send(data.rows);
        }
    })
});

router.get("/:name/back/:email/list", function(req, res) {
    var project_name = req.params.name
    var email = req.params.email
    const query = `SELECT transaction_id, amount, transaction_date FROM backingfunds NATURAL JOIN TRANSACTIONS WHERE project_name='${project_name}' AND email='${email}'`;
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when executing SQL");
        } else {
            res.status(200).send(data.rows);
        }
    })
});

router.get('/:name/back/:email/list/headers', function(req, res, next) {
    var sql_query = `SELECT transaction_id,  amount, transaction_date FROM backingfunds NATURAL JOIN TRANSACTIONS WHERE false`;
    pool.query(sql_query, (err, data) => {
      res.send(data)
    });
  })

router.post('/:name/unback/:id', function(req, res, next) {
    var sql_query = `DELETE FROM transactions WHERE transaction_id=${req.params.id}`;
    pool.query(sql_query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when executing SQL");
        } else {
            res.status(200).send();
        }
    })
});

router.post("/:name/back", function(req, res) {
    var {user_email, project_backed_name, backs_amount} = req.body
    const query = `SELECT * FROM backs('${user_email}', '${project_backed_name}', ${backs_amount})`;

    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when updating the project." + error);
        } else {
            if (data.rows[0].backs) {
                // Database check works.
                res.status(200).send("Success");
            } else {
                // Database check fails.
                res.status(200).send("Failure");
            }
            // res.status(200).send("Success");
        }
    })
});



module.exports = router;
