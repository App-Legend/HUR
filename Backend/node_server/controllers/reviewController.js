const pool = require('../db');

const MAX_CONTENT_LENGTH = 500;

// 후기 목록 + 우리 앱 후기 평균/개수 (로그인 불필요)
const getReviews = async (req, res) => {
    try {
        const productId = parseInt(req.params.id);
        if (!productId) return res.status(400).json({ message: '잘못된 상품입니다.' });

        const { rows } = await pool.query(
            `SELECT r.review_id, r.user_id, u.nickname, r.rating, r.content, r.created_at
             FROM product_reviews r
             JOIN users u ON u.user_id = r.user_id
             WHERE r.product_id = $1
             ORDER BY r.created_at DESC
             LIMIT 100`,
            [productId]
        );

        const count = rows.length;
        const avg = count === 0 ? null : rows.reduce((sum, r) => sum + r.rating, 0) / count;

        res.json({
            summary: { count, average: avg === null ? null : Math.round(avg * 10) / 10 },
            reviews: rows,
        });
    } catch (err) {
        console.error('[getReviews error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

// 후기 쓰기. 이미 썼으면 수정한다. (로그인 필요)
const saveReview = async (req, res) => {
    try {
        const productId = parseInt(req.params.id);
        const rating = parseInt(req.body.rating);
        const content = typeof req.body.content === 'string' ? req.body.content.trim().slice(0, MAX_CONTENT_LENGTH) : '';

        if (!productId) return res.status(400).json({ message: '잘못된 상품입니다.' });
        if (!(rating >= 1 && rating <= 5)) return res.status(400).json({ message: '별점은 1~5점으로 선택해주세요.' });
        if (!content) return res.status(400).json({ message: '후기 내용을 입력해주세요.' });

        const product = await pool.query('SELECT 1 FROM products WHERE id = $1', [productId]);
        if (product.rowCount === 0) return res.status(404).json({ message: '상품을 찾을 수 없습니다.' });

        await pool.query(
            `INSERT INTO product_reviews (product_id, user_id, rating, content)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (product_id, user_id)
             DO UPDATE SET rating = EXCLUDED.rating, content = EXCLUDED.content, updated_at = CURRENT_TIMESTAMP`,
            [productId, req.user.id, rating, content]
        );

        res.status(201).json({ message: '후기가 등록되었어요.' });
    } catch (err) {
        console.error('[saveReview error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

// 내 후기 삭제 (로그인 필요)
const deleteMyReview = async (req, res) => {
    try {
        const productId = parseInt(req.params.id);
        await pool.query(
            'DELETE FROM product_reviews WHERE product_id = $1 AND user_id = $2',
            [productId, req.user.id]
        );
        res.json({ message: '후기를 삭제했어요.' });
    } catch (err) {
        console.error('[deleteMyReview error]', err.message);
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getReviews, saveReview, deleteMyReview };
