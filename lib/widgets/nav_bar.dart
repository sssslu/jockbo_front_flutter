import 'package:flutter/material.dart';
import 'dart:html' as html; // ✅ 추가

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
            Navigator.of(context)
                .pushNamedAndRemoveUntil(route, (route) => false);
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
          // ✅ 홈페이지 버튼 클릭 시 slupark.com 새 탭에서 열기
          TextButton(
            onPressed: () {
              html.window.open('https://slupark.com', '_blank');
            },
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
