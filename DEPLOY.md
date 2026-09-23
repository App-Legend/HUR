# VPS 배포 가이드 (HTTP, 도메인 없음)

SSH로 VPS에 접속 가능한 사람이 따라하면 되는 절차입니다.

## 1. 사전 준비 (최초 1회)

VPS에 Docker + Docker Compose가 설치되어 있어야 합니다.

```bash
# Docker 설치 여부 확인
docker --version
docker compose version
```

없다면: https://docs.docker.com/engine/install/ 참고해서 설치.

## 2. 코드 가져오기

```bash
git clone https://github.com/App-Legend/HUR.git
cd HUR
git checkout feature   # 배포할 브랜치
```

이미 clone되어 있다면:

```bash
cd HUR
git pull origin feature
```

## 3. 비밀값 설정 (최초 1회, 이후엔 유지됨)

저장소 루트에 `.env` 파일을 만듭니다 (git에는 안 올라가는 파일이니 서버에서 직접 생성).

```bash
cp .env.example .env
```

`.env`를 열어서 실제 값으로 채우기:

```
DB_PASSWORD=<원하는 안전한 비밀번호>
JWT_SECRET=<랜덤한 긴 문자열, 예: openssl rand -hex 32 로 생성>
AWS_ACCESS_KEY_ID=<S3 전용 IAM 사용자의 Access Key>
AWS_SECRET_ACCESS_KEY=<S3 전용 IAM 사용자의 Secret Key>
AWS_REGION=ap-northeast-2
S3_BUCKET_NAME=<이미지 저장용 S3 버킷 이름>
```

S3 버킷은 AWS 콘솔에서 미리 만들어져 있어야 합니다 (퍼블릭 읽기 허용 + 이 IAM 사용자에게 해당 버킷 PutObject/GetObject 권한).

## 4. 컨테이너 빌드 및 실행

```bash
docker compose up -d --build
```

이 명령 하나로 nginx + node 백엔드 + postgres(pgvector) + ml_server(CLIP 임베딩) 4개 컨테이너가 뜹니다.

## 5. DB 스키마 적용 (최초 1회)

컨테이너가 뜬 뒤, postgres 컨테이너 안에서 SQL 파일을 실행합니다.

```bash
docker compose exec -T postgres_db psql -U app_legend -d Hur < Backend/database/hur_pg.sql
docker compose exec -T postgres_db psql -U app_legend -d Hur < Backend/database/hur_pg_seed.sql
```

## 6. 상품 임베딩 채우기 (최초 1회, 상품 추가될 때마다)

`products` 테이블에 이미지는 있는데 벡터(embedding)가 없는 상품들을 CLIP으로 임베딩합니다.
ml_server가 뜬 상태에서 실행해야 합니다.

```bash
docker compose exec backend node scripts/backfill_embeddings.js
```

## 7. 기존 상품 이미지를 S3로 이전 (최초 1회)

시드 데이터의 상품 이미지가 외부 CDN(화해) 핫링크라 깨지기 쉬워요. 우리 S3로 옮깁니다.

```bash
docker compose exec backend node scripts/migrate_images_to_s3.js
```

## 8. 정상 동작 확인

```bash
curl http://localhost/products/ranking
```

상품 목록 JSON이 나오면 정상입니다. 외부에서는 `http://<VPS의 IP 주소>/products/ranking`로 접속해서 확인하면 됩니다 (도메인 없이 IP로 접속, HTTP만 — HTTPS/도메인은 추후 추가 예정).

벡터 추천 엔드포인트 확인 (이미지를 base64로 인코딩해서 보내야 함):

```bash
curl -X POST http://localhost/products/recommend \
  -H "Content-Type: application/json" \
  -d "{\"image\": \"<base64 인코딩된 이미지>\"}"
```

## 9. DB 자동 백업 설정 (최초 1회)

매일 자정 근처에 DB를 덤프해서 S3(`backups/` 폴더)에 저장하도록 설정합니다.

**AWS CLI 설치** (백업 스크립트가 S3 업로드에 사용):
```bash
sudo apt update && sudo apt install -y awscli
```

**스크립트 실행 권한 부여 + 한 번 수동 테스트**:
```bash
chmod +x scripts/backup_db.sh
./scripts/backup_db.sh
```
`[backup] 완료: ...` 로그가 뜨면 성공. AWS 콘솔 S3 버킷의 `backups/` 폴더에 파일이 보이는지 확인.

**cron으로 매일 자동 실행 등록** (새벽 3시):
```bash
crontab -e
```
편집기가 열리면 맨 아래에 아래 줄 추가(`HUR` 경로는 실제 clone된 절대경로로):
```
0 3 * * * cd /home/ubuntu/HUR && ./scripts/backup_db.sh >> /home/ubuntu/hur_backup.log 2>&1
```
저장하고 나오면 등록 완료. `crontab -l`로 등록됐는지 확인 가능.

**(선택) 오래된 백업 자동 삭제** — S3 콘솔 → 버킷 → 관리(Management) 탭 → 수명 주기 규칙(Lifecycle rule) 생성 → `backups/` 접두사에 30일 지난 객체 만료(Expire) 규칙 추가. 안 해두면 백업이 계속 쌓여서 용량이 늘어남(스토리지 비용 자체는 저렴하지만).

## 10. 코드 업데이트 시 (이후 배포마다)

```bash
git pull origin feature
docker compose up -d --build
```

## 문제 생겼을 때

```bash
docker compose logs backend       # 백엔드 로그
docker compose logs ml_server     # 임베딩 서비스 로그
docker compose logs postgres_db   # DB 로그
docker compose ps                 # 컨테이너 상태 확인
```
