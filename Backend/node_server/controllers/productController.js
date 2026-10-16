const pool = require('../db');

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

// 내 추구미 랭킹.
// 로그인한 유저는 내 추구미(내 최신 게시물 -> 최근 좋아요한 게시물 -> 온보딩 취향 벡터 순)와
// 가장 닮은 다른 사람의 공개 게시물 50개를 찾고, 그 게시물에 태그된 제품을 닮은 정도의 합으로 먼저 정렬한다.
// 점수가 없는 제품(데이터가 적거나 비로그인)은 리뷰 수가 많은 순으로 뒤를 채운다.
// category를 안 보내면 전체 상품을 대상으로 한다.
const getRanking = async (req, res) => {
    try {
        const { limit = 20, category } = req.query;
        const limitInt = parseInt(limit) || 20;
        const userId = req.user ? req.user.id : null;

        const { rows } = await pool.query(
            `WITH anchor AS (
               SELECT COALESCE(
                 (SELECT embedding FROM posts WHERE user_id = $3::int AND embedding IS NOT NULL ORDER BY created_at DESC LIMIT 1),
                 (SELECT p2.embedding FROM post_likes pl JOIN posts p2 ON p2.post_id = pl.post_id
                   WHERE pl.user_id = $3::int AND p2.embedding IS NOT NULL ORDER BY pl.created_at DESC LIMIT 1),
                 (SELECT embedding FROM users WHERE user_id = $3::int)
               ) AS vec
             ),
             similar_posts AS (
               SELECT p.post_id, 1 - (p.embedding <=> anchor.vec) AS sim
               FROM posts p CROSS JOIN anchor
               WHERE anchor.vec IS NOT NULL
                 AND p.embedding IS NOT NULL
                 AND p.user_id <> $3::int
                 AND (p.visibility IS NULL OR p.visibility = '모든 사람')
               ORDER BY p.embedding <=> anchor.vec
               LIMIT 50
             ),
             scores AS (
               SELECT ps.product_id, SUM(sp.sim) AS match_score
               FROM similar_posts sp
               JOIN post_sticker ps ON ps.post_id = sp.post_id
               GROUP BY ps.product_id
             )
             SELECT p.id, p.brand, p.name, p.image, p.source, p.category,
                    p.price, p.original_price, p.discount_rate, p.rating, p.review_count,
                    COALESCE(s.match_score, 0) AS match_score,
                    COUNT(ps.id) AS tag_count
             FROM products p
             LEFT JOIN scores s ON s.product_id = p.id
             LEFT JOIN post_sticker ps ON ps.product_id = p.id
             WHERE ($2::text IS NULL OR p.category = $2)
             GROUP BY p.id, s.match_score
             ORDER BY COALESCE(s.match_score, 0) DESC, p.review_count DESC NULLS LAST, tag_count DESC, p.id ASC
             LIMIT $1`,
            [limitInt, category || null, userId]
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
