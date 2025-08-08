/// Models corresponding to the TypeScript interfaces used in the React
/// implementation.  Each class includes a factory constructor to
/// construct itself from JSON returned by the backend.  The field
/// names mirror the keys returned from the Node.js API and align
/// closely with the TypeScript definitions.

/// A minimal summary representation of a person in the genealogy.
class JockBoItemSummaryInfo {
  final int id;
  final String myName;
  final String myNamechi;

  JockBoItemSummaryInfo({
    required this.id,
    required this.myName,
    required this.myNamechi,
  });

  factory JockBoItemSummaryInfo.fromJson(Map<String, dynamic> json) {
    return JockBoItemSummaryInfo(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      myName: json['myName']?.toString() ?? '',
      myNamechi: json['myNamechi']?.toString() ?? '',
    );
  }
}

/// A complete representation of a row in the search table.  It includes
/// names for the father and grandfather records in addition to the
/// current person.
class JockBoItemInfo extends JockBoItemSummaryInfo {
  final String mySae;
  final JockBoItemSummaryInfo father;
  final JockBoItemSummaryInfo grandPa;

  JockBoItemInfo({
    required super.id,
    required super.myName,
    required super.myNamechi,
    required this.mySae,
    required this.father,
    required this.grandPa,
  });

  factory JockBoItemInfo.fromJson(Map<String, dynamic> json) {
    return JockBoItemInfo(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      myName: json['myName']?.toString() ?? '',
      myNamechi: json['myNamechi']?.toString() ?? '',
      mySae: json['mySae']?.toString() ?? '',
      father: JockBoItemSummaryInfo.fromJson(json['father'] ?? {}),
      grandPa: JockBoItemSummaryInfo.fromJson(json['grandPa'] ?? {}),
    );
  }
}

/// A tree node representing a person and their children for the direct
/// ancestry tree.  The server returns `mySae` as a number for these
/// structures.  `ancUID` holds the identifier of the ancestor in
/// question – it may be null for the root.
class JockBoTreeItemInfo extends JockBoItemSummaryInfo {
  final int mySae;
  final int? ancUID;
  final List<JockBoTreeItemInfo> children;

  JockBoTreeItemInfo({
    required super.id,
    required super.myName,
    required super.myNamechi,
    required this.mySae,
    required this.ancUID,
    List<JockBoTreeItemInfo>? children,
  }) : children = children ?? [];

  factory JockBoTreeItemInfo.fromJson(Map<String, dynamic> json) {
    // children can be an empty list or missing altogether
    final rawChildren = json['children'];
    List<JockBoTreeItemInfo> parsedChildren = [];
    if (rawChildren is List) {
      parsedChildren = rawChildren
          .map((item) => JockBoTreeItemInfo.fromJson(item))
          .toList();
    }

    return JockBoTreeItemInfo(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      myName: json['myName']?.toString() ?? '',
      myNamechi: json['myNamechi']?.toString() ?? '',
      mySae: json['mySae'] is int
          ? json['mySae']
          : int.tryParse(json['mySae']?.toString() ?? '') ?? 0,
      ancUID: json['ancUID'] == null
          ? null
          : (json['ancUID'] is int
              ? json['ancUID']
              : int.tryParse(json['ancUID'].toString()) ?? 0),
      children: parsedChildren,
    );
  }
}

/// Structure for the search form.  All fields are optional.
class SearchDataInfo {
  String? myName;
  String? mySae;
  String? fatherName;
  String? grandPaName;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (myName != null && myName!.isNotEmpty) params['myName'] = myName;
    if (mySae != null && mySae!.isNotEmpty) params['mySae'] = mySae;
    if (fatherName != null && fatherName!.isNotEmpty) params['fatherName'] = fatherName;
    if (grandPaName != null && grandPaName!.isNotEmpty) params['grandPaName'] = grandPaName;
    return params;
  }
}

/// Detailed information about a single person, including
/// biographical text (`ect`) and the last modification date.  The server
/// returns `_id`, `myName`, `myNamechi`, `mySae`, `ancUID` and
/// `ect` for these records.
class UserInfo extends JockBoItemSummaryInfo {
  final int mySae;
  final int? ancUID;
  final String ect;
  final String moddate;

  UserInfo({
    required super.id,
    required super.myName,
    required super.myNamechi,
    required this.mySae,
    required this.ancUID,
    required this.ect,
    required this.moddate,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      myName: json['myName']?.toString() ?? '',
      myNamechi: json['myNamechi']?.toString() ?? '',
      mySae: json['mySae'] is int
          ? json['mySae']
          : int.tryParse(json['mySae']?.toString() ?? '') ?? 0,
      ancUID: json['ancUID'] == null
          ? null
          : (json['ancUID'] is int
              ? json['ancUID']
              : int.tryParse(json['ancUID'].toString()) ?? 0),
      ect: json['ect']?.toString() ?? '',
      moddate: json['moddate']?.toString() ?? '',
    );
  }
}

/// A node in the complete family tree used by the E‑Book view.  This
/// extends [JockBoTreeItemInfo] by including the `ect` field to
/// display the biography under each person's name.  Children are
/// recursively typed as [TotalJockBoTreeItemInfo].
class TotalJockBoTreeItemInfo extends JockBoTreeItemInfo {
  final String ect;
  final List<TotalJockBoTreeItemInfo> totalChildren;

  TotalJockBoTreeItemInfo({
    required super.id,
    required super.myName,
    required super.myNamechi,
    required super.mySae,
    required super.ancUID,
    required this.ect,
    List<TotalJockBoTreeItemInfo>? children,
  }) : totalChildren = children ?? [];

  factory TotalJockBoTreeItemInfo.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    List<TotalJockBoTreeItemInfo> parsedChildren = [];
    if (rawChildren is List) {
      parsedChildren = rawChildren
          .map((e) => TotalJockBoTreeItemInfo.fromJson(e))
          .toList();
    }
    return TotalJockBoTreeItemInfo(
      id: json['_id'] is int ? json['_id'] : int.tryParse(json['_id'].toString()) ?? 0,
      myName: json['myName']?.toString() ?? '',
      myNamechi: json['myNamechi']?.toString() ?? '',
      mySae: json['mySae'] is int
          ? json['mySae']
          : int.tryParse(json['mySae']?.toString() ?? '') ?? 0,
      ancUID: json['ancUID'] == null
          ? null
          : (json['ancUID'] is int
              ? json['ancUID']
              : int.tryParse(json['ancUID'].toString()) ?? 0),
      ect: json['ect']?.toString() ?? '',
      children: parsedChildren,
    );
  }
}