const express = require("express");
const pool = require("../db");

const router = express.Router();

// GET /products/ranking?limit=20
// 크롤링된 products 테이블에서 id 순서대로 랭킹 상품 반환
router.get("/ranking", async (req, res) => {
    try {
        const { limit = 20 } = req.query;

        const result = await pool.query(
            `SELECT id, brand, name, image, source
             FROM products
             ORDER BY id ASC
             LIMIT $1`,
            [parseInt(limit)]
        );

        res.json(result.rows);
    } catch (err) {
        console.error("products/ranking error:", err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /products/search?q=틴트&limit=20
// 이름 또는 브랜드로 상품 검색 (ILIKE 대소문자 무시)
// ※ /:id 보다 반드시 위에 위치해야 express가 먼저 매칭
router.get("/search", async (req, res) => {
    try {
        const { q = "", limit = 20 } = req.query;

        if (!q.trim()) {
            return res.json([]);
        }

        const result = await pool.query(
            `SELECT id, brand, name, image, source
             FROM products
             WHERE name ILIKE $1 OR brand ILIKE $1
             ORDER BY id ASC
             LIMIT $2`,
            [`%${q.trim()}%`, parseInt(limit)]
        );

        res.json(result.rows);
    } catch (err) {
        console.error("products/search error:", err.message);
        res.status(500).json({ error: err.message });
    }
});

// GET /products/:id  — 단일 상품 조회
router.get("/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            "SELECT id, brand, name, image, source FROM products WHERE id = $1",
            [parseInt(id)]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: "상품을 찾을 수 없습니다" });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
