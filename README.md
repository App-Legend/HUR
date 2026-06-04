# HUR 🪞

> 나에게 어울리는 메이크업을 탐색하고, 추구미에 가까워지도록 도와주는 뷰티 커뮤니티 앱

<br>

## 📱 소개

**HUR**은 퍼스널 컬러와 추구하는 스타일을 기반으로 화장품을 추천받고,  
다른 사용자들의 메이크업 피드를 탐색하며 나만의 뷰티 스타일을 찾아가는 앱입니다.

<br>

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 온보딩 | 퍼스널 컬러 · 피부톤 · 추구 스타일 설정 |
| 홈 피드 | 팔로잉 기반 메이크업 게시물 탐색 |
| 랭킹 | 카테고리별(틴트·렌즈·볼터치·섀도우) 화장품 랭킹 TOP20 |
| 검색 | 화장품 이름/브랜드 검색 · 계정 검색 |
| 업로드 | 메이크업 사진 + 사용 화장품 태그 게시 |
| 프로필 | 내 피드 · 팔로워/팔로잉 관리 |
| 비회원 | 로그인 없이 홈 화면 둘러보기 가능 |

<br>

## 🛠 기술 스택

### Frontend
- **Flutter** (Dart)
- `http` — REST API 통신
- `shared_preferences` — 로컬 토큰 저장
- `image_picker` — 이미지 업로드
- `material_symbols_icons` — 아이콘

### Backend
- **Node.js** + **Express.js**
- **PostgreSQL** — 메인 데이터베이스
- `bcrypt` — 비밀번호 암호화
- `jsonwebtoken` — JWT 인증
- `multer` — 이미지 파일 업로드

<br>

## 🗂 프로젝트 구조

```
HUR/
├── Frontend/
│   └── hur_app/                  # Flutter 앱
│       └── lib/
│           ├── app/
│           │   ├── config/       # API 서버 주소 설정
│           │   └── extensions/
│           └── ui/
│               ├── common/       # 공통 위젯 (헤더, 버튼 등)
│               └── pages/
│                   ├── home/     # 홈 피드
│                   ├── login/    # 로그인 · 회원가입
│                   ├── onboarding/
│                   ├── profile/  # 마이페이지 · 프로필
│                   ├── ranking/  # 화장품 랭킹
│                   ├── search/   # 검색
│                   └── upload/   # 게시물 업로드
│
└── Backend/
    ├── node_server/
    │   ├── routes/
    │   │   ├── auth.js           # 로그인 · 회원가입
    │   │   ├── user.js           # 유저 · 마이페이지
    │   │   ├── follow.js         # 팔로우 · 언팔로우
    │   │   ├── upload.js         # 이미지 업로드
    │   │   └── product.js        # 화장품 랭킹 · 검색
    │   ├── server.js
    │   └── db.js
    └── database/
        └── hur_db.sql            # DB 스키마 및 데이터 덤프
```

<br>

## 🗄 주요 API

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/login` | 로그인 |
| POST | `/signup` | 회원가입 |
| POST | `/logout` | 로그아웃 |
| GET | `/user/:id` | 유저 프로필 조회 |
| GET | `/user/search/users?q=` | 계정 검색 |
| POST | `/user/:id/follow` | 팔로우 |
| DELETE | `/user/:id/follow` | 언팔로우 |
| POST | `/upload` | 게시물 이미지 업로드 |
| GET | `/products/ranking?limit=20` | 화장품 랭킹 조회 |
| GET | `/products/search?q=` | 화장품 검색 |

<br>

## 🚀 실행 방법

### 1. 백엔드 서버

```bash
cd Backend/node_server
npm install
node server.js
# → http://localhost:3000
```

### 2. Flutter 앱

서버 주소 설정 — `Frontend/hur_app/lib/app/config/api_config.dart`
```dart
// 에뮬레이터: 'http://10.0.2.2:3000'
// 실제 기기:  'http://컴퓨터_WiFi_IP:3000'
const String baseUrl = 'http://10.0.2.2:3000';
```

```bash
cd Frontend/hur_app
flutter pub get
flutter run
```

### 3. 데이터베이스 복원 (선택)

```bash
psql -U postgres -d postgres -f Backend/database/hur_db.sql
```

<br>

## 📋 환경 요구사항

- Flutter SDK `^3.11.1`
- Node.js `18+`
- PostgreSQL `13+`

<br>

## 👥 팀

**App-Legend** — HUR 개발팀
