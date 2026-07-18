import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../theme.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPath = ModalRoute.of(context)?.settings.name ?? '/';

    Widget item({
      required String label,
      required bool active,
      required VoidCallback onTap,
      IconData? trailingIcon,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppColors.ink.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: active ? AppColors.ink : AppColors.textMuted,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 4),
                    Icon(trailingIcon, size: 13, color: AppColors.textMuted),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              // 활성 탭 밑줄 (감빛)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 3,
                width: active ? 28 : 0,
                decoration: BoxDecoration(
                  color: AppColors.persimmon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget link(String label, String route) {
      final isActive = currentPath == route ||
          (route == '/' && currentPath == '') ||
          (route != '/' && currentPath.startsWith(route.split('/').take(2).join('/')));
      return item(
        label: label,
        active: isActive,
        onTap: () {
          if (currentPath != route) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(route, (route) => false);
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item(
            label: '홈페이지',
            active: false,
            trailingIcon: Icons.open_in_new,
            onTap: () => html.window.open('https://slupark.com', '_blank'),
          ),
          const SizedBox(width: 20),
          link('족보 검색', '/'),
          const SizedBox(width: 20),
          link('족보 보기', '/eBook/1/0'),
        ],
      ),
    );
  }
}
