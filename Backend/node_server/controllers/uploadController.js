const multer = require('multer');
const { s3Storage } = require('../s3');

// 게시물 이미지
const upload = multer({
    storage: s3Storage('posts'),
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowed = ["image/jpeg", "image/png", "image/webp"];
        allowed.includes(file.mimetype) ? cb(null, true) : cb(new Error("이미지 파일만 업로드 가능합니다"));
    },
});

const uploadImage = (req, res) => {
    if (!req.file) return res.status(400).json({ message: "파일이 없습니다" });
    res.json({ url: req.file.location });
};

// 프로필/배경 이미지
const uploadProfile = multer({
    storage: s3Storage('profiles'),
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowed = ["image/jpeg", "image/png", "image/webp"];
        allowed.includes(file.mimetype) ? cb(null, true) : cb(new Error("이미지 파일만 업로드 가능합니다"));
    },
});

const uploadProfileImage = (req, res) => {
    if (!req.file) return res.status(400).json({ message: "파일이 없습니다" });
    res.json({ url: req.file.location });
};

module.exports = { upload, uploadImage, uploadProfile, uploadProfileImage };
