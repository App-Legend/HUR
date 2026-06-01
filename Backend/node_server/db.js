const { Pool } = require('pg');

const pool = new Pool({
  host: 'http://172.16.13.141',
  user: 'credit',
  password: '',
  database: 'users',
  port: 5432,
});

module.exports = pool;