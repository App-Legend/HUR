const pool = require('../db');

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

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

// 사용자가 올린 '추구미' 레퍼런스 사진을 CLIP 임베딩으로 바꿔서
// 벡터가 가장 가까운(코사인 거리) 상품을 추천한다.
const recommendByImage = async (req, res) => {
    try {
        const { image, limit = 10 } = req.body;

        if (!image) {
            return res.status(400).json({ message: "image is required (base64)" });
        }

        const embedRes = await fetch(`${ML_SERVICE_URL}/embed`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ image }),
        });

        if (!embedRes.ok) {
            const detail = await embedRes.text();
            return res.status(502).json({ message: "ml_server error", detail });
        }

        const { embedding } = await embedRes.json();
        const vectorLiteral = `[${embedding.join(",")}]`;

        const { rows } = await pool.query(
            `SELECT id, brand, name, image, source,
                    embedding <=> $1::vector AS distance
             FROM products
             WHERE embedding IS NOT NULL
             ORDER BY embedding <=> $1::vector
             LIMIT $2`,
            [vectorLiteral, parseInt(limit)]
        );

        res.json(rows);
    } catch (err) {
        console.error("products/recommend error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getRanking, searchProducts, getProduct, recommendByImage };
