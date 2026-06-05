const pool = require('../db');

const getRanking = async (req, res) => {
    try {
        const { limit = 20, user_id } = req.query;
        const limitInt = parseInt(limit);

        let rows;

        if (user_id) {
            ({ rows } = await pool.query(
                `SELECT p.id, p.brand, p.name, p.image, p.source,
                        COALESCE(SUM(ucs.score), 0) AS relevance_score,
                        COUNT(DISTINCT ps.post_id) AS tag_count
                 FROM products p
                 LEFT JOIN post_sticker ps ON ps.product_id = p.id
                 LEFT JOIN post_category pc ON pc.post_id = ps.post_id
                 LEFT JOIN user_category_score ucs
                   ON ucs.category_type = pc.category_type
                   AND ucs.category_value = pc.category_value
                   AND ucs.user_id = $1
                 GROUP BY p.id
                 ORDER BY relevance_score DESC, tag_count DESC, p.id ASC
                 LIMIT $2`,
                [parseInt(user_id), limitInt]
            ));
        } else {
            ({ rows } = await pool.query(
                `SELECT p.id, p.brand, p.name, p.image, p.source,
                        COUNT(ps.id) AS tag_count
                 FROM products p
                 LEFT JOIN post_sticker ps ON p.id = ps.product_id
                 GROUP BY p.id
                 ORDER BY tag_count DESC, p.id ASC
                 LIMIT $1`,
                [limitInt]
            ));
        }

        res.json(rows);
    } catch (err) {
        console.error("products/ranking error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

const searchProducts = async (req, res) => {
    try {
        const { q = "", limit = 20 } = req.query;

        if (!q.trim()) {
            return res.json([]);
        }

        const { rows } = await pool.query(
            `SELECT id, brand, name, image, source
             FROM products
             WHERE name ILIKE $1 OR brand ILIKE $1
             ORDER BY id ASC
             LIMIT $2`,
            [`%${q.trim()}%`, parseInt(limit)]
        );

        res.json(rows);
    } catch (err) {
        console.error("products/search error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

const getProduct = async (req, res) => {
    try {
        const { id } = req.params;

        const { rows } = await pool.query(
            "SELECT id, brand, name, image, source FROM products WHERE id = $1",
            [parseInt(id)]
        );

        if (rows.length === 0) {
            return res.status(404).json({ message: "상품을 찾을 수 없습니다" });
        }

        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getRanking, searchProducts, getProduct };
