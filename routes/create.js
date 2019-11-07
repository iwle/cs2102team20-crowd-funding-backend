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

router.post("/", function(req, res, next) {
  var projectName = req.body.projectName;
  var projectCategory = req.body.projectCategory;
  var projectImageUrl = req.body.projectImageUrl;
  var projectDeadline = req.body.projectDeadline;
  var projectFundingGoal = req.body.projectFundingGoal;
  var projectDescription = req.body.projectDescription;
  var projectRewards = req.body.projectRewards;
  var creatorEmail = req.body.creatorEmail;

  /* --- Query: Insertion into Projects --- */
  const queryProjects =
    "INSERT INTO projects (project_name, project_description, project_deadline, " +
    "project_category, project_funding_goal, project_current_funding, project_image_url, email, project_created_timestamp) VALUES ('" +
    projectName +
    "', '" +
    projectDescription +
    "', '" +
    projectDeadline +
    "','" +
    projectCategory +
    "', '" +
    projectFundingGoal +
    "', '0', '" +
    projectImageUrl +
    "','" +
    creatorEmail +
    "', LOCALTIMESTAMP)";

  console.log(queryProjects);
  /* --- Query: Insertion into Rewards --- */
  var queryRewards =
    "INSERT INTO rewards (project_name, reward_name, reward_pledge_amount, reward_description, " +
    "reward_tier_id) VALUES ";
  var i = 0;
  for (; i < projectRewards.length; ) {
    let reward = projectRewards[i];
    queryRewards +=
      "('" +
      projectName +
      "','" +
      reward.rewardName +
      "','" +
      reward.rewardPledgeAmount +
      "','" +
      reward.rewardDescription +
      "','" +
      ++i +
      "'),";
  }
    queryRewards +=
        "('" +
        projectName +
        "', null ,'" +
        0 +
        "', null,'" +
        ++i +
        "'),";
  queryRewards = queryRewards.substr(0, queryRewards.length - 1);

  /* --- Final Query: Function to insert into Projects and Rewards. At the end, invoke function itself --- */
  var finalQuery = `CREATE OR REPLACE FUNCTION createProject ()
      RETURNS void AS $$
      BEGIN 
        ${queryProjects};
        ${queryRewards};
      END; $$
      LANGUAGE plpgsql;
      

      select createProject();`;

  console.log(finalQuery);
  pool.query(finalQuery, (error, data) => {
    if (error) {
      let errMsg;
      if (error.code === "10001") {
        errMsg = "You cannot create another project within 3 days.";
      } else if (error.code === "10002") {
        errMsg = "You have not logged in within the last 10 days.";
      } else if (error.code === "10003") {
        errMsg = "Your account is less than 30 days old.";
      }
      console.log(error.code);
      res.status(500).send(errMsg);
    } else {
      res.status(200).send("Project created !");
    }
  });
});

router.get("/", function(req, res, next) {
  const query = "SELECT project_name FROM projects";
  pool.query(query, (error, data) => {
    if (error) {
      console.log(error);
      res.status(500).send("Failed to retrieve project names.");
    } else {
      res.status(200).send(data.rows);
    }
  });
});

module.exports = router;
