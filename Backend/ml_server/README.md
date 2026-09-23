# HUR ML Server

사용자가 올린 '추구미' 레퍼런스 사진과 상품 이미지를 CLIP(ViT-B/32) 임베딩으로 변환하는 FastAPI 서비스.
`Backend/node_server`의 `productController.js`(`recommendByImage`)가 `/embed`를 호출해 벡터를 받은 뒤,
Postgres(pgvector)에서 코사인 유사도로 가장 가까운 상품을 찾는다.

docker-compose로 실행하면 `ml_server`라는 이름으로 백엔드와 같은 네트워크에 뜬다 (외부에 포트 노출 안 함, 백엔드만 내부 통신).

## 로컬(도커 없이) 실행

```bash
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

첫 실행 시 CLIP 사전학습 가중치를 다운로드하므로 인터넷 연결이 필요하고 다소 시간이 걸린다.
docker-compose로 띄울 땐 `ml_model_cache` 볼륨에 캐시되어 재시작해도 다시 다운로드하지 않는다.

## 참고

- 임베딩 차원(512)과 `model_version`은 `Backend/database/hur_pg.sql`의 `vector(512)` 컬럼과 반드시 맞아야 한다.
  모델을 바꾸면 마이그레이션도 같이 수정하고 기존 임베딩을 전부 재계산해야 함.
