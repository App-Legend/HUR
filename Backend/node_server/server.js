const express = require("express"); // 웹 서버 가동하려면 가져와야함
const cors = require("cors"); // 다른 주소에 넘어는 값 처리용
const pool = require("./db");
const bcrypt = require("bcrypt");

const app = express();
app.use(cors());
app.use(express.json());

const jwt = require("jsonwebtoken");

app.post("/login", async  (req, res) => {
    try {
    const { email, password } = req.body;
    console.log(email)
    const result = await pool.query(
        'SELECT * FROM "user" WHERE email=$1',
        [email]
    );

    console.log(result.rows)

    if (result.rows.length === 0) {
      return res.status(401).json({ message: "user not found" });
    }

    const user = result.rows[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "password incorrect" });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      "secretKey",
      { expiresIn: "1h" }
    );

    res.json({
      message: "login success",
      token: token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = 3000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

