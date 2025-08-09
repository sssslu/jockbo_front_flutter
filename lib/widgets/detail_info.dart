import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';

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

        return Container(
          width: 1100,
          margin: const EdgeInsets.fromLTRB(30, 20, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${info.myName} (${info.myNamechi}) - ${info.mySae}世',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/eBook/$eBookPage/${info.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC55300),
                    ),
                    child: const Text('족보 E‑BOOK'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '족보등재내용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (info.ect.isEmpty)
                const Text('')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_showMore ? info.ect : preview),
                    if (info.ect.length > _textLimit)
                      GestureDetector(
                        onTap: () => setState(() => _showMore = !_showMore),
                        child: const Text(
                          '...[더보기]',
                          style: TextStyle(
                            color: Color(0xFF61764B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
