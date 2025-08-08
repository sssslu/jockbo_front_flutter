import 'package:flutter/foundation.dart';

/// A simple state container mirroring the Recoil atoms used in the
/// original React code.  It exposes flags for search‑related and
/// long‑running tasks as well as the currently selected genealogy
/// identifier.  Widgets can read and update this model via the
/// provider package.
class AppState extends ChangeNotifier {
  bool _searchLoading = false;
  bool _loopLoading = false;
  int _gyeBoId = 10001;

  bool get searchLoading => _searchLoading;
  bool get loopLoading => _loopLoading;
  int get gyeBoId => _gyeBoId;

  set searchLoading(bool value) {
    if (_searchLoading != value) {
      _searchLoading = value;
      notifyListeners();
    }
  }

  set loopLoading(bool value) {
    if (_loopLoading != value) {
      _loopLoading = value;
      notifyListeners();
    }
  }

  set gyeBoId(int value) {
    if (_gyeBoId != value) {
      _gyeBoId = value;
      notifyListeners();
    }
  }

  /// Update all three fields at once if necessary.  Only the provided
  /// values are changed.
  void update({bool? searchLoading, bool? loopLoading, int? gyeBoId}) {
    bool changed = false;
    if (searchLoading != null && _searchLoading != searchLoading) {
      _searchLoading = searchLoading;
      changed = true;
    }
    if (loopLoading != null && _loopLoading != loopLoading) {
      _loopLoading = loopLoading;
      changed = true;
    }
    if (gyeBoId != null && _gyeBoId != gyeBoId) {
      _gyeBoId = gyeBoId;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}