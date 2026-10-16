const jwt = require('jsonwebtoken');
const pool = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'secretKey';

const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ message: 'Access token required' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);

    const { rows } = await pool.query(
      'SELECT user_id AS id, email, nickname, name FROM users WHERE user_id = $1',
      [decoded.id]
    );
    const user = rows[0];

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

// 로그인했으면 req.user를 채우고, 아니거나 토큰이 잘못돼도 에러 없이 그냥 통과시킨다. (비로그인도 볼 수 있는 API용)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return next();

    const decoded = jwt.verify(token, JWT_SECRET);
    const { rows } = await pool.query(
      'SELECT user_id AS id, email, nickname, name FROM users WHERE user_id = $1',
      [decoded.id]
    );
    if (rows[0]) req.user = rows[0];
  } catch (err) {
    // 토큰이 만료/잘못됐으면 비로그인으로 취급
  }
  next();
};

module.exports = { verifyToken, optionalAuth };
