const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("../db");

const router = express.Router();

router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;
        const result = await pool.query('SELECT * FROM "user" WHERE email=$1', [email]);

        if (result.rows.length === 0) {
            return res.status(401).json({ message: "존재하지 않는 이메일입니다" });
        }

        const user = result.rows[0];
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({ message: "비밀번호가 올바르지 않습니다" });
        }

        const token = jwt.sign(
            { id: user.id, email: user.email },
            "secretKey",
            { expiresIn: "1h" }
        );

        res.json({
            message: "로그인 성공",
            token,
            user: { id: user.id, email: user.email, name: user.name }
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.post("/signup", async (req, res) => {
    try {
        const { name, nickname, username, gender, birth_date, email, password } = req.body;

        if (!name || !nickname || !username || !gender || !birth_date || !email || !password) {
            return res.status(400).json({ message: "모든 필드를 입력해주세요" });
        }

        const existingEmail = await pool.query('SELECT id FROM "user" WHERE email=$1', [email]);
        if (existingEmail.rows.length > 0) {
            return res.status(409).json({ message: "이미 사용 중인 이메일입니다" });
        }

        const existingNick = await pool.query('SELECT id FROM "user" WHERE nickname=$1', [nickname]);
        if (existingNick.rows.length > 0) {
            return res.status(409).json({ message: "이미 사용 중인 닉네임입니다" });
        }

        const existingUsername = await pool.query('SELECT id FROM "user" WHERE username=$1', [username]);
        if (existingUsername.rows.length > 0) {
            return res.status(409).json({ message: "이미 사용 중인 아이디입니다" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const result = await pool.query(
            'INSERT INTO "user" (name, nickname, username, gender, birth_date, email, password) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, email, name, nickname, username',
            [name, nickname, username, gender, birth_date, email, hashedPassword]
        );

        const newUser = result.rows[0];
        const token = jwt.sign(
            { id: newUser.id, email: newUser.email },
            "secretKey",
            { expiresIn: "1h" }
        );

        res.status(201).json({
            message: "회원가입 성공",
            token,
            user: { id: newUser.id, email: newUser.email, name: newUser.name, nickname: newUser.nickname }
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.post("/logout", (req, res) => {
    res.json({ message: "로그아웃 성공" });
});

module.exports = router;
