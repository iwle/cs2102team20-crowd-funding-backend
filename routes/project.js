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

router.get("/:name/backers", function(req, res, next) {
    const query = "SELECT * FROM backingfunds WHERE project_name = " + "'" + req.params.name.split('_').join(' ') + "'";

    console.log(query)

    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving backers");
        } else {
            res.status(200).send(data.rows);
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

router.get("/backedRewards/:name/:email", function(req, res, next) {
    const query = "SELECT reward_name FROM backingfunds WHERE project_name = " + "'"
        + req.params.name.split('_').join(' ') + "' AND email = '" + req.params.email + "'";
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving backed rewards");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.get("/:name/updates", function(req, res, next) {
    const query = "SELECT * FROM updates WHERE project_name = " + "'" + req.params.name.split('_').join(' ') + "'";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project updates");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.get("/:name/comments", function(req, res, next) {
    const query = "SELECT * FROM comments WHERE project_name = " + "'" + req.params.name.split('_').join(' ')
        + "' ORDER BY comment_date DESC";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project updates");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.post("/:name/comments", function(req, res, next) {
    const query = "INSERT INTO comments (project_name, comment_text, email) VALUES " +
        "('" + req.body.projectName + "',$$" + req.body.newComment + "$$,'" + req.body.commenterEmail + "') RETURNING *";
    pool.query(query, (error, data) => {
        if (error) {
            //res.status(500).send("Internal server error when retrieving project updates");
            res.status(500).send(query);
        } else {
            res.status(200).send(data.rows[0]);
        }
    });
});

router.get("/:name/updates", function(req, res, next) {
    const query = "SELECT * FROM updates WHERE project_name = " + "'" + req.params.name.split('_').join(' ') + "'";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project updates");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.get("/:name/comments", function(req, res, next) {
    const query = "SELECT * FROM comments WHERE project_name = " + "'" + req.params.name.split('_').join(' ')
        + "' ORDER BY comment_date DESC";
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when retrieving project updates");
        } else {
            res.status(200).send(data.rows);
        }
    });
});

router.post("/:name/comments", function(req, res, next) {
    const query = "INSERT INTO comments (project_name, comment_text, email) VALUES " +
        "('" + req.body.projectName + "',$$" + req.body.newComment + "$$,'" + req.body.commenterEmail + "') RETURNING *";
    pool.query(query, (error, data) => {
        if (error) {
            //res.status(500).send("Internal server error when retrieving project updates");
            res.status(500).send(query);
        } else {
            res.status(200).send(data.rows[0]);
        }
    });
});

// Functions related to backing of a project

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
    const sql_query = `SELECT transaction_id,  amount, transaction_date FROM backingfunds NATURAL JOIN TRANSACTIONS WHERE false`;
    pool.query(sql_query, (err, data) => {
      res.send(data)
    });
  })

router.post('/:name/unback/:id', function(req, res, next) {
    console.log("Got a query");
    const sql_query = `SELECT * FROM unbacks('${req.params.name}', '${req.body.user_email}', ${req.params.id});`
    // const sql_query = `SELECT * FROM unbacks('${req.params.name}', '${user_email}', ${req.params.id})`;
    console.log(sql_query);
    pool.query(sql_query, (error, data) => {
        if (error) {
            console.log(error);
            res.status(500).send("Internal server error when executing SQL");
        } else {
            res.status(200).send();
        }
    })
});

router.post("/:name/back", function(req, res) {
    var {user_email, project_backed_name, reward_name, backs_amount} = req.body
    // backs is a function to create transaction and backing funds entry
    const query = `SELECT * FROM backs('${user_email}', '${project_backed_name}', '${reward_name}' , ${backs_amount})`;
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

router.post("/:name/unback", function(req, res) {
    var {user_email, project_backed_name, reward_name} = req.body
    // backs is a function to create transaction and backing funds entry
    const query = `SELECT * FROM unbacks('${project_backed_name}', '${reward_name}' , '${user_email}')`;
    console.log(query)
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when updating the project." + error);
        } else {
            if (data.rows[0].unbacks) {
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

// Functions to deal with Likes

router.get("/:name/like/:email", function(req, res) {
    const query = `INSERT INTO likes VALUES ('${req.params.email}', '${req.params.name}')`;
    console.log(query);
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when updating likes." + error);
        } else {
            res.status(200).send("Successfully added likes");
        }
    });
});

router.get("/:name/unlike/:email", function(req, res) {
    const query = `DELETE FROM likes WHERE email='${req.params.email}' AND project_name='${req.params.name}';`;

    console.log(query);
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when inserting likes" + error);
        } else {
            res.status(200).send("Successfully deleted likes");
        }
    });
});

router.get("/:name/islike/:email", function(req, res) {
    const query = `SELECT * FROM likes WHERE project_name='${req.params.name}' AND email='${req.params.email}';`;
    console.log(query);
    pool.query(query, (error, data) => {
        if (error) {
            res.status(500).send("Internal server error when inserting likes" + error);
        } else {
            res.status(200).send(data.rows);
        }
    });
})



module.exports = router;
