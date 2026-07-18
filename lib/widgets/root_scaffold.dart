import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import 'loading_widget.dart';
import 'nav_bar.dart';

/// A scaffold that displays the global header and navigation bar.  It
/// overlays a loading spinner whenever the app state indicates that
/// either a search or a long‑running computation is in progress.  The
/// wrapped [child] constitutes the main content of the page.
class RootScaffold extends StatelessWidget {
  final Widget child;

  const RootScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isLoading = appState.searchLoading || appState.loopLoading;
    final isNarrow = MediaQuery.of(context).size.width < 640;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.paper,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backGround.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: isNarrow ? 20 : 28),
                Text(
                  '샘플박씨 예시파 서울종친회',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isNarrow ? 20 : 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                // 감빛 포인트 장식선
                Container(
                  width: 56,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.persimmon,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const NavBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ),
        // Semi‑transparent overlay to indicate that the background is disabled
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.paper.withOpacity(0.55),
            ),
          ),
        // Display the appropriate loading spinner on a soft card
        if (isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: LoadingWidget(
                variant: appState.searchLoading ? 'search' : 'loop',
              ),
            ),
          ),
      ],
    );
  }
}
