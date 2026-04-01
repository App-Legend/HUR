const pool = require("./db");

async function testDB() {
  try {
    const result = await pool.query("SELECT NOW()");
    console.log("DB 연결 성공");
    console.log(result.rows);
  } catch (err) {
    console.error("DB 연결 실패");
    console.error(err);
  }
}

testDB();