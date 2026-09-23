// products 테이블 중 embedding이 비어있는 상품에 CLIP 임베딩을 채워 넣는 배치 스크립트.
// docker-compose 네트워크 안에서 실행해야 postgres_db/ml_server에 접속 가능하다.
// 사용법: docker compose exec backend node scripts/backfill_embeddings.js
const pool = require("../db");

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || "http://localhost:8000";

async function fetchImageAsBase64(url) {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`이미지 다운로드 실패 (${res.status}): ${url}`);
    const buf = Buffer.from(await res.arrayBuffer());
    return buf.toString("base64");
}

async function embed(imageBase64) {
    const res = await fetch(`${ML_SERVICE_URL}/embed`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ image: imageBase64 }),
    });
    if (!res.ok) throw new Error(`ml_server 호출 실패: ${await res.text()}`);
    return res.json();
}

async function run() {
    try {
        const { rows: products } = await pool.query(
            "SELECT id, name, image FROM products WHERE embedding IS NULL AND image IS NOT NULL"
        );

        console.log(`임베딩 대상 상품 ${products.length}개`);

        for (const product of products) {
            try {
                const imageBase64 = await fetchImageAsBase64(product.image);
                const { embedding, model_version } = await embed(imageBase64);
                const vectorLiteral = `[${embedding.join(",")}]`;

                await pool.query(
                    "UPDATE products SET embedding = $1::vector, model_version = $2 WHERE id = $3",
                    [vectorLiteral, model_version, product.id]
                );

                console.log(`완료 (${product.id}): ${product.name}`);
            } catch (err) {
                console.error(`실패 (${product.id}): ${product.name} - ${err.message}`);
            }
        }
    } finally {
        await pool.end();
    }
}

run();
