var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'password',
  port: 5432,
})

var sql_query = "SELECT * FROM "

router.get('/', function(req, res, next) {
    // pool.query(sql_query, (err, data) => {
    //     res.send("Hi");
    // })
    res.send([
        { age: 40, first_name: 'Dickerson', last_name: 'Macdonald' },
        { age: 21, first_name: 'Larsen', last_name: 'Shaw' },
        { age: 89, first_name: 'Geneva', last_name: 'Wilson' },
        { age: 38, first_name: 'Jami', last_name: 'Carney' }
      ]);
})

module.exports = router;





// /* SQL Query */
// var sql_query = 'SELECT * FROM student_info';

// router.get('/', function(req, res, next) {
// 	pool.query(sql_query, (err, data) => {
// 		res.render('select', { title: 'Database Connect', data: data.rows });
// 	});
// });

// module.exports = router;
