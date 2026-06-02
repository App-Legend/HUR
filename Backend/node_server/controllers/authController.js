const pool = require('../db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secretKey';

// 로그인
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const [rows] = await pool.query('SELECT * FROM users WHERE email=?', [email]);
        if (rows.length === 0) {
            return res.status(401).json({ message: '가입되지 않은 이메일입니다' });
        }

        const user = rows[0];
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ message: '비밀번호가 맞지 않습니다' });
        }

        const token = jwt.sign(
            { id: user.user_id, email: user.email },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.json({
            message: '로그인 성공',
            token,
            user: {
                id: user.user_id,
                email: user.email,
                name: user.name,
                nickname: user.nickname,
            },
        });
    } catch (err) {
        console.error('[login error]', err);
        res.status(500).json({ error: err.message });
    }
};

// 회원가입
const signup = async (req, res) => {
    try {
        const { name, nickname, gender, birth, email, password } = req.body;

        if (!name || !nickname || !gender || !birth || !email || !password) {
            return res.status(400).json({ message: '모든 필드를 입력해주세요' });
        }

        const [existingEmail] = await pool.query('SELECT user_id FROM users WHERE email=?', [email]);
        if (existingEmail.length > 0) {
            return res.status(409).json({ message: '이미 사용 중인 이메일입니다' });
        }

        const [existingNick] = await pool.query('SELECT user_id FROM users WHERE nickname=?', [nickname]);
        if (existingNick.length > 0) {
            return res.status(409).json({ message: '이미 사용 중인 닉네임입니다' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            'INSERT INTO users (name, nickname, gender, birth_date, email, password_hash) VALUES (?, ?, ?, ?, ?, ?)',
            [name, nickname, gender, birth, email, hashedPassword]
        );

        const [newUserRows] = await pool.query(
            'SELECT user_id AS id, email, name, nickname FROM users WHERE user_id=?',
            [result.insertId]
        );
        const newUser = newUserRows[0];

        const token = jwt.sign(
            { id: newUser.id, email: newUser.email },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.status(201).json({
            message: '회원가입 성공',
            token,
            user: { id: newUser.id, email: newUser.email, name: newUser.name, nickname: newUser.nickname }
        });
    } catch (err) {
        console.error('[signup error]', err);
        res.status(500).json({ error: err.message });
    }
};

// 로그아웃
const logout = (req, res) => {
    res.json({ message: '로그아웃 성공' });
};

module.exports = { login, signup, logout };
