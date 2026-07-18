import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/detail_info.dart';
import '../widgets/jockbo_tree.dart';
import '../widgets/search_form.dart';
import '../widgets/search_list.dart';

/// The main page for searching the genealogy database.  Users can
/// specify search criteria, view direct ancestors of the selected
/// person and see a list of matches.  Selecting a row updates the
/// ancestor view and the detailed information panel.
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<JockBoItemInfo> _searchItems = [];
  List<JockBoTreeItemInfo> _gyeBoTree = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial tree for default id
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      _fetchGyeBoTree(appState.gyeBoId);
    });
  }

  Future<void> _fetchGyeBoTree(int id) async {
    final appState = context.read<AppState>();
    appState.loopLoading = true;
    try {
      final tree = await jockBo5saeFetchApi(id);
      setState(() {
        _gyeBoTree = tree;
      });
    } catch (e) {
      // ignore
    } finally {
      appState.loopLoading = false;
    }
  }

  Future<void> _handleSearch(SearchDataInfo data) async {
    // Build query string; same as URLSearchParams in JS
    final params = data.toQueryParameters();
    if (params.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입력된 값이 없습니다.')),
      );
      return;
    }
    final appState = context.read<AppState>();
    appState.searchLoading = true;
    try {
      final queryString = '?' +
          params.entries
              .map((e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
              .join('&');
      final results = await jockBoSearchFetchApi(queryString);
      setState(() {
        _searchItems = results;
        _hasSearched = true;
      });
      // Optionally select the first result to display ancestors
      if (results.isNotEmpty) {
        final firstId = results.first.id;
        appState.gyeBoId = firstId;
        _fetchGyeBoTree(firstId);
      }
    } catch (e) {
      // ignore
    } finally {
      appState.searchLoading = false;
    }
  }

  void _handleReset() {
    setState(() {
      _searchItems = [];
      _hasSearched = false;
    });
  }

  void _handleSelect(int id) {
    final appState = context.read<AppState>();
    appState.gyeBoId = id;
    _fetchGyeBoTree(id);
  }

  /// 검색 폼 카드
  Widget _buildFormCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('족보 검색'),
          const SizedBox(height: 12),
          SearchForm(
            onSearch: _handleSearch,
            onReset: _handleReset,
          ),
        ],
      ),
    );
  }

  /// 직계 계보 카드
  Widget _buildTreeCard(AppState appState) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle('직계 계보'),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/jockBo/8dae');
                },
                icon: const Icon(Icons.account_tree_outlined, size: 17),
                label: const Text('8寸 계보'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paperDark.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: _gyeBoTree.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: JockBoTree(
                      jockBo: _gyeBoTree,
                      myId: appState.gyeBoId,
                      onSelect: _handleSelect,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_tree_outlined,
                            size: 36, color: AppColors.tan),
                        SizedBox(height: 8),
                        Text(
                          '인물을 검색하면 직계 계보가 표시됩니다',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 검색 결과 섹션 (검색 후에만 표시)
  Widget _buildResultSection(AppState appState) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionTitle('검색 결과'),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paperDark,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  '${_searchItems.length}건',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SearchList(
            items: _searchItems,
            onSelect: _handleSelect,
            selectedId: appState.gyeBoId,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildFormCard()),
                          const SizedBox(width: 20),
                          Expanded(flex: 3, child: _buildTreeCard(appState)),
                        ],
                      )
                    else ...[
                      _buildFormCard(),
                      const SizedBox(height: 16),
                      _buildTreeCard(appState),
                    ],
                    const SizedBox(height: 16),
                    const DetailInfo(),
                    if (_hasSearched) ...[
                      const SizedBox(height: 16),
                      _buildResultSection(appState),
                    ],
                    // 하단 조회수 배너와 겹치지 않게 여백
                    const SizedBox(height: 48),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
