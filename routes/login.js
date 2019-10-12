var express = require('express');
var router = express.Router();

router.post('/', function(req, res, next) {
    var username = req.body.username;
    var password = req.body.password;

    console.log(`Got ${username} and ${password}`);

    res.send('You are now logged in.');
});

router.get('/', function(req, res, next) {
    res.send("hi");
})

module.exports = router;
