const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 게시물 이미지
const uploadDir = path.join(__dirname, '../images/posts');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        cb(null, `${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`);
    },
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowed = ["image/jpeg", "image/png", "image/webp"];
        allowed.includes(file.mimetype) ? cb(null, true) : cb(new Error("이미지 파일만 업로드 가능합니다"));
    },
});

const uploadImage = (req, res) => {
    if (!req.file) return res.status(400).json({ message: "파일이 없습니다" });
    res.json({ url: `/uploads/${req.file.filename}` });
};

// 프로필/배경 이미지
const profileUploadDir = path.join(__dirname, '../images/profiles');
if (!fs.existsSync(profileUploadDir)) fs.mkdirSync(profileUploadDir, { recursive: true });

const profileStorage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, profileUploadDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        cb(null, `${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`);
    },
});

const uploadProfile = multer({
    storage: profileStorage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowed = ["image/jpeg", "image/png", "image/webp"];
        allowed.includes(file.mimetype) ? cb(null, true) : cb(new Error("이미지 파일만 업로드 가능합니다"));
    },
});

const uploadProfileImage = (req, res) => {
    if (!req.file) return res.status(400).json({ message: "파일이 없습니다" });
    res.json({ url: `/profile-images/${req.file.filename}` });
};

module.exports = { upload, uploadImage, uploadProfile, uploadProfileImage };
