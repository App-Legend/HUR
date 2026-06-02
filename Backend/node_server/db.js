const mysql = require('mysql2');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '1234',
  database: 'hur_test',
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool.promise();
