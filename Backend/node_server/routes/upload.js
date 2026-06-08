const express = require("express");
const { upload, uploadImage, uploadProfile, uploadProfileImage } = require("../controllers/uploadController");

const router = express.Router();

router.post("/", upload.single("image"), uploadImage);
router.post("/profile", uploadProfile.single("image"), uploadProfileImage);

module.exports = router;
