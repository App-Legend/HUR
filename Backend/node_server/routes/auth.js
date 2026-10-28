const express = require('express');
const { login, signup, logout, changePassword, resetPassword, deleteAccount } = require('../controllers/authController');
const { validateRegister } = require('../middleware/validation');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

router.post('/login', login);
router.post('/signup', validateRegister, signup);
router.post('/logout', logout);
router.put('/password', verifyToken, changePassword);
router.post('/reset-password', resetPassword);
router.delete('/account', verifyToken, deleteAccount);

module.exports = router;
