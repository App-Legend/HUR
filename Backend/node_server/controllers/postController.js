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
    const personalColorList = personalColors ? JSON.parse(personalColors) : [];
    const moodList = moods ? JSON.parse(moods) : [];
    const skinToneList = skinTones ? JSON.parse(skinTones) : [];

    const postResult = await pool.query(
      `INSERT INTO posts (user_id, title, post_content, post_image)
       VALUES ($1, $2, $3, $4)
       RETURNING post_id`,
      [userId, title.trim(), description?.trim() ?? null, postImage]
    );

    const postId = postResult.rows[0].post_id;

    // post_category에 태그 INSERT
    const categories = [
      ...personalColorList.map((v) => ['personal_color', v]),
      ...moodList.map((v) => ['mood', v]),
      ...skinToneList.map((v) => ['skin_tone', v]),
    ];

    if (categories.length > 0) {
      const placeholders = categories
        .map((_, i) => `($${i * 3 + 1}, $${i * 3 + 2}, $${i * 3 + 3})`)
        .join(', ');

      await pool.query(
        `INSERT INTO post_category (post_id, category_type, category_value)
         VALUES ${placeholders}`,
        categories.flatMap(([type, value]) => [postId, type, value])
      );
    }

    // post_sticker에 스티커 INSERT
    if (stickerList.length > 0) {
      const placeholders = stickerList
        .map((_, i) => `($${i * 5 + 1}, $${i * 5 + 2}, $${i * 5 + 3}, $${i * 5 + 4}, $${i * 5 + 5})`)
        .join(', ');

      await pool.query(
        `INSERT INTO post_sticker (post_id, x_ratio, y_ratio, brand_name, product_name)
         VALUES ${placeholders}`,
        stickerList.flatMap((s) => [postId, s.xRatio, s.yRatio, s.brandName, s.productName])
      );
    }

    res.status(201).json({ message: '게시글이 등록되었습니다.', postId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { createPost };
