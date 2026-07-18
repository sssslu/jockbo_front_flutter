import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'app_state.dart';
import 'pages/search_page.dart';
import 'pages/jockbo8_page.dart';
import 'pages/ebook_page.dart';
import 'theme.dart';
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
        theme: buildAppTheme(),
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

  /// 1234567 -> '1,234,567'
  String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final left = s.length - 1 - i;
      if (left > 0 && left % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 원래의 페이지
        if (widget.child != null) widget.child!,
        // 하단 중앙의 조회수 알약(pill) 배너
        if (_viewCount > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: IgnorePointer(
              ignoring: true, // 클릭 방해 안 하게
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xCC2E2018),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Color(0xFFD9C4AE),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatCount(_viewCount)} views',
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
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
