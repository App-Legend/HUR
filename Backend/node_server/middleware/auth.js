const jwt = require('jsonwebtoken');
const pool = require('../db');

// 환경변수에서 JWT 시크릿 키 가져오기
const JWT_SECRET = process.env.JWT_SECRET || 'secretKey';

// 토큰 검증 미들웨어
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);

    const [[user]] = await pool.query(
      'SELECT user_id AS id, email, nickname, name FROM users WHERE user_id = ?',
      [decoded.id]
    );

    if (!user) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    req.user = user;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired' });
    }
    return res.status(403).json({ message: 'Invalid token' });
  }
};

module.exports = { verifyToken };
