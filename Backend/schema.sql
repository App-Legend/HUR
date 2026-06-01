-- HUR 프로젝트 MySQL DDL
-- Generated for MySQL 8.0+

CREATE DATABASE IF NOT EXISTS hur_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE hur_test;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
  user_id       INT          NOT NULL AUTO_INCREMENT,
  email         VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name          VARCHAR(100) NOT NULL,
  nickname      VARCHAR(100) NOT NULL,
  profile_image VARCHAR(500) NULL,
  bio           TEXT         NULL,
  gender        VARCHAR(10)  NULL,
  birth_date    DATE         NULL,
  personal_color VARCHAR(50) NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 게시글 테이블
CREATE TABLE IF NOT EXISTS posts (
  post_id      INT          NOT NULL AUTO_INCREMENT,
  user_id      INT          NOT NULL,
  title        VARCHAR(255) NOT NULL,
  post_content TEXT         NULL,
  post_image   VARCHAR(500) NULL,
  post_like    INT          NOT NULL DEFAULT 0,
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id),
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 게시글 카테고리 태그 테이블 (퍼스널컬러 / 분위기 / 피부톤)
CREATE TABLE IF NOT EXISTS post_category (
  id             INT         NOT NULL AUTO_INCREMENT,
  post_id        INT         NOT NULL,
  category_type  VARCHAR(50) NOT NULL COMMENT 'personal_color | mood | skin_tone',
  category_value VARCHAR(100) NOT NULL,
  created_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_post_category_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 게시글 제품 스티커 테이블 (이미지 위 좌표 + 상품 정보)
CREATE TABLE IF NOT EXISTS post_sticker (
  id           INT            NOT NULL AUTO_INCREMENT,
  post_id      INT            NOT NULL,
  x_ratio      DECIMAL(5, 3)  NOT NULL COMMENT '이미지 내 X 좌표 비율 (0.000 ~ 1.000)',
  y_ratio      DECIMAL(5, 3)  NOT NULL COMMENT '이미지 내 Y 좌표 비율 (0.000 ~ 1.000)',
  brand_name   VARCHAR(100)   NOT NULL,
  product_name VARCHAR(255)   NOT NULL,
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_post_sticker_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 유저 카테고리 스코어 테이블 (추천 알고리즘용)
CREATE TABLE IF NOT EXISTS user_category_score (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  user_id        INT          NOT NULL,
  category_type  VARCHAR(20)  NOT NULL,
  category_value VARCHAR(100) NOT NULL,
  score          INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ucs_user_category (user_id, category_type, category_value),
  CONSTRAINT fk_ucs_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 인덱스
CREATE INDEX idx_posts_user_id    ON posts         (user_id);
CREATE INDEX idx_posts_created_at ON posts         (created_at);
CREATE INDEX idx_post_category_post_id ON post_category (post_id);
CREATE INDEX idx_post_sticker_post_id  ON post_sticker  (post_id);
CREATE INDEX idx_ucs_user_id           ON user_category_score (user_id);
