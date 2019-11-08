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

router.put("/", function(req, res, next) {
  const query = "UPDATE rewards SET reward_name = " + "'" + req.body.rewardName
      + "', reward_description = '" + req.body.rewardDescription + "' "
      + " WHERE project_name = '" + req.body.projectName + "' AND reward_name = '" + req.body.oldRewardName + "'";
  console.log(query)
  pool.query(query, (error, data) => {
    if (error) {
      res.status(500).send("Failed to update reward.");
    } else {
      res.status(200).send("Success update reward");
    }
  })
})

module.exports = router;
