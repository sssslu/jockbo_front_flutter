import 'package:flutter/material.dart';

/// A navigation bar displayed at the top of the app.  It roughly
/// corresponds to the `NavBar` component in the React project.  Each
/// entry routes to a different section of the application.  The
/// currently active route is highlighted.
class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPath = ModalRoute.of(context)?.settings.name ?? '/';

    Widget buildLink(String label, String route) {
      final isActive = currentPath == route ||
          (route == '/' && currentPath == '');
      return TextButton(
        onPressed: () {
          if (currentPath != route) {
            Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: isActive ? const Color(0xFF3C2317) : Colors.grey,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      );
    }

    return Container(
      height: 90,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // External site link.  In a real deployment you could use
          // `url_launcher` or `dart:html` to open this link.  Leaving it
          // disabled here avoids compilation issues on non‑web targets.
          TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('홈페이지'),
          ),
          buildLink('족보 검색', '/'),
          buildLink('족보 보기', '/eBook/1/0'),
        ],
      ),
    );
  }
}