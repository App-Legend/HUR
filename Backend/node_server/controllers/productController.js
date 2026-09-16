const pool = require('../db');

const getRanking = async (req, res) => {
    try {
        const { limit = 20 } = req.query;

        const [rows] = await pool.query(
            `SELECT p.id, p.brand, p.name, p.image, p.source,
                    COUNT(ps.id) AS tag_count
             FROM products p
             LEFT JOIN post_sticker ps ON p.id = ps.product_id
             GROUP BY p.id
             ORDER BY tag_count DESC, p.id ASC
             LIMIT ?`,
            [parseInt(limit)]
        );

        res.json(rows);
    } catch (err) {
        console.error("products/ranking error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

// 상품 검색 API
const searchProducts = async (req, res) => {
    try {
        const { q = "", limit = 20 } = req.query;

        if (!q.trim()) {
            return res.json([]);
        }

        const [rows] = await pool.query(
            `SELECT id, brand, name, image, source
             FROM products
             WHERE name LIKE ? OR brand LIKE ?
             ORDER BY id ASC
             LIMIT ?`,
            [`%${q.trim()}%`, `%${q.trim()}%`, parseInt(limit)]
        );

        res.json(rows);
    } catch (err) {
        console.error("products/search error:", err.message);
        res.status(500).json({ error: err.message });
    }
};

// 상품 상세 조회 API
const getProduct = async (req, res) => {
    try {
        const { id } = req.params;

        const [rows] = await pool.query(
            "SELECT id, brand, name, image, source FROM products WHERE id = ?",
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
