import 'package:flutter/material.dart';

/// 한지(paper) · 먹(ink) · 감(persimmon) · 송(pine) — 전통 색감 팔레트
class AppColors {
  static const ink = Color(0xFF2E2018); // 먹빛 (기본 텍스트/주 버튼)
  static const inkLight = Color(0xFF5B4636); // 옅은 먹 (본문)
  static const paper = Color(0xFFFBF8F2); // 한지 바탕
  static const paperDark = Color(0xFFF4EEE3); // 짙은 한지 (교차 행/빈 영역)
  static const persimmon = Color(0xFFC05621); // 감빛 (포인트/선택)
  static const pine = Color(0xFF6F7D54); // 송록 (보조 포인트)
  static const tan = Color(0xFFD9C4AE); // 갈모래 (칩/라벨)
  static const line = Color(0xFFE4DACB); // 경계선
  static const textMuted = Color(0xFF8A7A6A); // 보조 텍스트
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      primary: AppColors.ink,
      secondary: AppColors.pine,
      surface: AppColors.paper,
    ),
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.inkLight,
        side: const BorderSide(color: AppColors.tan),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.persimmon,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.persimmon, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AppColors.persimmon),
      prefixIconColor: AppColors.textMuted,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerColor: AppColors.line,
  );
}

/// 반투명 흰 배경 + 둥근 모서리 + 옅은 그림자 카드 (한지 배경 위 가독성 확보)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 감빛 세로 막대 + 제목 — 섹션 헤더 공통 스타일
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.persimmon,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
