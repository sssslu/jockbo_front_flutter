import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';

/// Displays detailed information about the currently selected person.  It
/// fetches the biography from the server whenever the selected
/// identifier changes.  A “read more” button toggles between a short
/// preview and the full text.  A button to navigate to the E‑Book
/// view is shown when the biography exists.
class DetailInfo extends StatefulWidget {
  const DetailInfo({Key? key}) : super(key: key);

  @override
  State<DetailInfo> createState() => _DetailInfoState();
}

class _DetailInfoState extends State<DetailInfo> {
  static const int _textLimit = 300;
  UserInfo? _info;
  bool _showMore = false;
  int _currentId = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppState>();
    if (_currentId != appState.gyeBoId) {
      _currentId = appState.gyeBoId;
      _fetchDetail(_currentId);
    }
  }

  Future<void> _fetchDetail(int id) async {
    final appState = context.read<AppState>();
    // Indicate a long‑running call
    appState.loopLoading = true;
    try {
      final info = await jockBoDetailFetchApi(id);
      setState(() {
        _info = info;
        _showMore = false;
      });
    } catch (e) {
      // ignore errors silently; in production you may want to show a snackbar
    } finally {
      appState.loopLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_info == null) {
      return Container();
    }
    final info = _info!;
    final preview = info.ect.length > _textLimit ? info.ect.substring(0, _textLimit) : info.ect;
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
                  backgroundColor: const Color(0xFFC55300), // palette.orange
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
            const Text(''),
          if (info.ect.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_showMore ? info.ect : preview),
                if (info.ect.length > _textLimit)
                  GestureDetector(
                    onTap: () {
                      setState(() => _showMore = !_showMore);
                    },
                    child: Text(
                      _showMore ? '[닫기]' : '...[더보기]',
                      style: const TextStyle(
                        color: Color(0xFF61764B), // palette.darkGreen
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}