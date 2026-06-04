const express = require("express");
const { searchUsers, getProfile, updateProfile } = require("../controllers/userController");

const router = express.Router();

router.get("/search/users", searchUsers);
router.get("/:id", getProfile);
router.put("/:id", updateProfile);

module.exports = router;
