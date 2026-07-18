import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class DetailInfo extends StatefulWidget {
  const DetailInfo({Key? key}) : super(key: key);

  @override
  State<DetailInfo> createState() => _DetailInfoState();
}

class _DetailInfoState extends State<DetailInfo> {
  static const int _textLimit = 300;

  int _currentId = -1;
  bool _showMore = false;
  Future<UserInfo>? _future;

  @override
  Widget build(BuildContext context) {
    // AppState에서 선택된 ID를 구독
    final nextId = context.watch<AppState>().gyeBoId;

    // ID가 바뀌었으면, 프레임 종료 후에 상태 갱신을 예약한다 (빌드 중 setState 금지)
    if (nextId > 0 && nextId != _currentId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentId = nextId;
          _showMore = false;
          _future = jockBoDetailFetchApi(_currentId);
        });
      });
    }

    if (_currentId <= 0 || _future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<UserInfo>(
      future: _future, // 동일 id 동안 같은 Future 재사용
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snap.hasError || !snap.hasData) {
          return const SizedBox.shrink();
        }

        final info = snap.data!;
        final preview = info.ect.length > _textLimit
            ? info.ect.substring(0, _textLimit)
            : info.ect;
        final eBookPage = ((info.mySae - 1) ~/ 5) + 1;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름 · 세(世) 칩 · E-BOOK 버튼
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${info.myName} (${info.myNamechi})',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tan.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${info.mySae}世',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkLight,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed('/eBook/$eBookPage/${info.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.persimmon,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.menu_book_outlined, size: 17),
                    label: const Text('족보 E‑BOOK'),
                  ),
                ],
              ),
              if (info.ect.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                const Text(
                  '족보 등재 내용',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showMore ? info.ect : preview,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    color: AppColors.inkLight,
                  ),
                ),
                if (info.ect.length > _textLimit)
                  TextButton.icon(
                    onPressed: () => setState(() => _showMore = !_showMore),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                    ),
                    icon: Icon(
                      _showMore ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                    label: Text(_showMore ? '접기' : '더보기'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
