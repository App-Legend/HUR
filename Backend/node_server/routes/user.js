const express = require("express");
const { verifyToken, optionalAuth } = require("../middleware/auth");
const { searchUsers, getProfile, updateProfile } = require("../controllers/userController");
const { blockUser, unblockUser, listBlocked } = require("../controllers/moderationController");

const router = express.Router();

router.get("/search/users", searchUsers);
router.get("/me/blocks", verifyToken, listBlocked);
router.get("/:id", optionalAuth, getProfile);
router.put("/:id", verifyToken, updateProfile);
router.post("/:id/block", verifyToken, blockUser);
router.delete("/:id/block", verifyToken, unblockUser);

module.exports = router;
