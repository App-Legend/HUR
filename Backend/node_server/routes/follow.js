const express = require("express");
const { verifyToken } = require("../middleware/auth");
const { followUser, unfollowUser, checkFollow, getFollowers, getFollowing } = require("../controllers/followController");

const router = express.Router({ mergeParams: true });

router.post("/", verifyToken, followUser);
router.delete("/", verifyToken, unfollowUser);
router.get("/check", checkFollow);
router.get("/followers", getFollowers);
router.get("/following", getFollowing);

module.exports = router;
