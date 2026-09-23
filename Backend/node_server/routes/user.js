const express = require("express");
const { verifyToken } = require("../middleware/auth");
const { searchUsers, getProfile, updateProfile } = require("../controllers/userController");

const router = express.Router();

router.get("/search/users", searchUsers);
router.get("/:id", getProfile);
router.put("/:id", verifyToken, updateProfile);

module.exports = router;
