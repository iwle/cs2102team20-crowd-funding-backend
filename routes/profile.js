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

/* Return all projects backed by the user. */
router.get("/:email/backedProjects", function(req, res, next) {
    const query = "SELECT * FROM projects WHERE email = " + "'" + req.params.email + "'";
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

module.exports = router;
