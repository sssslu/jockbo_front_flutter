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
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFFD0B8A8)), // palette.lightBrown
          columns: const [
            DataColumn(label: Center(child: Text('이름'))),
            DataColumn(label: Center(child: Text('세(世)'))),
            DataColumn(label: Center(child: Text('부명'))),
            DataColumn(label: Center(child: Text('조부명'))),
          ],
          rows: items.isNotEmpty
              ? items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text('${item.myName} (${item.myNamechi})'),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(item.mySae),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                              '${item.father.myName} (${item.father.myNamechi})'),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                              '${item.grandPa.myName} (${item.grandPa.myNamechi})'),
                        ),
                      ),
                    ],
                    onSelectChanged: (_) {
                      onSelect(item.id);
                    },
                  );
                }).toList()
              : [
                  const DataRow(
                    cells: [
                      DataCell(Center(child: Text('조건에 맞는 자료가 없습니다.'))),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}