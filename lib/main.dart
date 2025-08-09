import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'pages/search_page.dart';
import 'pages/jockbo8_page.dart';
import 'pages/ebook_page.dart';
import 'widgets/root_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: '온라인족보',
        debugShowCheckedModeBanner: false,
        // Use a light theme similar to the React project
        theme: ThemeData(
          primarySwatch: Colors.brown,
          fontFamily: 'Inter',
        ),
        onGenerateRoute: (settings) {
          final name = settings.name ?? '/';
          final uri = Uri.parse(name);
          // Root search page
          if (uri.path == '/' || uri.path.isEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RootScaffold(child: SearchPage()),
            );
          }
          // Eight cousin page: /jockBo/8dae
          if (uri.pathSegments.length >= 2 &&
              uri.pathSegments[0] == 'jockBo' &&
              uri.pathSegments[1] == '8dae') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RootScaffold(child: JockBo8Page()),
            );
          }
          // E‑Book page: /eBook/:page/:id
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
          // Fall back to search page for unknown routes
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const RootScaffold(child: SearchPage()),
          );
        },
      ),
    );
  }
}