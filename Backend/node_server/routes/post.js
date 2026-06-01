const router = require('express').Router();
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const { verifyToken } = require('../middleware/auth');
const { createPost, getFeed } = require('../controllers/postController');

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
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  },
});

router.get('/feed', getFeed);
router.post('/', verifyToken, upload.single('image'), createPost);

module.exports = router;
