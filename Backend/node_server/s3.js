const path = require('path');
const { S3Client } = require('@aws-sdk/client-s3');
const multerS3 = require('multer-s3');

const s3 = new S3Client({ region: process.env.AWS_REGION });
const bucket = process.env.S3_BUCKET_NAME;

// prefix: 's3 안에서 어느 폴더에 저장할지 (예: 'posts', 'profiles')
function s3Storage(prefix) {
    return multerS3({
        s3,
        bucket,
        contentType: multerS3.AUTO_CONTENT_TYPE,
        key: (req, file, cb) => {
            const ext = path.extname(file.originalname);
            cb(null, `${prefix}/${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`);
        },
    });
}

module.exports = { s3, bucket, s3Storage };
