const { Pool } = require("pg");

const pool = new Pool({
  connectionString:
    "postgresql://postgres:OpQSogYJnEZloRzCAmBcyjSiIWvctkMD@tramway.proxy.rlwy.net:52823/railway",
  ssl: {
    rejectUnauthorized: false,
  },
});

module.exports = pool;