#!/bin/bash
# Postgres DB를 덤프해서 S3에 백업하는 스크립트.
# repo 루트에서 실행해야 함 (docker-compose.yml, .env가 있는 위치).
# 사용법: ./scripts/backup_db.sh
# cron으로 매일 자동 실행하도록 DEPLOY.md에 등록 안내되어 있음.
set -euo pipefail

cd "$(dirname "$0")/.."

# .env에서 AWS/DB 자격 정보 불러오기
set -a
source .env
set +a

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="hur_backup_${TIMESTAMP}.sql.gz"
TMP_PATH="/tmp/${BACKUP_FILE}"

echo "[backup] pg_dump 시작: ${TIMESTAMP}"
docker compose exec -T postgres_db pg_dump -U app_legend Hur | gzip > "${TMP_PATH}"

echo "[backup] S3 업로드: s3://${S3_BUCKET_NAME}/backups/${BACKUP_FILE}"
aws s3 cp "${TMP_PATH}" "s3://${S3_BUCKET_NAME}/backups/${BACKUP_FILE}" --region "${AWS_REGION}"

rm -f "${TMP_PATH}"
echo "[backup] 완료: ${BACKUP_FILE}"
