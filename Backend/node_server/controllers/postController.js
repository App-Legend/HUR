const pool = require('../db');

// 글 작성 API
const createPost = async (req, res) => {
  try {
    const userId = req.user.id;
    const { title, description, stickers, personalColors, moods, skinTones, visibility } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ message: '제목은 필수입니다.' });
    }

    const postImage = req.file ? `/uploads/${req.file.filename}` : null;
    const visibilityValue = visibility || '모든 사람';

    const stickerList = stickers ? JSON.parse(stickers) : [];
    const personalColorList = (personalColors ? JSON.parse(personalColors) : [])
      .filter((v) => v !== '잘 모르겠음');
    const moodList = moods ? JSON.parse(moods) : [];
    const skinToneList = skinTones ? JSON.parse(skinTones) : [];

    const { rows: [{ post_id: postId }] } = await pool.query(
      `INSERT INTO posts (user_id, title, post_content, post_image, visibility)
       VALUES ($1, $2, $3, $4, $5) RETURNING post_id`,
      [userId, title.trim(), description?.trim() ?? null, postImage, visibilityValue]
    );

    const categories = [
      ...personalColorList.map((v) => ['personal_color', v]),
      ...moodList.map((v) => ['mood', v]),
      ...skinToneList.map((v) => ['skin_tone', v]),
    ];

    if (categories.length > 0) {
      const placeholders = categories.map((_, i) => `($${i*3+1}, $${i*3+2}, $${i*3+3})`).join(', ');
      await pool.query(
        `INSERT INTO post_category (post_id, category_type, category_value) VALUES ${placeholders}`,
        categories.flatMap(([type, value]) => [postId, type, value])
      );
    }

    if (stickerList.length > 0) {
      try {
        const placeholders = stickerList.map((_, i) => `($${i*4+1}, $${i*4+2}, $${i*4+3}, $${i*4+4})`).join(', ');
        await pool.query(
          `INSERT INTO post_sticker (post_id, product_id, x_ratio, y_ratio) VALUES ${placeholders}`,
          stickerList.flatMap((s) => [postId, s.productId, s.xRatio, s.yRatio])
        );
      } catch (stickerErr) {
        console.error('[sticker insert error]', stickerErr.message);
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

    const color = req.query.color || null;
    const skinTone = req.query.skin_tone || null;

    let rows;
    if (userId) {
      ({ rows } = await pool.query(
        `SELECT
          p.post_id,
          p.title,
          p.post_image,
          p.created_at,
          u.nickname,
          u.profile_image,
          COALESCE(
            (SELECT JSON_AGG(JSON_BUILD_OBJECT('type', pc.category_type, 'value', pc.category_value))
             FROM post_category pc
             WHERE pc.post_id = p.post_id),
            '[]'::json
          ) AS categories,
          COALESCE(
            (SELECT SUM(ucs.score)
             FROM post_category pc2
             JOIN user_category_score ucs
               ON ucs.category_type = pc2.category_type
               AND ucs.category_value = pc2.category_value
               AND ucs.user_id = $1
             WHERE pc2.post_id = p.post_id),
            0
          ) AS relevance_score
        FROM posts p
        JOIN users u ON p.user_id = u.user_id
        WHERE (p.visibility = '모든 사람' OR (p.visibility = '팔로워만' AND EXISTS (
                SELECT 1 FROM follow WHERE follower_id = $1 AND following_id = p.user_id
              )))
          AND p.created_at > NOW() - INTERVAL '7 days'
        ORDER BY relevance_score DESC, p.created_at DESC
        LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      ));
    } else if (color || skinTone) {
      const params = [];
      const categoryFilters = [];
      if (color) {
        params.push('personal_color', color);
        categoryFilters.push(`(pc.category_type = $${params.length - 1} AND pc.category_value = $${params.length})`);
      }
      if (skinTone) {
        params.push('skin_tone', skinTone);
        categoryFilters.push(`(pc.category_type = $${params.length - 1} AND pc.category_value = $${params.length})`);
      }
      const filterExpr = categoryFilters.join(' OR ');
      params.push(limit, offset);
      const limitIdx = params.length - 1;
      const offsetIdx = params.length;

      ({ rows } = await pool.query(
        `SELECT
          p.post_id,
          p.title,
          p.post_image,
          p.created_at,
          u.nickname,
          u.profile_image,
          COALESCE(
            (SELECT JSON_AGG(JSON_BUILD_OBJECT('type', pc.category_type, 'value', pc.category_value))
             FROM post_category pc
             WHERE pc.post_id = p.post_id),
            '[]'::json
          ) AS categories,
          COALESCE(
            (SELECT COUNT(*) FROM post_category pc
             WHERE pc.post_id = p.post_id AND (${filterExpr})),
            0
          ) AS relevance_score
        FROM posts p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.visibility = '모든 사람'
          AND p.created_at > NOW() - INTERVAL '7 days'
        ORDER BY relevance_score DESC, p.created_at DESC
        LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
        params
      ));
    } else {
      ({ rows } = await pool.query(
        `SELECT
          p.post_id,
          p.title,
          p.post_image,
          p.created_at,
          u.nickname,
          u.profile_image,
          COALESCE(
            (SELECT JSON_AGG(JSON_BUILD_OBJECT('type', pc.category_type, 'value', pc.category_value))
             FROM post_category pc
             WHERE pc.post_id = p.post_id),
            '[]'::json
          ) AS categories
        FROM posts p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.visibility = '모든 사람'
          AND p.created_at > NOW() - INTERVAL '7 days'
        ORDER BY p.created_at DESC
        LIMIT $1 OFFSET $2`,
        [limit, offset]
      ));
    }

    res.json({ posts: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getUserPosts = async (req, res) => {
  try {
    const { userId } = req.params;
    const userIdInt = parseInt(userId);
    const viewerIdRaw = req.query.viewer_id;
    const viewerId = viewerIdRaw ? parseInt(viewerIdRaw) : null;

    let query, params;
    if (viewerId === userIdInt) {
      query = `SELECT p.post_id, p.post_image, p.title, p.created_at, u.nickname
               FROM posts p JOIN users u ON p.user_id = u.user_id
               WHERE p.user_id = $1
               ORDER BY p.created_at DESC`;
      params = [userIdInt];
    } else if (viewerId) {
      query = `SELECT p.post_id, p.post_image, p.title, p.created_at, u.nickname
               FROM posts p JOIN users u ON p.user_id = u.user_id
               WHERE p.user_id = $1
                 AND (p.visibility = '모든 사람' OR (p.visibility = '팔로워만' AND EXISTS (
                   SELECT 1 FROM follow WHERE follower_id = $2 AND following_id = $1
                 )))
               ORDER BY p.created_at DESC`;
      params = [userIdInt, viewerId];
    } else {
      query = `SELECT p.post_id, p.post_image, p.title, p.created_at, u.nickname
               FROM posts p JOIN users u ON p.user_id = u.user_id
               WHERE p.user_id = $1 AND p.visibility = '모든 사람'
               ORDER BY p.created_at DESC`;
      params = [userIdInt];
    }

    const { rows } = await pool.query(query, params);
    res.json({ posts: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 좋아요 토글
const toggleLike = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id } = req.body;

        if (!user_id) return res.status(400).json({ message: 'user_id가 필요합니다' });

        const { rows: existing } = await pool.query(
            'SELECT like_id FROM post_likes WHERE post_id = $1 AND user_id = $2',
            [postId, user_id]
        );

        if (existing.length > 0) {
            await pool.query('DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2', [postId, user_id]);
            await pool.query('UPDATE posts SET post_like = GREATEST(post_like - 1, 0) WHERE post_id = $1', [postId]);

            const { rows: categories } = await pool.query(
                'SELECT category_type, category_value FROM post_category WHERE post_id = $1', [postId]
            );
            for (const { category_type, category_value } of categories) {
                await pool.query(
                    `UPDATE user_category_score SET score = GREATEST(score - 2, 0)
                     WHERE user_id = $1 AND category_type = $2 AND category_value = $3`,
                    [user_id, category_type, category_value]
                );
            }
            return res.json({ liked: false });
        } else {
            await pool.query('INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2)', [postId, user_id]);
            await pool.query('UPDATE posts SET post_like = post_like + 1 WHERE post_id = $1', [postId]);

            const { rows: categories } = await pool.query(
                'SELECT category_type, category_value FROM post_category WHERE post_id = $1', [postId]
            );
            for (const { category_type, category_value } of categories) {
                await pool.query(
                    `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                     VALUES ($1, $2, $3, 2)
                     ON CONFLICT (user_id, category_type, category_value) DO UPDATE SET score = user_category_score.score + 2`,
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

        const { rows: [{ count }] } = await pool.query(
            'SELECT COUNT(*) AS count FROM post_likes WHERE post_id = $1', [postId]
        );

        if (!user_id) return res.json({ liked: false, count: parseInt(count) });

        const { rows: existing } = await pool.query(
            'SELECT like_id FROM post_likes WHERE post_id = $1 AND user_id = $2', [postId, user_id]
        );

        res.json({ liked: existing.length > 0, count: parseInt(count) });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 점수 업데이트
const updateScore = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { user_id, action } = req.body;

        if (!user_id || !action) {
            return res.status(400).json({ message: 'user_id와 action이 필요합니다' });
        }

        const delta = action === 'like' ? 2 : 1;

        const { rows: categories } = await pool.query(
            'SELECT category_type, category_value FROM post_category WHERE post_id = $1',
            [postId]
        );

        if (categories.length === 0) return res.json({ message: '카테고리 없음' });

        for (const { category_type, category_value } of categories) {
            await pool.query(
                `INSERT INTO user_category_score (user_id, category_type, category_value, score)
                 VALUES ($1, $2, $3, $4)
                 ON CONFLICT (user_id, category_type, category_value) DO UPDATE SET score = user_category_score.score + $4`,
                [user_id, category_type, category_value, delta]
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
        const viewerId = req.query.viewer_id ? parseInt(req.query.viewer_id) : null;

        const { rows } = await pool.query(
            `SELECT p.post_id, p.user_id, p.title, p.post_content, p.post_image, p.post_like,
                    p.visibility, u.nickname, u.profile_image
             FROM posts p
             JOIN users u ON p.user_id = u.user_id
             WHERE p.post_id = $1`,
            [parseInt(postId)]
        );
        const post = rows[0];
        if (!post) return res.status(404).json({ message: '게시물이 없습니다' });

        if (post.visibility === '팔로워만') {
            if (!viewerId) {
                return res.status(403).json({ message: '팔로우한 사람만 볼 수 있는 게시물이에요.' });
            }
            if (viewerId !== post.user_id) {
                const { rows: followCheck } = await pool.query(
                    'SELECT 1 FROM follow WHERE follower_id = $1 AND following_id = $2',
                    [viewerId, post.user_id]
                );
                if (followCheck.length === 0) {
                    return res.status(403).json({ message: '팔로우한 사람만 볼 수 있는 게시물이에요.' });
                }
            }
        }

        const { rows: categories } = await pool.query(
            'SELECT category_type, category_value FROM post_category WHERE post_id = $1', [postId]
        );

        let stickers = [];
        try {
            const { rows: stickerRows } = await pool.query(
                `SELECT ps.x_ratio, ps.y_ratio, p.id AS product_id,
                        p.brand AS brand_name, p.name AS product_name, p.image
                 FROM post_sticker ps
                 JOIN products p ON ps.product_id = p.id
                 WHERE ps.post_id = $1`, [postId]
            );
            stickers = stickerRows;
        } catch (e) { console.error('[getPostDetail sticker]', e.message); }

        let comment_count = 0;
        try {
            const { rows: [{ count }] } = await pool.query(
                'SELECT COUNT(*) AS count FROM post_comments WHERE post_id = $1', [postId]
            );
            comment_count = parseInt(count);
        } catch (e) { console.error('[getPostDetail comment_count]', e.message); }

        res.json({ ...post, categories, stickers, comment_count });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 댓글 목록 조회
const getComments = async (req, res) => {
    try {
        const { id: postId } = req.params;
        const { rows } = await pool.query(
            `SELECT c.comment_id, c.content, c.created_at,
                    u.user_id, u.nickname, u.profile_image
             FROM post_comments c
             JOIN users u ON c.user_id = u.user_id
             WHERE c.post_id = $1
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

        const { rows: [{ comment_id }] } = await pool.query(
            'INSERT INTO post_comments (post_id, user_id, content) VALUES ($1, $2, $3) RETURNING comment_id',
            [postId, user_id, content.trim()]
        );

        const { rows: [comment] } = await pool.query(
            `SELECT c.comment_id, c.content, c.created_at,
                    u.user_id, u.nickname, u.profile_image
             FROM post_comments c
             JOIN users u ON c.user_id = u.user_id
             WHERE c.comment_id = $1`,
            [comment_id]
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

        const { rows } = await pool.query(
            'SELECT user_id FROM post_comments WHERE comment_id = $1', [commentId]
        );

        if (rows.length === 0) return res.status(404).json({ message: '댓글이 없습니다' });
        if (rows[0].user_id !== Number(user_id)) {
            return res.status(403).json({ message: '본인 댓글만 삭제할 수 있습니다' });
        }

        await pool.query('DELETE FROM post_comments WHERE comment_id = $1', [commentId]);
        res.json({ message: '댓글이 삭제됐습니다' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// 제품 태그된 게시물 조회
const getPostsByProduct = async (req, res) => {
    try {
        const { productId } = req.params;
        const { rows } = await pool.query(
            `SELECT DISTINCT p.post_id, p.title, p.post_image, u.nickname, u.profile_image,
                    COALESCE(
                        (SELECT JSON_AGG(pc.category_value)
                         FROM post_category pc
                         WHERE pc.post_id = p.post_id AND pc.category_type = 'personal_color'),
                        '[]'::json
                    ) AS personal_colors
             FROM posts p
             JOIN post_sticker ps ON ps.post_id = p.post_id
             JOIN users u ON p.user_id = u.user_id
             WHERE ps.product_id = $1
             ORDER BY p.post_id DESC`,
            [productId]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { createPost, getFeed, getUserPosts, getPostDetail, updateScore, toggleLike, getLikeStatus, getComments, addComment, deleteComment, getPostsByProduct };
