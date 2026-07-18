import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'app_state.dart';
import 'pages/search_page.dart';
import 'pages/jockbo8_page.dart';
import 'pages/ebook_page.dart';
import 'widgets/root_scaffold.dart';

void main() {
  runApp(const MyApp());
}

// 🔗 너의 Node.js 서버 (홈서버 Docker — ngrok /sphere 경로로 공개)
const String _apiBase = 'https://wick-ribbon-player.ngrok-free.dev/sphere';
// ✅ 이 프로젝트 전용 카운터 id (포트폴리오가 1이면, 여긴 2처럼 따로 쓰자)

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: '온라인족보',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          fontFamily: 'Inter',
        ),
        // 🔻 모든 페이지 위에 조회수 배너를 오버레이로 붙임
        builder: (context, child) => ViewCountOverlay(child: child),
        onGenerateRoute: (settings) {
          final name = settings.name ?? '/';
          final uri = Uri.parse(name);
          if (uri.path == '/' || uri.path.isEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RootScaffold(child: SearchPage()),
            );
          }
          if (uri.pathSegments.length >= 2 &&
              uri.pathSegments[0] == 'jockBo' &&
              uri.pathSegments[1] == '8dae') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RootScaffold(child: JockBo8Page()),
            );
          }
          if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'eBook') {
            int page = 1;
            int focusId = 0;
            if (uri.pathSegments.length >= 2) {
              page = int.tryParse(uri.pathSegments[1]) ?? 1;
            }
            if (uri.pathSegments.length >= 3) {
              focusId = int.tryParse(uri.pathSegments[2]) ?? 0;
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => RootScaffold(
                child: EbookPage(page: page, focusId: focusId),
              ),
            );
          }
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const RootScaffold(child: SearchPage()),
          );
        },
      ),
    );
  }
}

/// 모든 화면을 감싸서:
/// 1) 앱 시작 시 1회 조회수 +1 & 값 로드
/// 2) 화면 맨 아래에 배너로 Total 표시
class ViewCountOverlay extends StatefulWidget {
  final Widget? child;
  const ViewCountOverlay({super.key, this.child});

  @override
  State<ViewCountOverlay> createState() => _ViewCountOverlayState();
}

class _ViewCountOverlayState extends State<ViewCountOverlay> {
  int _viewCount = -1; // -1 = 아직 로딩 안 됨

  @override
  void initState() {
    super.initState();
    _bumpAndLoadViewCount();
  }

  Future<void> _bumpAndLoadViewCount() async {
    try {
      final res =
      await http.get(Uri.parse('$_apiBase/viewcount/2'),
          // ngrok 무료 도메인의 브라우저 경고 페이지 우회 (값은 아무거나)
          headers: {'ngrok-skip-browser-warning': '1'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final v = data['viewCount'];
        final next = v is int ? v : int.tryParse(v.toString()) ?? 0;
        if (!mounted) return;
        setState(() => _viewCount = next);
      } else {
        debugPrint('❌ viewcount 실패: ${res.statusCode} / ${res.body}');
        if (!mounted) return;
        setState(() => _viewCount = 0);
      }
    } catch (e) {
      debugPrint('❗ viewcount 에러: $e');
      if (!mounted) return;
      setState(() => _viewCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 배너 색상: 검정(투명도 약간) + 얇은 경계선
    final banner = (_viewCount == -1)
        ? const SizedBox.shrink()
        : Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(),
    );

    return Stack(
      children: [
        // 원래의 페이지
        if (widget.child != null) widget.child!,
        // 맨 아래 배너(배경)
        if (_viewCount != -1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: banner,
          ),
        // 배너 텍스트
        if (_viewCount != -1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: IgnorePointer(
              ignoring: true, // 클릭 방해 안 하게
              child: Center(
                child: Text(
                  'Total : $_viewCount views',
                  style: const TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 13,
                    shadows: [
                      Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
