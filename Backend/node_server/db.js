const { Pool } = require('pg');

const pool = new Pool({
  host: "localhost",
  user: 'credit',
  password: '',
  database: 'postgres',
  port: 5432,
});

module.exports = pool;