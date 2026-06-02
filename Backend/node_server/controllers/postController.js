const pool = require('../db');

const createPost = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { title, description, stickers, personalColors, moods, skinTones } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ message: '제목은 필수입니다.' });
    }

    const postImage = req.file ? `/uploads/${req.file.filename}` : null;

    const stickerList = stickers ? JSON.parse(stickers) : [];
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
      const placeholders = stickerList.map(() => `(?, ?, ?, ?, ?)`).join(', ');
      await pool.query(
        `INSERT INTO post_sticker (post_id, x_ratio, y_ratio, brand_name, product_name) VALUES ${placeholders}`,
        stickerList.flatMap((s) => [postId, s.xRatio, s.yRatio, s.brandName, s.productName])
      );
    }

    res.status(201).json({ message: '게시글이 등록되었습니다.', postId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getFeed = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 0;
    const limit = 20;
    const offset = page * limit;

    const [rows] = await pool.query(
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

    res.json({ posts: rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { createPost, getFeed };
