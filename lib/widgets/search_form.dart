import 'package:flutter/material.dart';

import '../models.dart';

/// A form that allows the user to enter search criteria.  It
/// corresponds to the `SearchForm` component in the React project.
/// When the user presses the search button the form calls
/// [onSearch] with a [SearchDataInfo] containing only the non‑empty
/// fields.  Pressing the reset button clears all fields and calls
/// [onReset].
class SearchForm extends StatefulWidget {
  final void Function(SearchDataInfo data) onSearch;
  final VoidCallback onReset;

  const SearchForm({Key? key, required this.onSearch, required this.onReset})
      : super(key: key);

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _nameController = TextEditingController();
  final _saeController = TextEditingController();
  final _fatherController = TextEditingController();
  final _grandPaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _saeController.dispose();
    _fatherController.dispose();
    _grandPaController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final data = SearchDataInfo()
      ..myName = _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim()
      ..mySae = _saeController.text.trim().isEmpty
          ? null
          : _saeController.text.trim()
      ..fatherName = _fatherController.text.trim().isEmpty
          ? null
          : _fatherController.text.trim()
      ..grandPaName = _grandPaController.text.trim().isEmpty
          ? null
          : _grandPaController.text.trim();
    widget.onSearch(data);
  }

  void _handleReset() {
    _nameController.clear();
    _saeController.clear();
    _fatherController.clear();
    _grandPaController.clear();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '족보 검색',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _saeController,
                decoration: const InputDecoration(
                  labelText: '세(世)',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _fatherController,
                decoration: const InputDecoration(
                  labelText: '부 이름',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _grandPaController,
                decoration: const InputDecoration(
                  labelText: '조부 이름',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF939B62), // palette.green
              ),
              child: const Text('검색'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85586F), // palette.purple
              ),
              child: const Text('초기화'),
            ),
          ],
        ),
      ],
    );
  }
}