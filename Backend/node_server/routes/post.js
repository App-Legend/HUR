const router = require('express').Router();
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const { verifyToken } = require('../middleware/auth');
const { createPost, getFeed, getUserPosts, getPostDetail, updateScore, toggleLike, getLikeStatus, getComments, addComment, deleteComment } = require('../controllers/postController');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '../images/posts')),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    const allowedExts = ['.jpg', '.jpeg', '.png', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, allowedExts.includes(ext) || file.mimetype.startsWith('image/'));
  },
});

router.get('/feed', getFeed);
router.get('/user/:userId', getUserPosts);
router.get('/:id', getPostDetail);
router.post('/', verifyToken, upload.single('image'), createPost);
router.post('/:id/score', updateScore);
router.post('/:id/like', toggleLike);
router.get('/:id/like', getLikeStatus);
router.get('/:id/comments', getComments);
router.post('/:id/comments', addComment);
router.delete('/:id/comments/:commentId', deleteComment);

module.exports = router;
