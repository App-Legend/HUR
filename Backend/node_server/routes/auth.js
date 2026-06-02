const express = require('express');
const { login, signup, logout } = require('../controllers/authController');
const { validateRegister } = require('../middleware/validation');

const router = express.Router();

router.post('/login', login);
router.post('/signup', validateRegister, signup);
router.post('/logout', logout);

module.exports = router;
