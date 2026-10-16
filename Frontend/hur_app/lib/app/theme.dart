import 'package:flutter/material.dart';

/// HUR 앱의 공통 색상. 화면마다 색을 직접 쓰지 말고 여기서 가져다 쓴다.
class HurColors {
  HurColors._();

  /// 앱 전체 바탕 (스플래시 영상의 검정과 이어진다)
  static const bg = Color(0xFF0C0A0F);

  /// 카드, 입력칸 같은 한 단계 위 면
  static const surface = Color(0x0FFFFFFF); // 흰색 6%
  static const surfaceStrong = Color(0x1AFFFFFF); // 흰색 10%

  /// 하단 탭바, 바텀시트처럼 불투명하게 깔리는 면
  static const panel = Color(0xFF16131B);

  /// 글자
  static const text = Color(0xFFF4ECE6);
  static const textSub = Color(0xFFCFC6CC);
  static const muted = Color(0xFFA99FAD);

  /// 포인트 (선택된 칩, 주요 버튼). 펄 화이트 한 가지로 통일한다.
  static const accent = Color(0xFFF2EBE6);
  static const onAccent = Color(0xFF14101A);

  /// 알림 점, 좋아요, 로그아웃 같은 작은 강조에만 쓰는 누드 피치
  static const peach = Color(0xFFE0A596);

  /// 구분선, 테두리
  static const line = Color(0x1AFFFFFF); // 흰색 10%
  static const border = Color(0x2EFFFFFF); // 흰색 18%

  /// 사진이 없을 때 깔리는 자리 색
  static const placeholder = Color(0xFF1E1A22);
}

class HurTheme {
  HurTheme._();

  static const fontFamily = 'Instrument Sans';

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = const ColorScheme.dark().copyWith(
      primary: HurColors.accent,
      onPrimary: HurColors.onAccent,
      secondary: HurColors.peach,
      surface: HurColors.bg,
      onSurface: HurColors.text,
      error: HurColors.peach,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: HurColors.bg,
      canvasColor: HurColors.bg,
      dividerColor: HurColors.line,
      splashFactory: NoSplash.splashFactory,
      textTheme: base.textTheme
          .apply(
            fontFamily: fontFamily,
            bodyColor: HurColors.text,
            displayColor: HurColors.text,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: HurColors.bg,
        foregroundColor: HurColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: HurColors.text),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HurColors.surface,
        hintStyle: const TextStyle(color: HurColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HurColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HurColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HurColors.accent),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HurColors.panel,
        contentTextStyle: const TextStyle(color: HurColors.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: HurColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HurColors.panel,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: HurColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: HurColors.textSub, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HurColors.border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HurColors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HurColors.accent,
          foregroundColor: HurColors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HurColors.text,
          side: const BorderSide(color: HurColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: HurColors.text),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: HurColors.accent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? HurColors.accent
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(HurColors.onAccent),
        side: const BorderSide(color: HurColors.border, width: 1.5),
      ),
    );
  }
}
