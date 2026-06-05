const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  user:     process.env.DB_USER     || 'app_legend',
  password: process.env.DB_PASSWORD || '1234',
  database: process.env.DB_NAME     || 'Hur',
  port:     5432,
});

module.exports = pool;
