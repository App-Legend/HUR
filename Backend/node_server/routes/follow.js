const express = require("express");
const { followUser, unfollowUser, checkFollow, getFollowers, getFollowing } = require("../controllers/followController");

const router = express.Router({ mergeParams: true });

router.post("/", followUser);
router.delete("/", unfollowUser);
router.get("/check", checkFollow);
router.get("/followers", getFollowers);
router.get("/following", getFollowing);

module.exports = router;
