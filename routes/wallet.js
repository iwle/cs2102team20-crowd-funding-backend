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

router.post("/retrieve", function(req, res, next) {
  var email = req.body.email;

  const updatedWalletAmountQuery = `SELECT amount FROM Wallets WHERE email = '${email}';`;

  pool.query(updatedWalletAmountQuery, (error, walletAmountData) => {
    if (error) {
      res.status(500).send("Internal Server Error.");
    } else {
      // There exists NO users entry with the given email.
      if (walletAmountData.rows.length !== 1) {
        res.status(404).send("Invalid User.");
      } else {
        console.log(walletAmountData.rows[0]);
        const walletData = {
          ...walletAmountData.rows[0],
          topupHistory: [],
          backingHistory: [],
          transferHistory: []
        };

        // Begin Retrieving Other Neecessary Wallet Histories
        // TopUp History
        const topUpHistoryQuery = `SELECT amount, transaction_date, 'Topup' as type FROM Transactions NATURAL JOIN TopUpFunds WHERE email = '${email}';`;
        // console.log("Query: " + topUpHistoryQuery);
        pool.query(topUpHistoryQuery, (error, topUpHistoryData) => {
          if (error) {
            res.status(500).send("Internal Server Error.");
          } else {
            walletData.topupHistory = topUpHistoryData.rows;

            console.log("Retreiving Transfers");
            // Transfer History
            const transferHistoryQuery = `SELECT 
              (CASE
                WHEN email_transferer = '${email}' THEN amount * -1
                WHEN email_transfee = '${email}' THEN amount
                END) as amount,
              transaction_date,
              (CASE
                WHEN email_transferer = '${email}' THEN email_transfee
                WHEN email_transfee = '${email}' THEN email_transferer
                END) as email,
              (CASE
                WHEN email_transferer = '${email}' THEN 'TransferTo'
                WHEN email_transfee = '${email}' THEN 'TransferFrom'
                END) as type
              FROM Transactions NATURAL JOIN TransferFunds WHERE email_transferer = '${email}' OR email_transfee = '${email}';`;
            // console.log("Query: " + transferHistoryQuery);
            pool.query(transferHistoryQuery, (error, transferHistoryData) => {
              if (error) {
                res.status(500).send("Internal Server Error.");
              } else {
                walletData.transferHistory = transferHistoryData.rows;

                // Backing History
                const backingHistoryQuery = `SELECT amount * -1 as amount, transaction_date, project_name, 'Backing' as type FROM Transactions NATURAL JOIN BackingFunds WHERE email = '${email}';`;
                // console.log("Query: " + backingHistoryQuery);
                pool.query(backingHistoryQuery, (error, backingHistoryData) => {
                  if (error) {
                    res.status(500).send("Internal Server Error.");
                  } else {
                    walletData.backingHistory = backingHistoryData.rows;

                    // Send completely constructed data.
                    res.send(walletData);
                  }
                });
              }
            });
          }
        });
      }
    }
  });
});

router.post("/topup", function(req, res, next) {
  var email = req.body.email;
  var currentAmount = parseFloat(req.body.currentAmount);
  var topupAmount = parseFloat(req.body.topupAmount);
  var newAmount = currentAmount + topupAmount;

  const updateQuery = `CALL topup_wallet('${email}', ${newAmount}, ${topupAmount});`;

  pool.query(updateQuery, (error, updateQueryData) => {
    if (error) {
      res.status(500).send("Internal Server Error.");
    } else {
      res.redirect(307, "/wallet/retrieve");
    }
  });
});

router.post("/transfer", function(req, res, next) {
  var senderEmail = req.body.email;
  var receiverEmail = req.body.receiverEmail;
  var transferAmount = parseFloat(req.body.transferAmount);

  const updateQuery = `CALL transfer_from_wallet('${senderEmail}', '${receiverEmail}', ${transferAmount});`;

  pool.query(updateQuery, (error, updateQueryData) => {
    if (error) {
      res.status(500).send("Internal Server Error.");
    } else {
      res.redirect(307, "/wallet/retrieve");
    }
  });
});

router.get("/", function(req, res, next) {
  res.send("Unauthorized");
});

module.exports = router;
