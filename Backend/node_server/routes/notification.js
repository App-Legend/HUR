const router = require('express').Router();
const { verifyToken } = require('../middleware/auth');
const { getNotifications, getUnreadCount, markAllRead } = require('../controllers/notificationController');

router.get('/', verifyToken, getNotifications);
router.get('/unread-count', verifyToken, getUnreadCount);
router.post('/read-all', verifyToken, markAllRead);

module.exports = router;
