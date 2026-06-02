const { Pool } = require("pg");
//로컬 db로 테스트해보는중
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "1234",
  port: 5432,

  keepAlive: true,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on("error", (err) => {
  console.error("DB connection error:", err.message);
});

module.exports = pool;