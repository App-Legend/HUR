const router = require('express').Router();
const { login, signup } = require('../controllers/authController');
const { validateRegister } = require('../middleware/validation');

router.post('/login', login);
router.post('/signup', validateRegister, signup);

module.exports = router;
