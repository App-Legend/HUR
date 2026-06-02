const express = require("express");
const pool = require("../db");

const router = express.Router({ mergeParams: true });

// 팔로우
router.post("/", async (req, res) => {
    try {
        const { id } = req.params;         // 팔로우 당하는 사람
        const { follower_id } = req.body;  // 팔로우 하는 사람

        if (!follower_id) {
            return res.status(400).json({ message: "follower_id가 필요합니다" });
        }
        if (Number(id) === Number(follower_id)) {
            return res.status(400).json({ message: "자기 자신을 팔로우할 수 없습니다" });
        }

        await pool.query(
            "INSERT INTO follow (follower_id, following_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
            [follower_id, id]
        );

        res.json({ message: "팔로우 성공" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 언팔로우
router.delete("/", async (req, res) => {
    try {
        const { id } = req.params;
        const { follower_id } = req.body;

        if (!follower_id) {
            return res.status(400).json({ message: "follower_id가 필요합니다" });
        }

        await pool.query(
            "DELETE FROM follow WHERE follower_id=$1 AND following_id=$2",
            [follower_id, id]
        );

        res.json({ message: "언팔로우 성공" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 팔로우 여부 확인
router.get("/check", async (req, res) => {
    try {
        const { id } = req.params;
        const { me } = req.query;
        if (!me) return res.json({ is_following: false });

        const result = await pool.query(
            "SELECT 1 FROM follow WHERE follower_id=$1 AND following_id=$2",
            [me, id]
        );
        res.json({ is_following: result.rows.length > 0 });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 팔로워 목록
router.get("/followers", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `SELECT u.id, u.nickname, u.username, u.profile_image
             FROM follow f JOIN "user" u ON f.follower_id = u.id
             WHERE f.following_id = $1`,
            [id]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 팔로잉 목록
router.get("/following", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `SELECT u.id, u.nickname, u.username, u.profile_image
             FROM follow f JOIN "user" u ON f.following_id = u.id
             WHERE f.follower_id = $1`,
            [id]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
