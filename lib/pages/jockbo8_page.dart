import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/jockbo_tree.dart';

/// Displays the eight‑cousin genealogy for the currently selected
/// person.  A back button navigates to the previous page.  Selecting a
/// different node updates the view.
class JockBo8Page extends StatefulWidget {
  const JockBo8Page({Key? key}) : super(key: key);

  @override
  State<JockBo8Page> createState() => _JockBo8PageState();
}

class _JockBo8PageState extends State<JockBo8Page> {
  List<JockBoTreeItemInfo> _tree = [];
  UserInfo? _info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AppState>().gyeBoId;
      _fetchData(id);
    });
  }

  Future<void> _fetchData(int id) async {
    final appState = context.read<AppState>();
    appState.loopLoading = true;
    try {
      final info = await jockBoDetailFetchApi(id);
      final tree = await jockBo8saeFetchApi(id);
      setState(() {
        _info = info;
        _tree = tree;
      });
    } catch (e) {
      // ignore
    } finally {
      appState.loopLoading = false;
    }
  }

  void _handleSelect(int id) {
    final appState = context.read<AppState>();
    appState.gyeBoId = id;
    _fetchData(id);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const FaIcon(FontAwesomeIcons.arrowLeftLong,
                        size: 20, color: AppColors.ink),
                    tooltip: '뒤로가기',
                  ),
                  const SizedBox(width: 6),
                  const SectionTitle('8촌 가계도'),
                ],
              ),
              const SizedBox(height: 10),
              if (_info != null)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.pine),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_info!.myName} (${_info!.myNamechi})님은 시조로부터 ${_info!.mySae}세입니다. '
                          '8촌 가계도는 본인을 기준으로 최대 8촌까지 보여주는 가계도입니다.',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.inkLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: _tree.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: JockBoTree(
                              jockBo: _tree,
                              myId: appState.gyeBoId,
                              onSelect: _handleSelect,
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            '가계도를 불러오는 중입니다',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                ),
              ),
              // 하단 조회수 배너와 겹치지 않게 여백
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
