const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { logSearch, getRecent, deleteRecent, clearRecent, getTrending } = require('../controllers/searchController');

const router = express.Router();

router.get('/trending', getTrending);
router.get('/recent', verifyToken, getRecent);
router.post('/log', verifyToken, logSearch);
router.delete('/recent', verifyToken, clearRecent);
router.delete('/recent/:keyword', verifyToken, deleteRecent);

module.exports = router;
