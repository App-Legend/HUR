const pool = require('../db');

// 글 작성 API
const createPost = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, description, stickers, personalColors, moods, skinTones } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ message: '제목은 필수입니다.' });
    }

    const postImage = req.file ? `/uploads/${req.file.filename}` : null;

    const stickerList = stickers ? JSON.parse(stickers) : [];
    console.log('[createPost] stickerList:', JSON.stringify(stickerList));
    const personalColorList = (personalColors ? JSON.parse(personalColors) : [])
      .filter((v) => v !== '잘 모르겠음');
    const moodList = moods ? JSON.parse(moods) : [];
    const skinToneList = skinTones ? JSON.parse(skinTones) : [];

    const [postResult] = await pool.query(
      `INSERT INTO posts (user_id, title, post_content, post_image)
       VALUES (?, ?, ?, ?)`,
      [userId, title.trim(), description?.trim() ?? null, postImage]
    );

    const postId = postResult.insertId;

    // post_category에 태그 INSERT
    const categories = [
      ...personalColorList.map((v) => ['personal_color', v]),
      ...moodList.map((v) => ['mood', v]),
      ...skinToneList.map((v) => ['skin_tone', v]),
    ];

    if (categories.length > 0) {
      const placeholders = categories.map(() => `(?, ?, ?)`).join(', ');
      await pool.query(
        `INSERT INTO post_category (post_id, category_type, category_value) VALUES ${placeholders}`,
        categories.flatMap(([type, value]) => [postId, type, value])
      );
    }

    // post_sticker에 스티커 INSERT
    if (stickerList.length > 0) {
      try {
        const placeholders = stickerList.map(() => `(?, ?, ?, ?)`).join(', ');
        await pool.query(
          `INSERT INTO post_sticker (post_id, product_id, x_ratio, y_ratio) VALUES ${placeholders}`,
          stickerList.flatMap((s) => [postId, s.productId, s.xRatio, s.yRatio])
        );
      } catch (stickerErr) {
        console.error('[sticker insert error]', stickerErr.message, JSON.stringify(stickerList));
      }
    }

    res.status(201).json({ message: '게시글이 등록되었습니다.', postId });
  } catch (err) {
    console.error('[createPost error]', err.message);
    res.status(500).json({ error: err.message });
  }
};

const getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 0;
    const userId = parseInt(req.query.user_id) || null;
    const limit = 20;
    const offset = page * limit;

    let rows;
    if (userId) {
      [rows] = await pool.query(
        `SELECT
          p.post_id,
          p.title,
          p.post_image,
          p.created_at,
          u.nickname,
          u.profile_image,
          IFNULL(
            (SELECT JSON_ARRAYAGG(JSON_OBJECT('type', pc.category_type, 'value', pc.category_value))
             FROM post_category pc
             WHERE pc.post_id = p.post_id),
            JSON_ARRAY()
          ) AS categories,
          IFNULL(
            (SELECT SUM(ucs.score)
             FROM post_category pc2
             JOIN user_category_score ucs
               ON ucs.category_type = pc2.category_type
               AND ucs.category_value = pc2.category_value
               AND ucs.user_id = ?
             WHERE pc2.post_id = p.post_id),
            0
          ) AS relevance_score
        FROM posts p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.created_at > NOW() - INTERVAL 7 DAY
        ORDER BY relevance_score DESC, p.created_at DESC
        LIMIT ? OFFSET ?`,
        [userId, limit, offset]
      );
    } else {
      [rows] = await pool.query(
        `SELECT
          p.post_id,
          p.title,
          p.post_image,
          p.created_at,
          u.nickname,
          u.profile_image,
          IFNULL(
            (SELECT JSON_ARRAYAGG(JSON_OBJECT('type', pc.category_type, 'value', pc.category_value))
             FROM post_category pc
             WHERE pc.post_id = p.post_id),
            JSON_ARRAY()
          ) AS categories
        FROM posts p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.created_at > NOW() - INTERVAL 7 DAY
        ORDER BY p.created_at DESC
        LIMIT ? OFFSET ?`,
        [limit, offset]
      );
    }

    res.json({ posts: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 좋아요 토글 (좋아요 추가 시 score +2, 취소 시 -2)
const toggleLike = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id } = req.body;

        if (!user_id) return res.status(400).json({ message: 'user_id가 필요합니다' });

        const [existing] = await pool.query(
            'SELECT like_id FROM post_likes WHERE post_id = ? AND user_id = ?',
            [postId, user_id]
        );

        if (existing.length > 0) {
            // 좋아요 취소
            await pool.query('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, user_id]);
            await pool.query('UPDATE posts SET post_like = GREATEST(post_like - 1, 0) WHERE post_id = ?', [postId]);

            const [categories] = await pool.query(
                'SELECT category_type, category_value FROM post_category WHERE post_id = ?', [postId]
            );
            for (const { category_type, category_value } of categories) {
                await pool.query(
                    `UPDATE user_category_score SET score = GREATEST(score - 2, 0)
                     WHERE user_id = ? AND category_type = ? AND category_value = ?`,
                    [user_id, category_type, category_value]
                );
            }
            return res.json({ liked: false });
        } else {
            // 좋아요 추가
            await pool.query('INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)', [postId, user_id]);
            await pool.query('UPDATE posts SET post_like = post_like + 1 WHERE post_id = ?', [postId]);

            const [categories] = await pool.query(
                'SELECT category_type, category_value FROM post_category WHERE post_id = ?', [postId]
            );
            for (const { category_type, category_value } of categories) {
                await pool.query(
                    `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                     VALUES (?, ?, ?, 2)
                     ON DUPLICATE KEY UPDATE score = score + 2`,
                    [user_id, category_type, category_value]
                );
            }
            return res.json({ liked: true });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 좋아요 여부 확인
const getLikeStatus = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id } = req.query;

        const [[{ count }]] = await pool.query(
            'SELECT COUNT(*) AS count FROM post_likes WHERE post_id = ?', [postId]
        );

        if (!user_id) return res.json({ liked: false, count });

        const [existing] = await pool.query(
            'SELECT like_id FROM post_likes WHERE post_id = ? AND user_id = ?', [postId, user_id]
        );

        res.json({ liked: existing.length > 0, count });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 점수 업데이트 (조회=+1, 좋아요=+2 / 실제 점수는 /2 해서 표시)
const updateScore = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id, action } = req.body;

        if (!user_id || !action) {
            return res.status(400).json({ message: 'user_id와 action이 필요합니다' });
        }

        const delta = action === 'like' ? 2 : 1;

        const [categories] = await pool.query(
            'SELECT category_type, category_value FROM post_category WHERE post_id = ?',
            [postId]
        );

        if (categories.length === 0) return res.json({ message: '카테고리 없음' });

        for (const { category_type, category_value } of categories) {
            await pool.query(
                `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                 VALUES (?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE score = score + ?`,
                [user_id, category_type, category_value, delta, delta]
            );
        }

        res.json({ message: '점수 업데이트 완료' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 게시물 상세 조회
const getPostDetail = async (req, res) => {
    try {
        const { id: postId } = req.params;

        const [[post]] = await pool.query(
            `SELECT p.post_id, p.user_id, p.title, p.post_content, p.post_image, p.post_like,
                    u.nickname, u.profile_image
             FROM posts p
             JOIN users u ON p.user_id = u.user_id
             WHERE p.post_id = ?`,
            [parseInt(postId)]
        );
        if (!post) return res.status(404).json({ message: '게시물이 없습니다' });

        const [categories] = await pool.query(
            'SELECT category_type, category_value FROM post_category WHERE post_id = ?', [postId]
        );

        let stickers = [];
        try {
            const [rows] = await pool.query(
                `SELECT ps.x_ratio, ps.y_ratio, p.id AS product_id,
                        p.brand AS brand_name, p.name AS product_name, p.image
                 FROM post_sticker ps
                 JOIN products p ON ps.product_id = p.id
                 WHERE ps.post_id = ?`, [postId]
            );
            stickers = rows;
        } catch (e) { console.error('[getPostDetail sticker]', e.message); }

        let comment_count = 0;
        try {
            const [[row]] = await pool.query(
                'SELECT COUNT(*) AS count FROM post_comments WHERE post_id = ?', [postId]
            );
            comment_count = row.count;
        } catch (e) { console.error('[getPostDetail comment_count]', e.message); }

        const result = { ...post, categories, stickers, comment_count };
        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 댓글 목록 조회
const getComments = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const [rows] = await pool.query(
            `SELECT c.comment_id, c.content, c.created_at,
                    u.user_id, u.nickname, u.profile_image
             FROM post_comments c
             JOIN users u ON c.user_id = u.user_id
             WHERE c.post_id = ?
             ORDER BY c.created_at ASC`,
            [postId]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 댓글 작성
const addComment = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id, content } = req.body;

        if (!user_id || !content?.trim()) {
            return res.status(400).json({ message: 'user_id와 내용이 필요합니다' });
        }

        const [result] = await pool.query(
            'INSERT INTO post_comments (post_id, user_id, content) VALUES (?, ?, ?)',
            [postId, user_id, content.trim()]
        );

        const [[comment]] = await pool.query(
            `SELECT c.comment_id, c.content, c.created_at,
                    u.user_id, u.nickname, u.profile_image
             FROM post_comments c
             JOIN users u ON c.user_id = u.user_id
             WHERE c.comment_id = ?`,
            [result.insertId]
        );

        res.status(201).json(comment);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 댓글 삭제
const deleteComment = async (req, res) => {
    try {
        const { commentId } = req.params;
        const { user_id } = req.body;

        const [rows] = await pool.query(
            'SELECT user_id FROM post_comments WHERE comment_id = ?', [commentId]
        );

        if (rows.length === 0) return res.status(404).json({ message: '댓글이 없습니다' });
        if (rows[0].user_id !== Number(user_id)) {
            return res.status(403).json({ message: '본인 댓글만 삭제할 수 있습니다' });
        }

        await pool.query('DELETE FROM post_comments WHERE comment_id = ?', [commentId]);
        res.json({ message: '댓글이 삭제됐습니다' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { createPost, getFeed, getPostDetail, updateScore, toggleLike, getLikeStatus, getComments, addComment, deleteComment };
