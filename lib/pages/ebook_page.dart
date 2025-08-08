import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';

/// Displays an E‑Book style view of the family tree.  The tree is
/// grouped into pages of five generations each.  Users can select a
/// page from a drop‑down or use the arrow buttons to move between
/// pages.  Selecting a person from the regular search page will also
/// deep‑link to a specific page and highlight the chosen identifier.
class EbookPage extends StatefulWidget {
  final int page;
  final int focusId;

  const EbookPage({Key? key, required this.page, required this.focusId})
      : super(key: key);

  @override
  State<EbookPage> createState() => _EbookPageState();
}

class _EbookPageState extends State<EbookPage> {
  late int _currentPage;
  late int _focusId;
  List<TotalJockBoTreeItemInfo> _tree = [];
  static const int _defaultLastPage = 8;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.page;
    _focusId = widget.focusId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPage());
  }

  Future<void> _fetchPage() async {
    final appState = context.read<AppState>();
    appState.loopLoading = true;
    try {
      final data = await jockBoEBookFetchApi(_currentPage);
      setState(() {
        _tree = data;
      });
    } catch (e) {
      // ignore
    } finally {
      appState.loopLoading = false;
    }
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
    _fetchPage();
  }

  void _movePrevious() {
    if (_currentPage > 1) {
      _changePage(_currentPage - 1);
    }
  }

  void _moveNext() {
    if (_currentPage < _defaultLastPage) {
      _changePage(_currentPage + 1);
    }
  }

  Widget _buildTreeItem(TotalJockBoTreeItemInfo item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.myName,
            style: TextStyle(
              color: item.id == _focusId ? Colors.blue : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.ect.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(item.ect),
            ),
          if (item.totalChildren.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.totalChildren.map(_buildTreeItem).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 24, color: Color(0xFF3C2317)),
                tooltip: '뒤로가기',
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _currentPage,
                items: List.generate(_defaultLastPage, (index) {
                  final page = index + 1;
                  final start = page * 5 - 5;
                  final end = page * 5;
                  return DropdownMenuItem<int>(
                    value: page,
                    child: Text('$start世 ~ $end世'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    _changePage(value);
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _movePrevious,
                icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.brown),
                tooltip: '이전 페이지',
              ),
              IconButton(
                onPressed: _moveNext,
                icon: const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.brown),
                tooltip: '다음 페이지',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _tree.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _tree.map(_buildTreeItem).toList(),
                      ),
                    )
                  : const Center(child: Text('')), // no data yet
            ),
          ),
        ],
      ),
    );
  }
}