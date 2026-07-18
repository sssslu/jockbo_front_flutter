import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

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
    final isFocus = item.id == _focusId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 초점 인물은 감빛 배경으로 강조
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isFocus ? const Color(0x24C05621) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.myName,
              style: TextStyle(
                color: isFocus ? AppColors.persimmon : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
          if (item.ect.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2),
              child: Text(
                item.ect,
                style: const TextStyle(
                  color: AppColors.inkLight,
                  fontSize: 13.5,
                  height: 1.65,
                ),
              ),
            ),
          if (item.totalChildren.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 10, top: 4),
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                // 세대 들여쓰기 가이드 라인
                border: Border(
                  left: BorderSide(color: AppColors.line, width: 1.5),
                ),
              ),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 도구 막대
              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const FaIcon(FontAwesomeIcons.arrowLeftLong,
                          size: 20, color: AppColors.ink),
                      tooltip: '뒤로가기',
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _currentPage,
                          borderRadius: BorderRadius.circular(10),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkLight,
                          ),
                          iconEnabledColor: AppColors.textMuted,
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _currentPage > 1 ? _movePrevious : null,
                      icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                      color: AppColors.inkLight,
                      disabledColor: AppColors.tan,
                      tooltip: '이전 페이지',
                    ),
                    IconButton(
                      onPressed:
                          _currentPage < _defaultLastPage ? _moveNext : null,
                      icon:
                          const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                      color: AppColors.inkLight,
                      disabledColor: AppColors.tan,
                      tooltip: '다음 페이지',
                    ),
                    const Spacer(),
                    Text(
                      '$_currentPage / $_defaultLastPage 페이지',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: _tree.isNotEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _tree.map(_buildTreeItem).toList(),
                          ),
                        )
                      : const Center(
                          child: Text(
                            '표시할 자료가 없습니다',
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
