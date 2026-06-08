const pool = require('../db');
const fs = require('fs');
const path = require('path');

const searchUsers = async (req, res) => {
    try {
        const { q, me } = req.query;
        if (!q || q.trim() === "") return res.json([]);

        const { rows } = await pool.query(
            `SELECT u.user_id AS id, u.nickname, u.profile_image,
                    EXISTS(
                        SELECT 1 FROM follow
                        WHERE follower_id = $1 AND following_id = u.user_id
                    ) AS is_following
             FROM users u
             WHERE u.nickname ILIKE $2
               AND u.user_id != $3
             LIMIT 20`,
            [me ?? 0, `%${q}%`, me ?? 0]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getProfile = async (req, res) => {
    try {
        const { id } = req.params;

        const { rows } = await pool.query(
            `SELECT u.user_id AS id, u.email, u.name, u.nickname, u.gender, u.birth_date,
                    u.bio, u.profile_image, u.background_image, u.aesthetic_tag,
                    u.personal_color, u.skin_tone,
                    COUNT(DISTINCT f_in.follower_id)   AS follower_count,
                    COUNT(DISTINCT f_out.following_id) AS following_count
             FROM users u
             LEFT JOIN follow f_in  ON f_in.following_id = u.user_id
             LEFT JOIN follow f_out ON f_out.follower_id  = u.user_id
             WHERE u.user_id = $1
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
        const { nickname, bio, profile_image, background_image, aesthetic_tag, personal_color, skin_tone } = req.body;

        const { rows: existing } = await pool.query('SELECT user_id FROM users WHERE user_id=$1', [id]);
        if (existing.length === 0) {
            return res.status(404).json({ message: "유저를 찾을 수 없습니다" });
        }

        if (nickname) {
            const { rows: dup } = await pool.query('SELECT user_id FROM users WHERE nickname=$1 AND user_id!=$2', [nickname, id]);
            if (dup.length > 0) return res.status(409).json({ message: "이미 사용 중인 닉네임입니다" });
        }

        const { rows: current } = await pool.query(
            'SELECT profile_image, background_image FROM users WHERE user_id=$1', [id]
        );
        const deleteProfileFile = (filePath) => {
            if (!filePath || filePath.startsWith('http')) return;
            const filename = filePath.split('/').pop();
            const fullPath = path.join(__dirname, '../images/profiles', filename);
            try { if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath); } catch (_) {}
        };
        if (profile_image && profile_image !== current[0]?.profile_image) {
            deleteProfileFile(current[0]?.profile_image);
        }
        if (background_image && background_image !== current[0]?.background_image) {
            deleteProfileFile(current[0]?.background_image);
        }

        await pool.query(
            `UPDATE users
             SET nickname         = COALESCE($1, nickname),
                 bio              = COALESCE($2, bio),
                 profile_image    = COALESCE($3, profile_image),
                 background_image = COALESCE($4, background_image),
                 aesthetic_tag    = COALESCE($5, aesthetic_tag),
                 personal_color   = COALESCE($6, personal_color),
                 skin_tone        = COALESCE($7, skin_tone)
             WHERE user_id=$8`,
            [nickname, bio, profile_image, background_image, aesthetic_tag, personal_color, skin_tone, id]
        );

        if (personal_color) {
            await pool.query(
                `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                 VALUES ($1, 'personal_color', $2, 5)
                 ON CONFLICT (user_id, category_type, category_value) DO NOTHING`,
                [id, personal_color]
            );
        }
        if (skin_tone) {
            await pool.query(
                `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                 VALUES ($1, 'skin_tone', $2, 5)
                 ON CONFLICT (user_id, category_type, category_value) DO NOTHING`,
                [id, skin_tone]
            );
        }

        const { rows: updated } = await pool.query(
            `SELECT user_id AS id, email, name, nickname, bio, profile_image, background_image,
                    aesthetic_tag, personal_color, skin_tone
             FROM users WHERE user_id=$1`,
            [id]
        );

        res.json({ message: "프로필이 수정되었습니다", user: updated[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { searchUsers, getProfile, updateProfile };
