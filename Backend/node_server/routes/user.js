const express = require("express");
const pool = require("../db");

const router = express.Router();

// 유저 검색
router.get("/search/users", async (req, res) => {
    try {
        const { q, me } = req.query;
        if (!q || q.trim() === "") return res.json([]);

        const result = await pool.query(
            `SELECT u.id, u.nickname, u.username, u.profile_image,
                    EXISTS(
                        SELECT 1 FROM follow
                        WHERE follower_id = $2 AND following_id = u.id
                    ) AS is_following
             FROM "user" u
             WHERE (u.username ILIKE $1 OR u.nickname ILIKE $1)
               AND u.id != $2
             LIMIT 20`,
            [`%${q}%`, me ?? 0]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 유저 프로필 조회
router.get("/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `SELECT u.id, u.email, u.name, u.nickname, u.username, u.gender, u.birth_date,
                    u.bio, u.profile_image, u.background_image, u.aesthetic_tag,
                    COUNT(DISTINCT f_in.follower_id)  AS follower_count,
                    COUNT(DISTINCT f_out.following_id) AS following_count
             FROM "user" u
             LEFT JOIN follow f_in  ON f_in.following_id = u.id
             LEFT JOIN follow f_out ON f_out.follower_id  = u.id
             WHERE u.id = $1
             GROUP BY u.id`,
            [id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ message: "유저를 찾을 수 없습니다" });
        }
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 유저 프로필 수정
router.put("/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { nickname, username, bio, profile_image, background_image, aesthetic_tag } = req.body;

        const existing = await pool.query('SELECT id FROM "user" WHERE id=$1', [id]);
        if (existing.rows.length === 0) {
            return res.status(404).json({ message: "유저를 찾을 수 없습니다" });
        }

        if (nickname) {
            const dup = await pool.query('SELECT id FROM "user" WHERE nickname=$1 AND id!=$2', [nickname, id]);
            if (dup.rows.length > 0) return res.status(409).json({ message: "이미 사용 중인 닉네임입니다" });
        }

        if (username) {
            const dup = await pool.query('SELECT id FROM "user" WHERE username=$1 AND id!=$2', [username, id]);
            if (dup.rows.length > 0) return res.status(409).json({ message: "이미 사용 중인 아이디입니다" });
        }

        const result = await pool.query(
            `UPDATE "user"
             SET nickname          = COALESCE($1, nickname),
                 username          = COALESCE($2, username),
                 bio               = COALESCE($3, bio),
                 profile_image     = COALESCE($4, profile_image),
                 background_image  = COALESCE($5, background_image),
                 aesthetic_tag     = COALESCE($6, aesthetic_tag)
             WHERE id=$7
             RETURNING id, email, name, nickname, username, bio, profile_image, background_image, aesthetic_tag`,
            [nickname, username, bio, profile_image, background_image, aesthetic_tag, id]
        );

        res.json({ message: "프로필이 수정되었습니다", user: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
