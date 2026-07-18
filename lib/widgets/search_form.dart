import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

/// A form that allows the user to enter search criteria.  It
/// corresponds to the `SearchForm` component in the React project.
/// When the user presses the search button (or Enter) the form calls
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

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _handleSearch(), // Enter 로 바로 검색
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '조건을 입력하고 Enter 또는 검색 버튼을 누르세요. 이름만으로도 검색됩니다.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _field(_nameController, '이름', Icons.person_outline),
            _field(
              _saeController,
              '세(世)',
              Icons.tag,
              keyboardType: TextInputType.number,
            ),
            _field(_fatherController, '부 이름', Icons.supervisor_account),
            _field(_grandPaController, '조부 이름', Icons.elderly),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.persimmon,
              ),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('검색'),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _handleReset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('초기화'),
            ),
          ],
        ),
      ],
    );
  }
}
