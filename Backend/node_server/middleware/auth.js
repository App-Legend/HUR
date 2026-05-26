const jwt = require('jsonwebtoken');

const JWT_SECRET = 'secretKey'; // TODO: 환경변수로 이동

const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: '토큰이 없습니다.' });
  }

  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
  }
};

module.exports = { verifyToken };
