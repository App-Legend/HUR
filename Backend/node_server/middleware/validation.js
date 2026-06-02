const { body, validationResult } = require('express-validator');

// 유효성 검사 미들웨어
const validateRegister = [
  body('name').isLength({ min: 2, max: 50 }),
  body('nickname').isLength({ min: 2, max: 30 }),
  body('gender').isIn(['male', 'female', 'other']),
  body('birth').isISO8601().toDate(),
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/),
  body('passwordConfirm').custom((value, { req }) => {
    if (value !== req.body.password) {
      throw new Error('비밀번호가 일치하지 않습니다.');
    }
    return true;
  }),
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

module.exports = {
  validateRegister,
  validateLogin
};