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

/* Return all projects backed by the user. */
router.get("/:email/createdProjects", function(req, res, next) {
    const query = "SELECT * FROM Projects WHERE email = " + "'" + req.params.email + "'";
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

/* Return all the projects created by the user. */
router.get("/:email/backedProjects", function(req, res, next) {
    const query = "Select * from projects P, " +
        "(select DISTINCT project_name from backingfunds WHERE email = '" + req.params.email + "') AS BF " +
        "WHERE P.project_name = BF.project_name";
    ;
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

/* Delete a project. */
router.delete("/deleteCreatedProject/:email/:project_name", function(req, res, next) {
    const query = "DELETE FROM Projects AS P " +
        "WHERE P.email = '" + req.params.email + "' AND " +
        "P.project_name = '" + req.params.project_name + "'";
    ;
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send("Deleted project " + req.body);
        }
    });
});

router.get("/follows/:followerEmail/:followingEmail", function(req, res, next) {
    const query = "SELECT * FROM Follows WHERE follower_id = " + "'" + req.params.followerEmail +
        "' AND following_id = '" + req.params.followingEmail + "'";
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project");
        } else {
            res.status(200).send(data.rows[0]);
        }
    });
});

router.post("/follows", function(req, res, next) {
    const query =
        "INSERT INTO Follows (follower_id, following_id) VALUES " +
        "('" +
        req.body.follower_id +
        "','" +
        req.body.following_id +
        "') RETURNING *";
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            console.log(error);
            //res.status(500).send("Internal server error when retrieving project updates");
            res.status(500).send(query);
        } else {
            res.status(200).send(data.rows[0]);
        }
    });
})

/* Delete a project. */
router.delete("/follows/:followerEmail/:followingEmail", function(req, res, next) {
    const query = "DELETE FROM Follows " +
        "WHERE follower_id = '" + req.params.followerEmail + "' AND " +
        "following_id = '" + req.params.followingEmail + "'";
    ;
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when unfollowing user.");
        } else {
            res.status(200).send("Unfollowed " + req.params.followingEmail);
        }
    });
});

module.exports = router;
