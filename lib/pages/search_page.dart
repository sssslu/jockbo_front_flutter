import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';
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
        const SnackBar(content: Text('입력된 값이 없습니다.')),);
      return;
    }
    final appState = context.read<AppState>();
    appState.searchLoading = true;
    try {
      final queryString = '?' + params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}').join('&');
      final results = await jockBoSearchFetchApi(queryString);
      setState(() {
        _searchItems = results;
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
    });
  }

  void _handleSelect(int id) {
    final appState = context.read<AppState>();
    appState.gyeBoId = id;
    _fetchGyeBoTree(id);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SearchForm(
                    onSearch: _handleSearch,
                    onReset: _handleReset,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '직계 계보',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/jockBo/8dae');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3C2317), // palette.darkBrown
                            ),
                            child: const Text('8寸 계보'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 700,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
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
                            : const Center(child: Text('')), // No tree yet
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DetailInfo(),
            const SizedBox(height: 16),
            SearchList(items: _searchItems, onSelect: _handleSelect),
          ],
        ),
      ),
    );
  }
}