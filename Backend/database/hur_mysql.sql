-- HUR 프로젝트 MySQL DDL
-- Generated for MySQL 8.0+

CREATE DATABASE IF NOT EXISTS hur_test
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE hur_test;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
  user_id          INT          NOT NULL AUTO_INCREMENT,
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
  aesthetic_tag    VARCHAR(20)  NULL,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_email    (email),
  UNIQUE KEY uq_users_nickname (nickname)
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

-- 게시글 제품 스티커 테이블 (이미지 위 좌표 + 상품 FK)
CREATE TABLE IF NOT EXISTS post_sticker (
  id           INT            NOT NULL AUTO_INCREMENT,
  post_id      INT            NOT NULL,
  product_id   INT            NOT NULL,
  x_ratio      DECIMAL(5, 3)  NOT NULL COMMENT '이미지 내 X 좌표 비율 (0.000 ~ 1.000)',
  y_ratio      DECIMAL(5, 3)  NOT NULL COMMENT '이미지 내 Y 좌표 비율 (0.000 ~ 1.000)',
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_post_sticker_post    FOREIGN KEY (post_id)    REFERENCES posts    (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_sticker_product FOREIGN KEY (product_id) REFERENCES products (id)      ON DELETE RESTRICT
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

-- 팔로우 테이블
CREATE TABLE IF NOT EXISTS follow (
  follower_id  INT      NOT NULL,
  following_id INT      NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, following_id),
  CONSTRAINT fk_follow_follower  FOREIGN KEY (follower_id)  REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_follow_following FOREIGN KEY (following_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 좋아요 테이블
CREATE TABLE IF NOT EXISTS post_likes (
  like_id    INT       NOT NULL AUTO_INCREMENT,
  post_id    INT       NOT NULL,
  user_id    INT       NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (like_id),
  UNIQUE KEY uq_post_likes (post_id, user_id),
  CONSTRAINT fk_post_likes_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_likes_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글 테이블
CREATE TABLE IF NOT EXISTS post_comments (
  comment_id INT          NOT NULL AUTO_INCREMENT,
  post_id    INT          NOT NULL,
  user_id    INT          NOT NULL,
  content    TEXT         NOT NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (comment_id),
  CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
  CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 제품 테이블
CREATE TABLE IF NOT EXISTS products (
  id     INT          NOT NULL AUTO_INCREMENT,
  brand  VARCHAR(100) NULL,
  name   TEXT         NOT NULL,
  image  TEXT         NULL,
  source VARCHAR(50)  NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 인덱스 (없을 때만 생성)
DROP PROCEDURE IF EXISTS _create_index_if_not_exists;
DELIMITER $$
CREATE PROCEDURE _create_index_if_not_exists(
    IN tbl  VARCHAR(100),
    IN idx  VARCHAR(100),
    IN cols VARCHAR(200)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = tbl
          AND INDEX_NAME   = idx
    ) THEN
        SET @sql = CONCAT('CREATE INDEX ', idx, ' ON ', tbl, ' (', cols, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL _create_index_if_not_exists('posts',              'idx_posts_user_id',          'user_id');
CALL _create_index_if_not_exists('posts',              'idx_posts_created_at',       'created_at');
CALL _create_index_if_not_exists('post_category',      'idx_post_category_post_id',  'post_id');
CALL _create_index_if_not_exists('post_sticker',       'idx_post_sticker_post_id',   'post_id');
CALL _create_index_if_not_exists('user_category_score','idx_ucs_user_id',            'user_id');
CALL _create_index_if_not_exists('follow',             'idx_follow_follower_id',     'follower_id');
CALL _create_index_if_not_exists('follow',             'idx_follow_following_id',    'following_id');

DROP PROCEDURE IF EXISTS _create_index_if_not_exists;

-- 제품 기본 데이터
INSERT IGNORE INTO products (id, brand, name, image, source) VALUES
(1,  '다이브',            '쥬베 립 세럼 [01 쥬 로즈]',                                'https://img.hwahae.co.kr/products/2194994/2194994_20260319152024.jpg?size=80x80', 'hwahae'),
(2,  '토리든',            '솔리드인 세라마이드 립 에센스',                             'https://img.hwahae.co.kr/products/1917897/1917897_20220801000000.jpg?size=80x80', 'hwahae'),
(3,  '시드물',            '호호바 립 에센스 [원료향]',                                 'https://img.hwahae.co.kr/products/1918116/1918116_20240308143024.jpg?size=80x80', 'hwahae'),
(4,  '라네즈',            '립 슬리핑 마스크 EX [베리]',                               'https://img.hwahae.co.kr/products/1984180/1984180_20220801000000.jpg?size=80x80', 'hwahae'),
(5,  '브링그린',          '대나무히알루 립에센스',                                     'https://img.hwahae.co.kr/products/2101095/2101095_20240610180832.jpg?size=80x80', 'hwahae'),
(6,  '토리든',            '셀메이징 저분자 콜라겐 볼륨 립 에센스',                    'https://img.hwahae.co.kr/products/2160461/2160461_20250829134926.jpg?size=80x80', 'hwahae'),
(7,  '이니스프리',        '유채꿀립밤 [초보습]',                                       'https://img.hwahae.co.kr/products/1866314/1866314_20240412143851.jpg?size=80x80', 'hwahae'),
(8,  '페리페라',          '잉크 무드 글로이 틴트 [005 어쩔체리]',                     'https://img.hwahae.co.kr/products/1997322/1997322_20220801000000.jpg?size=80x80', 'hwahae'),
(9,  '바이오더마',        '아토덤 립스틱',                                             'https://img.hwahae.co.kr/products/2032327/2032327_20230405145434.jpg?size=80x80', 'hwahae'),
(10, '아이소이',          '립 트리트먼트 밤 [퓨어레드]',                              'https://img.hwahae.co.kr/products/1979445/1979445_20220801000000.jpg?size=80x80', 'hwahae'),
(11, '헤라',              '센슈얼 누드 글로스 [422호 란제리]',                        'https://img.hwahae.co.kr/products/2024986/2024986_20230302181105.jpg?size=80x80', 'hwahae'),
(12, '비플레인',          '밀크 세라마이드 립 에센스',                                 'https://img.hwahae.co.kr/products/2121361/2121361_20241107114135.jpg?size=80x80', 'hwahae'),
(13, '에뛰드',            '진저슈가 오버나이트 립 마스크',                             'https://img.hwahae.co.kr/products/2075264/2075264_20231107095209.jpg?size=80x80', 'hwahae'),
(14, '아토팜',            '판테놀 립세라',                                             'https://img.hwahae.co.kr/products/2100260/2100260_20240603150145.jpg?size=80x80', 'hwahae'),
(15, '토코보',            '비타 글레이즈드 립 마스크',                                 'https://img.hwahae.co.kr/products/2048814/2048814_20230629103740.jpg?size=80x80', 'hwahae'),
(16, '유이크',            '바이옴 베리어 모이스처 멜팅 립밤 [로지]',                  'https://img.hwahae.co.kr/products/2077408/2077408_20231113170226.jpg?size=80x80', 'hwahae'),
(17, '아누아',            'PDRN 립 세럼',                                              'https://img.hwahae.co.kr/products/2176392/2176392_20251208134739.jpg?size=80x80', 'hwahae'),
(18, '힌스',              '로 글로우 젤 틴트 [02 로 로즈]',                           'https://img.hwahae.co.kr/products/2093258/2093258_20240402115947.jpg?size=80x80', 'hwahae'),
(19, '아이소이',          '립 트리트먼트 로즈립밤 [로지코랄]',                        'https://img.hwahae.co.kr/products/2117711/2117711_20250109170748.jpg?size=80x80', 'hwahae'),
(20, '롬앤',              '글래스팅 멜팅 밤 [06 카야 피그]',                          'https://img.hwahae.co.kr/products/2016925/2016925_20221129111807.jpg?size=80x80', 'hwahae'),
(21, '페리페라',          '약과몰입 컬렉션 잉크 무드 글로이 틴트 [020 당맛도리]',     'https://img.hwahae.co.kr/products/2068570/2068570_20260120121441.jpg?size=80x80', 'hwahae'),
(22, '바세린',            '(유니레버) 립 테라피 미니자 립밤 [오리지널]',              'https://img.hwahae.co.kr/products/1996163/1996163_20220801000000.jpg?size=80x80', 'hwahae'),
(23, '아이소이',          '립 트리트먼트 로즈립밤 [베리로즈]',                        'https://img.hwahae.co.kr/products/2117708/2117708_20250109173540.jpg?size=80x80', 'hwahae'),
(24, '컬러그램',          '탕후루 탱글 틴트 밀크 [03 행복숭아]',                      'https://img.hwahae.co.kr/products/2133286/2133286_20250225152553.jpg?size=80x80', 'hwahae'),
(25, '일리윤',            '세라마이드 무향 비건 립밤',                                 'https://img.hwahae.co.kr/products/2167225/2167225_20251013143217.jpg?size=80x80', 'hwahae'),
(26, '블리스텍스',        '립메덱스',                                                  'https://img.hwahae.co.kr/products/1828972/1828972_20220801000000.jpg?size=80x80', 'hwahae'),
(27, '클리오',            '크리스탈 글램틴트 [3호 블러쉬드피치]',                     'https://img.hwahae.co.kr/products/2043627/2043627_20230605104410.jpg?size=80x80', 'hwahae'),
(28, '이니스프리',        '듀이 틴트 립밤 [4호 로즈브릭]',                            'https://img.hwahae.co.kr/products/1983578/1983578_20230420155330.jpg?size=80x80', 'hwahae'),
(29, '삐아',              '오버 글레이즈 [06 땅콩당]',                                 'https://img.hwahae.co.kr/products/2117093/2117093_20240924115558.jpg?size=80x80', 'hwahae'),
(30, '아이소이',          '립 트리트먼트 로즈립밤 [선셋오렌지]',                      'https://img.hwahae.co.kr/products/2117709/2117709_20250109173119.jpg?size=80x80', 'hwahae'),
(31, '시드물',            '호호바 립 에센스 [오렌지향]',                               'https://img.hwahae.co.kr/products/2058351/2058351_20230810141405.jpg?size=80x80', 'hwahae'),
(32, '일리윤',            '세라마이드 무향 립밤',                                      'https://img.hwahae.co.kr/products/1917887/1917887_20220801000000.jpg?size=80x80', 'hwahae'),
(33, '클리오',            '벨벳 립펜슬 [2호 피치베이지]',                             'https://img.hwahae.co.kr/products/2063649/2063649_20230905133755.jpg?size=80x80', 'hwahae'),
(34, '피지오겔',          'DMT 마일드 립밤',                                           'https://img.hwahae.co.kr/products/1899939/1899939_20221102111609.jpg?size=80x80', 'hwahae'),
(35, '헤라',              '센슈얼 누드 글로스 [102호 플러티]',                        'https://img.hwahae.co.kr/products/2114348/2114348_20240827110115.jpg?size=80x80', 'hwahae'),
(36, '헤라',              '센슈얼 누드 글로스 [380호 체리쉬]',                        'https://img.hwahae.co.kr/products/2114351/2114351_20240827110607.jpg?size=80x80', 'hwahae'),
(37, '에뛰드',            '픽싱 틴트 [#5 미드나잇모브]',                              'https://img.hwahae.co.kr/products/1932268/1932268_20241210102035.jpg?size=80x80', 'hwahae'),
(38, '토니모리',          '퍼펙트립스 쇼킹립 틴트 [N13 애프리콧쇼킹]',               'https://img.hwahae.co.kr/products/2135937/2135937_20250324154944.jpg?size=80x80', 'hwahae'),
(39, '롬앤',              '글래스팅 컬러 글로스 [01 피오니발레]',                     'https://img.hwahae.co.kr/products/2082587/2082587_20231215094333.jpg?size=80x80', 'hwahae'),
(40, '유리아쥬',          '스틱레브르 오리지널',                                       'https://img.hwahae.co.kr/products/7570/7570_20220801000000.jpg?size=80x80',       'hwahae'),
(41, '롬앤',              '듀이풀 워터 틴트 [13 커스터드모브]',                       'https://img.hwahae.co.kr/products/2012926/2012926_20260430113108.jpg?size=80x80', 'hwahae'),
(42, '시드물',            '토마토 립 틴트',                                            'https://img.hwahae.co.kr/products/2032338/2032338_20230405153411.jpg?size=80x80', 'hwahae'),
(43, '닥터브로너스',      '오가닉 립밤 [베이비마일드]',                                'https://img.hwahae.co.kr/products/1793222/1793222_20220801000000.jpg?size=80x80', 'hwahae'),
(44, '클리오',            '벨벳 립펜슬 [10호 코지누드]',                              'https://img.hwahae.co.kr/products/2161254/2161254_20250903154332.jpg?size=80x80', 'hwahae'),
(45, '네이처리퍼블릭',    '에센셜 립밤 [5호 장미]',                                   'https://img.hwahae.co.kr/products/2105813/2105813_20240709094549.jpg?size=80x80', 'hwahae'),
(46, '클리오',            '애플 시리즈 크리스탈 글램틴트 [20 바닐라애플]',            'https://img.hwahae.co.kr/products/2130877/2130877_20250204141306.jpg?size=80x80', 'hwahae'),
(47, '롬앤',              '블러 퍼지 틴트 [06 모비쉬]',                               'https://img.hwahae.co.kr/products/2009377/2009377_20220823142725.jpg?size=80x80', 'hwahae'),
(48, '클리오',            '크리스탈 글램틴트 [1호 빈티지애플]',                       'https://img.hwahae.co.kr/products/2043625/2043625_20230605104357.jpg?size=80x80', 'hwahae'),
(49, '유이크',            '바이옴 베리어 모이스처 멜팅 립밤 [오리지널]',              'https://img.hwahae.co.kr/products/2077405/2077405_20231113170011.jpg?size=80x80', 'hwahae'),
(50, '컬러그램',          '누디 블러 틴트 [07 긱로즈]',                               'https://img.hwahae.co.kr/products/2116511/2116511_20250811140853.jpg?size=80x80', 'hwahae'),
(51, '이니스프리',        '유채꿀 립밤',                                               'https://img.hwahae.co.kr/products/1869530/1869530_20230907155216.jpg?size=80x80', 'hwahae'),
(52, '토코보',            '민트 쿨링 립 마스크',                                       'https://img.hwahae.co.kr/products/2118955/2118955_20241014152758.jpg?size=80x80', 'hwahae'),
(53, '페리페라',          '잉크 무드 글로이 틴트 [2호 손웜수템]',                     'https://img.hwahae.co.kr/products/1997319/1997319_20220801000000.jpg?size=80x80', 'hwahae'),
(54, '유리아쥬',          '오떼르말 스틱 레브르 립밤',                                 'https://img.hwahae.co.kr/products/2058085/2058085_20230808155617.jpg?size=80x80', 'hwahae'),
(55, '페리페라',          '잉크 무드 글로이 틴트 [003 맘찍로즈]',                     'https://img.hwahae.co.kr/products/2089958/2089958_20241217104918.jpg?size=80x80', 'hwahae'),
(56, '라네즈',            '글레이즈 크레이즈 틴티드 립 세럼 [메이플 글레이즈]',      'https://img.hwahae.co.kr/products/2139483/2139483_20250422122456.jpg?size=80x80', 'hwahae'),
(57, '삐아',              'MLBB 에디션 글로우 틴트 [14 데일리보틀]',                  'https://img.hwahae.co.kr/products/2106206/2106206_20240710135331.jpg?size=80x80', 'hwahae'),
(58, '샤넬',              '루쥬 코코 플래쉬 [90호 쥬르]',                             'https://img.hwahae.co.kr/products/1828841/1828841_20220801000000.jpg?size=80x80', 'hwahae'),
(59, '페리페라',          '페리복권 컬렉션 잉크 무드 글로이 틴트 [23호 쩡신차렷]',   'https://img.hwahae.co.kr/products/2084596/2084596_20240103103550.jpg?size=80x80', 'hwahae'),
(60, '클리오',            '냥생역전 코숏 에디션 크리스탈 글램틴트 [14호 하트핑크다이아]', 'https://img.hwahae.co.kr/products/2100477/2100477_20240604170201.jpg?size=80x80', 'hwahae'),
(61, '이니스프리',        '듀이 틴트 립밤 [1호 베이비핑크]',                          'https://img.hwahae.co.kr/products/1983574/1983574_20230420154648.jpg?size=80x80', 'hwahae'),
(62, '3CE',               '소프트 매트 립스틱 [웨이 백]',                              'https://img.hwahae.co.kr/products/1917150/1917150_20220801000000.jpg?size=80x80', 'hwahae'),
(63, '롬앤',              '제로 매트 립스틱 [10 핑크샌드]',                            'https://img.hwahae.co.kr/products/1962959/1962959_20220801000000.jpg?size=80x80', 'hwahae'),
(64, '입생로랑뷰티',      '러브샤인 워터샤인 립스틱 [209 핑크디자이어]',              'https://img.hwahae.co.kr/products/2090341/2090341_20240313103917.jpg?size=80x80', 'hwahae'),
(65, '얼터너티브스테레오','립 포션 슈가 글레이즈 틴트 [2호 로즈볼]',                 'https://img.hwahae.co.kr/products/2118865/2118865_20241014094442.jpg?size=80x80', 'hwahae'),
(66, '스킨푸드',          '아보카도 스틱 립밤 [1호 리치]',                             'https://img.hwahae.co.kr/products/1961733/1961733_20230919171934.jpg?size=80x80', 'hwahae'),
(67, '에스쁘아',          '노웨어 립스틱 바밍글로우 [7호 애쉬메이플]',                'https://img.hwahae.co.kr/products/2087388/2087388_20240213114722.jpg?size=80x80', 'hwahae'),
(68, '릴리바이레드',      '스윗 라이어 밀키 틴트 [04 복숭아 푸딩인 척]',              'https://img.hwahae.co.kr/products/2097058/2097058_20240508113657.jpg?size=80x80', 'hwahae'),
(69, '한율',              '자연을 닮은 립밤 [자초]',                                   'https://img.hwahae.co.kr/products/2032352/2032352_20230405164047.jpg?size=80x80', 'hwahae'),
(70, '더마토리',          '히알루론 펩타이드 밤 [볼륨립마스크]',                       'https://img.hwahae.co.kr/products/2124697/2124697_20241202142349.jpg?size=80x80', 'hwahae'),
(71, '토니모리',          '퍼펙트립스 쇼킹립 틴트 [01 루비쇼킹]',                    'https://img.hwahae.co.kr/products/2101309/2101309_20240617161002.jpg?size=80x80', 'hwahae'),
(72, '에뛰드',            '진저슈가 립 세럼 [03 누디 베이지]',                        'https://img.hwahae.co.kr/products/2170355/2170355_20251103115326.jpg?size=80x80', 'hwahae'),
(73, '버츠비',            '틴티드립밤 [로즈]',                                         'https://img.hwahae.co.kr/products/2067137/2067137_20230922161012.jpg?size=80x80', 'hwahae'),
(74, '에스쁘아',          '꾸뛰르 립틴트 글레이즈 [3호 칠링칠링]',                   'https://img.hwahae.co.kr/products/2084097/2084097_20250210142537.jpg?size=80x80', 'hwahae'),
(75, '퓌',                '3D 볼류밍 글로스 [B10 요거트70%]',                          'https://img.hwahae.co.kr/products/2136810/2136810_20250401110756.jpg?size=80x80', 'hwahae'),
(76, '릴리바이레드',      '스윗 라이어 밀키 틴트 [09 무화과토스트인척]',              'https://img.hwahae.co.kr/products/2115495/2115495_20240904144830.jpg?size=80x80', 'hwahae'),
(77, '클리오',            '크리스탈 글램틴트 [6호 데일리모브]',                       'https://img.hwahae.co.kr/products/2043630/2043630_20230605104428.jpg?size=80x80', 'hwahae'),
(78, '리얼베리어',        '익스트림 모이스처 립밤',                                    'https://img.hwahae.co.kr/products/1994017/1994017_20240202100545.jpg?size=80x80', 'hwahae'),
(79, '라부르켓',          'SOS 립 밤',                                                 'https://img.hwahae.co.kr/products/2119135/2119135_20241016135354.jpg?size=80x80', 'hwahae'),
(80, '헤라',              '센슈얼 누드 밤 [112호 본프리]',                             'https://img.hwahae.co.kr/products/2128973/2128973_20250109081100.jpg?size=80x80', 'hwahae');
