import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class SearchList extends StatelessWidget {
  final List<JockBoItemInfo> items;
  final ValueChanged<int> onSelect;

  /// 현재 선택된 사람 id (없으면 -1)
  final int selectedId;

  const SearchList({
    Key? key,
    required this.items,
    required this.onSelect,
    this.selectedId = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: const Column(
          children: [
            Icon(Icons.search_off, size: 36, color: AppColors.tan),
            SizedBox(height: 8),
            Text(
              '조건에 맞는 자료가 없습니다.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
            constraints.maxWidth.clamp(720.0, 1400.0);

        final w1 = tableWidth * 0.34; // 이름
        final w2 = tableWidth * 0.12; // 세(世)
        final w3 = tableWidth * 0.27; // 부명
        final w4 = tableWidth * 0.27; // 조부명

        Widget hd(String s, double w) => SizedBox(
              width: w,
              child: Center(
                child: Text(
                  s,
                  style: const TextStyle(
                    color: Color(0xFFF3EDE2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            );
        Widget cell(String s, double w, {bool strong = false}) => SizedBox(
              width: w,
              child: Center(
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: strong ? AppColors.ink : AppColors.inkLight,
                    fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: tableWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowHeight: 48,
                      dataRowMinHeight: 50,
                      dataRowMaxHeight: 50,
                      dividerThickness: 0.6,
                      headingRowColor: WidgetStateColor.resolveWith(
                        (_) => AppColors.ink,
                      ),
                      columns: [
                        DataColumn(label: hd('이름', w1)),
                        DataColumn(label: hd('세(世)', w2)),
                        DataColumn(label: hd('부명', w3)),
                        DataColumn(label: hd('조부명', w4)),
                      ],
                      rows: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = item.id == selectedId;
                        return DataRow(
                          selected: isSelected,
                          color: WidgetStateProperty.resolveWith((states) {
                            if (isSelected) {
                              return const Color(0x24C05621); // 감빛 강조
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFFF2E9DC); // hover
                            }
                            // 얼룩말(zebra) 줄무늬
                            return index.isEven
                                ? Colors.white
                                : const Color(0xFFFAF6EE);
                          }),
                          onSelectChanged: (_) {
                            onSelect(item.id);
                          },
                          cells: [
                            DataCell(cell(
                              '${item.myName} (${item.myNamechi})',
                              w1,
                              strong: true,
                            )),
                            DataCell(cell(item.mySae, w2)),
                            DataCell(cell(
                                '${item.father.myName} (${item.father.myNamechi})',
                                w3)),
                            DataCell(cell(
                                '${item.grandPa.myName} (${item.grandPa.myNamechi})',
                                w4)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
