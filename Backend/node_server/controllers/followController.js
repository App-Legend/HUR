const pool = require('../db');

// 팔로우 API
const followUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { follower_id } = req.body;

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
};

// 언팔 API
const unfollowUser = async (req, res) => {
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
};

// 팔로우 여부 체크 API
const checkFollow = async (req, res) => {
    try {
        const { id } = req.params;
        const { me } = req.query;
        if (!me) return res.json({ is_following: false });

        const { rows } = await pool.query(
            "SELECT 1 FROM follow WHERE follower_id=$1 AND following_id=$2",
            [me, id]
        );
        res.json({ is_following: rows.length > 0 });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 팔로워 목록 API
const getFollowers = async (req, res) => {
    try {
        const { id } = req.params;
        const { rows } = await pool.query(
            `SELECT u.user_id AS id, u.nickname, u.profile_image
             FROM follow f JOIN users u ON f.follower_id = u.user_id
             WHERE f.following_id = $1`,
            [id]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 팔로잉 목록 API
const getFollowing = async (req, res) => {
    try {
        const { id } = req.params;
        const { rows } = await pool.query(
            `SELECT u.user_id AS id, u.nickname, u.profile_image
             FROM follow f JOIN users u ON f.following_id = u.user_id
             WHERE f.follower_id = $1`,
            [id]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { followUser, unfollowUser, checkFollow, getFollowers, getFollowing };
