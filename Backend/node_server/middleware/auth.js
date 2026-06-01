const jwt = require('jsonwebtoken');
const pool = require('../db');

// 환경변수에서 JWT 시크릿 키 가져오기
const JWT_SECRET = process.env.JWT_SECRET || 'your-default-secret-key-please-change-this';

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

module.exports = { authenticateToken };
