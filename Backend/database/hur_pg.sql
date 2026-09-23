-- HUR 프로젝트 PostgreSQL DDL
-- Generated for PostgreSQL 14+

-- 벡터 유사도 검색용 확장 (docker-compose의 postgres 이미지를 pgvector/pgvector:pg17로 교체해야 사용 가능)
CREATE EXTENSION IF NOT EXISTS vector;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
  user_id          SERIAL       NOT NULL,
  email            VARCHAR(255) NOT NULL,
  password_hash    VARCHAR(255) NOT NULL,
  name             VARCHAR(100) NOT NULL,
  nickname         VARCHAR(100) NULL,
  profile_image    VARCHAR(500) NULL,
  background_image TEXT         NULL,
  bio              TEXT         NULL,
  gender           VARCHAR(10)  NULL,
  birth_date       DATE         NULL,
  personal_color   VARCHAR(50)  NULL,
  skin_tone        VARCHAR(50)  NULL,
  aesthetic_tag    VARCHAR(20)  NULL,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT uq_users_email    UNIQUE (email),
  CONSTRAINT uq_users_nickname UNIQUE (nickname)
);

-- 제품 테이블 (post_sticker FK 참조 전 선언)
CREATE TABLE IF NOT EXISTS products (
  id             SERIAL       NOT NULL,
  brand          VARCHAR(100) NULL,
  name           TEXT         NOT NULL,
  image          TEXT         NULL,
  source         VARCHAR(50)  NULL,
  embedding      vector(512)  NULL,  -- 상품 이미지의 CLIP 임베딩 (벡터 유사도 추천용)
  model_version  VARCHAR(50)  NULL,  -- embedding을 생성한 모델 버전 (모델 교체 시 재계산 대상 식별용)
  PRIMARY KEY (id)
);

-- 게시글 테이블
CREATE TABLE IF NOT EXISTS posts (
  post_id      SERIAL       NOT NULL,
  user_id      INT          NOT NULL,
  title        VARCHAR(255) NOT NULL,
  post_content TEXT         NULL,
  post_image   VARCHAR(500) NULL,
  post_like    INT          NOT NULL DEFAULT 0,
  visibility   VARCHAR(20)  NOT NULL DEFAULT '모든 사람',
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id),
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION fn_update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION fn_update_updated_at();

-- 게시글 카테고리 태그 테이블 (퍼스널컬러 / 분위기 / 피부톤)
CREATE TABLE IF NOT EXISTS post_category (
  id             SERIAL      NOT NULL,
  post_id        INT         NOT NULL,
  category_type  VARCHAR(50) NOT NULL,
  category_value VARCHAR(100) NOT NULL,
  created_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_post_category_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE
);

-- 게시글 제품 스티커 테이블 (이미지 위 좌표 + 상품 FK)
CREATE TABLE IF NOT EXISTS post_sticker (
  id           SERIAL         NOT NULL,
  post_id      INT            NOT NULL,
  product_id   INT            NOT NULL,
  x_ratio      DECIMAL(5, 3)  NOT NULL,
  y_ratio      DECIMAL(5, 3)  NOT NULL,
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_post_sticker_post    FOREIGN KEY (post_id)    REFERENCES posts    (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_sticker_product FOREIGN KEY (product_id) REFERENCES products (id)      ON DELETE RESTRICT
);

-- 유저 카테고리 스코어 테이블 (추천 알고리즘용)
CREATE TABLE IF NOT EXISTS user_category_score (
  id             BIGSERIAL    NOT NULL,
  user_id        INT          NOT NULL,
  category_type  VARCHAR(20)  NOT NULL,
  category_value VARCHAR(100) NOT NULL,
  score          INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  CONSTRAINT uq_ucs_user_category UNIQUE (user_id, category_type, category_value),
  CONSTRAINT fk_ucs_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 팔로우 테이블
CREATE TABLE IF NOT EXISTS follow (
  follower_id  INT       NOT NULL,
  following_id INT       NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, following_id),
  CONSTRAINT fk_follow_follower  FOREIGN KEY (follower_id)  REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_follow_following FOREIGN KEY (following_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 좋아요 테이블
CREATE TABLE IF NOT EXISTS post_likes (
  like_id    SERIAL    NOT NULL,
  post_id    INT       NOT NULL,
  user_id    INT       NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (like_id),
  CONSTRAINT uq_post_likes      UNIQUE (post_id, user_id),
  CONSTRAINT fk_post_likes_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_likes_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 댓글 테이블
CREATE TABLE IF NOT EXISTS post_comments (
  comment_id SERIAL    NOT NULL,
  post_id    INT       NOT NULL,
  user_id    INT       NOT NULL,
  content    TEXT      NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (comment_id),
  CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 사용자가 업로드한 '추구미' 레퍼런스 사진 (알고리즘 입력 로그 + 재사용)
CREATE TABLE IF NOT EXISTS look_reference (
  id         SERIAL       NOT NULL,
  user_id    INT          NULL,
  image      TEXT         NOT NULL,
  embedding  vector(512)  NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_look_reference_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_posts_user_id          ON posts               (user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at       ON posts               (created_at);
CREATE INDEX IF NOT EXISTS idx_post_category_post_id  ON post_category       (post_id);
CREATE INDEX IF NOT EXISTS idx_post_sticker_post_id   ON post_sticker        (post_id);
CREATE INDEX IF NOT EXISTS idx_ucs_user_id            ON user_category_score (user_id);
CREATE INDEX IF NOT EXISTS idx_follow_follower_id     ON follow              (follower_id);
CREATE INDEX IF NOT EXISTS idx_follow_following_id    ON follow              (following_id);
CREATE INDEX IF NOT EXISTS idx_look_reference_user_id ON look_reference      (user_id);

-- 벡터 코사인 유사도 검색 인덱스
-- ivfflat은 lists 값을 데이터 양에 맞춰야 효과적이라(경험적으로 rows/1000, 최소 10),
-- 지금처럼 상품 수가 적을 땐 lists=10으로 시작하고 카탈로그가 커지면 DROP INDEX 후 재생성 권장.
CREATE INDEX IF NOT EXISTS idx_products_embedding_cosine
  ON products
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 10);
