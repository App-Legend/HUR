const pool = require('../db');

const searchUsers = async (req, res) => {
    try {
        const { q, me } = req.query;
        if (!q || q.trim() === "") return res.json([]);

        const [rows] = await pool.query(
            `SELECT u.user_id AS id, u.nickname, u.username, u.profile_image,
                    EXISTS(
                        SELECT 1 FROM follow
                        WHERE follower_id = ? AND following_id = u.user_id
                    ) AS is_following
             FROM users u
             WHERE (u.username LIKE ? OR u.nickname LIKE ?)
               AND u.user_id != ?
             LIMIT 20`,
            [me ?? 0, `%${q}%`, `%${q}%`, me ?? 0]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getProfile = async (req, res) => {
    try {
        const { id } = req.params;

        const [rows] = await pool.query(
            `SELECT u.user_id AS id, u.email, u.name, u.nickname, u.username, u.gender, u.birth_date,
                    u.bio, u.profile_image, u.background_image, u.aesthetic_tag,
                    COUNT(DISTINCT f_in.follower_id)   AS follower_count,
                    COUNT(DISTINCT f_out.following_id) AS following_count
             FROM users u
             LEFT JOIN follow f_in  ON f_in.following_id = u.user_id
             LEFT JOIN follow f_out ON f_out.follower_id  = u.user_id
             WHERE u.user_id = ?
             GROUP BY u.user_id`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ message: "유저를 찾을 수 없습니다" });
        }
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const updateProfile = async (req, res) => {
    try {
        const { id } = req.params;
        const { nickname, username, bio, profile_image, background_image, aesthetic_tag } = req.body;

        const [existing] = await pool.query('SELECT user_id FROM users WHERE user_id=?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ message: "유저를 찾을 수 없습니다" });
        }

        if (nickname) {
            const [dup] = await pool.query('SELECT user_id FROM users WHERE nickname=? AND user_id!=?', [nickname, id]);
            if (dup.length > 0) return res.status(409).json({ message: "이미 사용 중인 닉네임입니다" });
        }

        if (username) {
            const [dup] = await pool.query('SELECT user_id FROM users WHERE username=? AND user_id!=?', [username, id]);
            if (dup.length > 0) return res.status(409).json({ message: "이미 사용 중인 아이디입니다" });
        }

        await pool.query(
            `UPDATE users
             SET nickname         = COALESCE(?, nickname),
                 username         = COALESCE(?, username),
                 bio              = COALESCE(?, bio),
                 profile_image    = COALESCE(?, profile_image),
                 background_image = COALESCE(?, background_image),
                 aesthetic_tag    = COALESCE(?, aesthetic_tag)
             WHERE user_id=?`,
            [nickname, username, bio, profile_image, background_image, aesthetic_tag, id]
        );

        const [updated] = await pool.query(
            'SELECT user_id AS id, email, name, nickname, username, bio, profile_image, background_image, aesthetic_tag FROM users WHERE user_id=?',
            [id]
        );

        res.json({ message: "프로필이 수정되었습니다", user: updated[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { searchUsers, getProfile, updateProfile };
