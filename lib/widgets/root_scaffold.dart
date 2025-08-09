import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
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

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backGround.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  '샘플박씨 예시파 서울종친회',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
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
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        // Display the appropriate loading spinner
        if (appState.searchLoading)
          const Center(child: LoadingWidget(variant: 'search')),
        if (!appState.searchLoading && appState.loopLoading)
          const Center(child: LoadingWidget(variant: 'loop')),
      ],
    );
  }
}