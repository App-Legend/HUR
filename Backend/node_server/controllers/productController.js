const pool = require('../db');

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

// 랭킹: 카테고리별로 리뷰 수가 많은 순 (리뷰 수가 없는 상품은 맨 뒤). 모든 유저에게 같은 순서로 보여준다.
// category를 안 보내면 전체 상품을 대상으로 한다.
const getRanking = async (req, res) => {
    try {
        const { limit = 20, category } = req.query;
        const limitInt = parseInt(limit) || 20;

        const { rows } = await pool.query(
            `SELECT p.id, p.brand, p.name, p.image, p.source, p.category,
                    p.price, p.original_price, p.discount_rate, p.rating, p.review_count,
                    COUNT(ps.id) AS tag_count
             FROM products p
             LEFT JOIN post_sticker ps ON p.id = ps.product_id
             WHERE ($2::text IS NULL OR p.category = $2)
             GROUP BY p.id
             ORDER BY p.review_count DESC NULLS LAST, tag_count DESC, p.id ASC
             LIMIT $1`,
            [limitInt, category || null]
        );

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
            `SELECT id, brand, name, image, source, category
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
            `SELECT id, brand, name, image, source, category,
                    price, original_price, discount_rate, rating, review_count
             FROM products WHERE id = $1`,
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
