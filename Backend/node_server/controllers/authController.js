const pool = require('../db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');

// 환경변수에서 JWT 시크릿 키 가져오기
const JWT_SECRET = process.env.JWT_SECRET || 'your-default-secret-key-please-change-this';

// 유효성 검사 미들웨어
const validateRegister = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/),
  body('nickname').isLength({ min: 2, max: 30 }),
  body('name').isLength({ min: 2, max: 50 }),
  body('gender').isIn(['male', 'female', 'other']),
  body('birth').isISO8601().toDate()
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

// 로그인 기능
const login = async (req, res) => {
  try {
    // 유효성 검사
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      });
    }

    const { email, password } = req.body;

    // 이메일로 사용자 조회
    const result = await pool.query(
      'SELECT user_id, email, password_hash, nickname, name, gender, birth FROM users WHERE email=$1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ 
        message: 'Invalid credentials' 
      });
    }

    const user = result.rows[0];

    // 비밀번호 비교
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ 
        message: 'Invalid credentials' 
      });
    }

    // JWT 토큰 생성
    const token = jwt.sign(
      { 
        user_id: user.user_id, 
        email: user.email,
        nickname: user.nickname,
        name: user.name
      },
      JWT_SECRET,
      { 
        expiresIn: '2h'
      }
    );

    // 성공 응답
    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.user_id,
        email: user.email,
        name: user.name,
        nickname: user.nickname,
        gender: user.gender,
        birth: user.birth
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ 
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

// 회원가입 기능
const signup = async (req, res) => {
  try {
    // 유효성 검사
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      });
    }

    const { email, password, nickname, name, gender, birth } = req.body;

    // 이메일 중복 체크
    const existingUser = await pool.query(
      'SELECT user_id FROM users WHERE email=$1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ 
        message: 'Email already registered' 
      });
    }

    // 비밀번호 강도 검사
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({ 
        message: 'Password must contain at least one uppercase letter, lowercase letter, number, and special character' 
      });
    }

    // 비밀번호 해시화
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // 새로운 사용자 DB에 저장 (필드 순서대로 저장)
    const newUser = await pool.query(
      `INSERT INTO users 
       (name, nickname, gender, birth, email, password_hash, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW()) 
       RETURNING user_id, email, nickname, name, gender, birth`,
      [name, nickname, gender, birth, email, hashedPassword]
    );

    // JWT 토큰 생성
    const token = jwt.sign(
      { 
        user_id: newUser.rows[0].user_id, 
        email: newUser.rows[0].email,
        nickname: newUser.rows[0].nickname,
        name: newUser.rows[0].name
      },
      JWT_SECRET,
      { 
        expiresIn: '24h',
        issuer: 'your-app-name',
        audience: 'your-app-users'
      }
    );

    // 성공 응답
    res.status(201).json({
      message: 'Registration successful',
      token,
      user: {
        id: newUser.rows[0].user_id,
        email: newUser.rows[0].email,
        name: newUser.rows[0].name,
        nickname: newUser.rows[0].nickname,
        gender: newUser.rows[0].gender,
        birth: newUser.rows[0].birth
      },
    });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ 
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

// 토큰 검증 미들웨어
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    // JWT 토큰 검증
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // 사용자 정보 조회
    const userResult = await pool.query(
      'SELECT user_id, email, nickname, name FROM users WHERE user_id=$1',
      [decoded.user_id]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    req.user = userResult.rows[0];
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired' });
    }
    return res.status(403).json({ message: 'Invalid token' });
  }
};

module.exports = { 
  login,
  signup,
  authenticateToken
};
