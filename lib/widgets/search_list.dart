import 'package:flutter/material.dart';

import '../models.dart';

/// Displays a table of search results.  Each row corresponds to one
/// person returned by the search API.  Clicking a row calls
/// [onSelect] with that person's identifier.
class SearchList extends StatelessWidget {
  final List<JockBoItemInfo> items;
  final ValueChanged<int> onSelect;

  const SearchList({Key? key, required this.items, required this.onSelect})
      : super(key: key);

  @override

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('조건에 맞는 자료가 없습니다.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth =
        (constraints.maxWidth * 0.9).clamp(960.0, 1400.0);

        // 각 열의 비율 (원하면 숫자 조절가능)
        final w1 = tableWidth * 0.34; // 이름
        final w2 = tableWidth * 0.12; // 세(世)
        final w3 = tableWidth * 0.27; // 부명
        final w4 = tableWidth * 0.27; // 조부명

        Widget hd(String s, double w) =>
            SizedBox(width: w, child: Center(child: Text(s)));
        Widget cell(String s, double w) => SizedBox(
          width: w,
          child: Center(
            child: Text(s, overflow: TextOverflow.ellipsis, softWrap: false),
          ),
        );

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: tableWidth),
              child: DataTable(
                // 여백/간격을 0으로 만들어 열폭을 "고정값"만 쓰게 함
                horizontalMargin: 0,
                columnSpacing: 0,
                headingRowHeight: 48,
                dataRowHeight: 48,
                headingRowColor: MaterialStateColor.resolveWith(
                      (_) => const Color(0xFFD0B8A8),
                ),
                columns: [
                  DataColumn(label: hd('이름', w1)),
                  DataColumn(label: hd('세(世)', w2)),
                  DataColumn(label: hd('부명', w3)),
                  DataColumn(label: hd('조부명', w4)),
                ],
                rows: items.map((item) {
                  return DataRow(cells: [
                    DataCell(cell('${item.myName} (${item.myNamechi})', w1)),
                    DataCell(cell(item.mySae, w2)),
                    DataCell(cell(
                        '${item.father.myName} (${item.father.myNamechi})', w3)),
                    DataCell(cell(
                        '${item.grandPa.myName} (${item.grandPa.myNamechi})', w4)),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }



}