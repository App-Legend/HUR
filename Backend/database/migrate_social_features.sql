-- 홈 피드 새로고침/북마크/알림/차단·신고/조회 기록/제품 표시 기능에 필요한 테이블을 한 번에 만든다.
-- 여러 번 실행해도 안전하다 (IF NOT EXISTS). 서버 코드를 배포하기 "전에" 실행할 것.
-- 사용법: docker compose exec -T postgres_db psql -U app_legend -d Hur < Backend/database/migrate_social_features.sql

-- 북마크
CREATE TABLE IF NOT EXISTS post_bookmarks (
  bookmark_id SERIAL    NOT NULL,
  post_id     INT       NOT NULL,
  user_id     INT       NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (bookmark_id),
  CONSTRAINT uq_post_bookmarks      UNIQUE (post_id, user_id),
  CONSTRAINT fk_post_bookmarks_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_bookmarks_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_post_bookmarks_user ON post_bookmarks (user_id, created_at DESC);

-- 알림
CREATE TABLE IF NOT EXISTS notifications (
  notification_id SERIAL      NOT NULL,
  user_id         INT         NOT NULL,
  actor_id        INT         NOT NULL,
  type            VARCHAR(20) NOT NULL,
  post_id         INT,
  is_read         BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notification_id),
  CONSTRAINT fk_notifications_user  FOREIGN KEY (user_id)  REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_notifications_actor FOREIGN KEY (actor_id) REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_notifications_post  FOREIGN KEY (post_id)  REFERENCES posts (post_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications (user_id, created_at DESC);

-- 차단/제한
CREATE TABLE IF NOT EXISTS user_blocks (
  block_id   SERIAL      NOT NULL,
  blocker_id INT         NOT NULL,
  blocked_id INT         NOT NULL,
  kind       VARCHAR(10) NOT NULL DEFAULT 'block',
  created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (block_id),
  CONSTRAINT uq_user_blocks UNIQUE (blocker_id, blocked_id),
  CONSTRAINT fk_user_blocks_blocker FOREIGN KEY (blocker_id) REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_user_blocks_blocked FOREIGN KEY (blocked_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 게시물 신고
CREATE TABLE IF NOT EXISTS post_reports (
  report_id   SERIAL       NOT NULL,
  post_id     INT          NOT NULL,
  reporter_id INT          NOT NULL,
  reason      VARCHAR(50)  NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (report_id),
  CONSTRAINT uq_post_reports UNIQUE (post_id, reporter_id),
  CONSTRAINT fk_post_reports_post     FOREIGN KEY (post_id)     REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_reports_reporter FOREIGN KEY (reporter_id) REFERENCES users (user_id) ON DELETE CASCADE
);

-- 조회 기록
CREATE TABLE IF NOT EXISTS post_views (
  user_id   INT       NOT NULL,
  post_id   INT       NOT NULL,
  viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  CONSTRAINT fk_post_views_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_views_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_post_views_user ON post_views (user_id, viewed_at DESC);

-- 제품 표시 (찜 / 내 화장품 / 덜 보기)
CREATE TABLE IF NOT EXISTS user_products (
  user_id    INT         NOT NULL,
  product_id INT         NOT NULL,
  kind       VARCHAR(10) NOT NULL,
  created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id, kind),
  CONSTRAINT fk_user_products_user    FOREIGN KEY (user_id)    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_user_products_product FOREIGN KEY (product_id) REFERENCES products (id)   ON DELETE CASCADE
);
