# HUR — Flutter Frontend

> HUR 앱의 Flutter 프론트엔드 프로젝트입니다.

<br>

## 📁 프로젝트 구조

```
lib/
├── app/
│   ├── config/
│   │   └── api_config.dart        # 서버 주소 중앙 관리
│   └── extensions/
│       ├── sized_box_extension.dart
│       └── snackbar_extension.dart
│
└── ui/
    ├── common/                    # 공통 컴포넌트
    │   ├── headers/               # 앱바/헤더
    │   ├── navigation/            # 하단 내비게이션
    │   └── widget/
    │       ├── category_chip.dart         # 카테고리 필터 칩
    │       ├── follow_button.dart         # 팔로우 버튼
    │       ├── product_item_container.dart # 화장품 리스트 아이템
    │       ├── product_more_popup.dart     # 화장품 더보기 팝업
    │       ├── home_post_more_popup.dart   # 피드 더보기 팝업
    │       └── side_drawer.dart            # 사이드 드로어
    │
    └── pages/
        ├── main_page.dart         # 하단 탭 네비게이션 루트
        ├── splash/                # 스플래시 화면
        ├── onboarding/            # 온보딩 (퍼스널컬러·피부톤·추구미)
        ├── login/                 # 로그인 · 회원가입
        ├── home/                  # 홈 피드 · 게시물 상세
        ├── ranking/               # 화장품 랭킹 · 상세
        ├── search/                # 화장품·계정·피드 검색
        ├── upload/                # 사진 업로드 · 화장품 태그
        └── profile/               # 마이페이지 · 프로필 · 설정
```

<br>

## 📦 주요 패키지

| 패키지 | 용도 |
|--------|------|
| `http` | REST API 통신 |
| `shared_preferences` | 로컬 토큰/유저 ID 저장 |
| `image_picker` | 갤러리·카메라 이미지 선택 |
| `material_symbols_icons` | Material 아이콘 |
| `dotted_border` | 점선 테두리 |
| `flutter_native_splash` | 네이티브 스플래시 화면 |

<br>

## 🌐 서버 주소 설정

`lib/app/config/api_config.dart` 파일 하나만 수정하면 전체 적용됩니다.

```dart
// 에뮬레이터 → 10.0.2.2
// 실제 기기  → 컴퓨터의 Wi-Fi IP (ipconfig로 확인)
const String baseUrl = 'http://10.0.2.2:3000';
```

<br>

## 🚀 실행

```bash
flutter pub get
flutter run
```

<br>

## 📄 화면 목록

| 화면 | 설명 |
|------|------|
| Splash | 앱 시작 로딩 화면 |
| Onboarding | 퍼스널 컬러 · 피부톤 · 추구 스타일 설정 |
| Login / Signup | 이메일 로그인 · 회원가입 · 비회원 입장 |
| Home | 팔로잉 기반 메이크업 피드 |
| Ranking | 카테고리별 화장품 랭킹 TOP20 (틴트 · 렌즈 · 볼터치 · 섀도우) |
| Search | 화장품 이름/브랜드 검색 · 계정 검색 · 피드 검색 |
| Upload | 메이크업 사진 업로드 + 사용 화장품 태그 |
| Profile / MyPage | 내 피드 · 팔로워/팔로잉 · 프로필 편집 · 설정 |
