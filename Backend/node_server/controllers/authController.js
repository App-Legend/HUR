const pool = require('../db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secretKey';

// 로그인
const login = async (req, res) => {
    try {
        const { email, password, keep_logged_in } = req.body;

        const { rows } = await pool.query('SELECT * FROM users WHERE email=$1', [email]);
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
            { expiresIn: keep_logged_in ? '30d' : '1h' }
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

        const { rows: existingEmail } = await pool.query('SELECT user_id FROM users WHERE email=$1', [email]);
        if (existingEmail.length > 0) {
            return res.status(409).json({ message: '이미 사용 중인 이메일입니다' });
        }

        const { rows: existingNick } = await pool.query('SELECT user_id FROM users WHERE nickname=$1', [nickname]);
        if (existingNick.length > 0) {
            return res.status(409).json({ message: '이미 사용 중인 닉네임입니다' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const { rows: inserted } = await pool.query(
            'INSERT INTO users (name, nickname, gender, birth_date, email, password_hash) VALUES ($1, $2, $3, $4, $5, $6) RETURNING user_id',
            [name, nickname, gender, birth, email, hashedPassword]
        );
        const newUserId = inserted[0].user_id;

        const { rows: newUserRows } = await pool.query(
            'SELECT user_id AS id, email, name, nickname FROM users WHERE user_id=$1',
            [newUserId]
        );
        const newUser = newUserRows[0];

        const token = jwt.sign(
            { id: newUser.id, email: newUser.email },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        const initScores = [
            ...['봄 웜톤', '가을 웜톤', '겨울 쿨톤', '여름쿨톤', '잘 모르겠음'].map(v => [newUserId, 'personal_color', v, 0]),
            ...['청순', '시크', '큐티', '섹시', '차분'].map(v => [newUserId, 'mood', v, 0]),
            ...['13호 ~ 17호', '21호', '23호', '25호', '27호'].map(v => [newUserId, 'skin_tone', v, 0]),
        ];
        const scorePlaceholders = initScores.map((_, i) => `($${i*4+1}, $${i*4+2}, $${i*4+3}, $${i*4+4})`).join(', ');
        await pool.query(
            `INSERT INTO user_category_score (user_id, category_type, category_value, score) VALUES ${scorePlaceholders} ON CONFLICT DO NOTHING`,
            initScores.flat()
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

// 가입 때(middleware/validation.js)와 같은 규칙: 8자 이상 + 영문 소문자 + 숫자 + 특수문자(@$!%*?&)
const PASSWORD_RULE_MESSAGE = '비밀번호는 8자 이상이고 영문 소문자, 숫자, 특수문자(@$!%*?&)를 포함해야 해요';
const isValidPassword = (pw) =>
    typeof pw === 'string' && pw.length >= 8 && /^(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])/.test(pw);

// 비밀번호 변경 (로그인 상태에서 현재 비밀번호 확인)
const changePassword = async (req, res) => {
    try {
        const { current_password, new_password } = req.body;
        if (!current_password || !new_password) {
            return res.status(400).json({ message: '현재 비밀번호와 새 비밀번호를 입력해주세요' });
        }
        if (!isValidPassword(new_password)) {
            return res.status(400).json({ message: PASSWORD_RULE_MESSAGE });
        }

        const { rows: [user] } = await pool.query('SELECT password_hash FROM users WHERE user_id = $1', [req.user.id]);
        if (!user || !(await bcrypt.compare(current_password, user.password_hash))) {
            // 401은 앱에서 '로그인 만료'로 처리하므로 비밀번호 불일치는 400으로 내려준다.
            return res.status(400).json({ message: '현재 비밀번호가 맞지 않아요' });
        }
        if (current_password === new_password) {
            return res.status(400).json({ message: '현재 비밀번호와 다른 비밀번호를 입력해주세요' });
        }

        const hashed = await bcrypt.hash(new_password, 10);
        await pool.query('UPDATE users SET password_hash = $1 WHERE user_id = $2', [hashed, req.user.id]);
        res.json({ message: '비밀번호를 변경했어요' });
    } catch (err) {
        console.error('[changePassword error]', err);
        res.status(500).json({ error: err.message });
    }
};

// 비밀번호 재설정 (시연용): 이메일 발송 환경이 없어서 가입한 이메일과 이름이 모두 맞으면 새 비밀번호로 바꿔준다.
// 실서비스에서는 이메일/문자 인증으로 본인 확인을 해야 한다.
const resetPassword = async (req, res) => {
    try {
        const { email, name, new_password } = req.body;
        if (!email || !name || !new_password) {
            return res.status(400).json({ message: '이메일, 이름, 새 비밀번호를 모두 입력해주세요' });
        }
        if (!isValidPassword(new_password)) {
            return res.status(400).json({ message: PASSWORD_RULE_MESSAGE });
        }

        const { rows: [user] } = await pool.query(
            'SELECT user_id FROM users WHERE LOWER(email) = LOWER($1) AND name = $2',
            [email.trim(), name.trim()]
        );
        if (!user) {
            return res.status(404).json({ message: '이메일과 이름이 일치하는 계정이 없어요' });
        }

        const hashed = await bcrypt.hash(new_password, 10);
        await pool.query('UPDATE users SET password_hash = $1 WHERE user_id = $2', [hashed, user.user_id]);
        res.json({ message: '비밀번호를 재설정했어요. 새 비밀번호로 로그인해주세요' });
    } catch (err) {
        console.error('[resetPassword error]', err);
        res.status(500).json({ error: err.message });
    }
};

// 회원탈퇴: 비밀번호를 확인한 뒤 계정을 지운다. 게시물/댓글/좋아요/팔로우/후기 등은 FK CASCADE로 함께 지워진다.
// S3에 올라간 사진 파일은 지우지 않는다.
const deleteAccount = async (req, res) => {
    try {
        const { password } = req.body;
        if (!password) {
            return res.status(400).json({ message: '비밀번호를 입력해주세요' });
        }

        const { rows: [user] } = await pool.query('SELECT password_hash FROM users WHERE user_id = $1', [req.user.id]);
        if (!user || !(await bcrypt.compare(password, user.password_hash))) {
            return res.status(400).json({ message: '비밀번호가 맞지 않아요' });
        }

        await pool.query('DELETE FROM users WHERE user_id = $1', [req.user.id]);
        res.json({ message: '탈퇴가 완료됐어요' });
    } catch (err) {
        console.error('[deleteAccount error]', err);
        res.status(500).json({ error: err.message });
    }
};

module.exports = { login, signup, logout, changePassword, resetPassword, deleteAccount };
