// 화해 CDN에 핫링크된 상품 이미지를 다운받아 우리 S3 버킷에 올리고,
// products.image를 S3 URL로 교체하는 마이그레이션 스크립트.
// 원본 사이트가 이미지를 내리거나 핫링크를 막으면 깨지는 문제를 근본적으로 해결한다.
// 사용법: docker compose exec backend node scripts/migrate_images_to_s3.js
const path = require('path');
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const pool = require('../db');
const { s3, bucket } = require('../s3');

async function uploadToS3(buffer, key, contentType) {
    await s3.send(new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: buffer,
        ContentType: contentType,
    }));
    return `https://${bucket}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
}

async function run() {
    try {
        // 이미 S3로 옮겨진 건 건너뛰고, 아직 외부 CDN 링크인 것만 대상으로 한다.
        const { rows: products } = await pool.query(
            `SELECT id, name, image FROM products
             WHERE image IS NOT NULL AND image NOT LIKE $1`,
            [`%${process.env.S3_BUCKET_NAME}%`]
        );

        console.log(`마이그레이션 대상 상품 ${products.length}개`);

        for (const product of products) {
            try {
                const res = await fetch(product.image);
                if (!res.ok) throw new Error(`다운로드 실패 (${res.status})`);

                const contentType = res.headers.get('content-type') || 'image/jpeg';
                const buffer = Buffer.from(await res.arrayBuffer());
                const ext = path.extname(new URL(product.image).pathname) || '.jpg';
                const key = `products/${product.id}${ext}`;

                const s3Url = await uploadToS3(buffer, key, contentType);

                await pool.query('UPDATE products SET image = $1 WHERE id = $2', [s3Url, product.id]);

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
