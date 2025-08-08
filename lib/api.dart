import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models.dart';

/// Base URL for all network requests.  The underlying Node.js server
/// exposes endpoints like `/all`, `/list`, `/search`, etc.  The value
/// can be overridden at compile time using `--dart-define=BASE_URL=...`.
//const String _baseUrl = 'http://localhost:8080';
const String _baseUrl = 'https://jokbonode.fly.dev';

/// Helper for building URIs consistently.  We avoid using `Uri.parse` on
/// concatenated strings because it can accidentally treat query
/// parameters as part of the path.  This helper inserts a leading
/// slash if missing and attaches any query string intact.
Uri _buildUri(String path) {
  // Ensure there is exactly one slash between the base and path
  final normalizedBase = _baseUrl.endsWith('/')
      ? _baseUrl.substring(0, _baseUrl.length - 1)
      : _baseUrl;
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return Uri.parse('$normalizedBase$normalizedPath');
}

/// Fetch all available genealogical records.  Not currently used in
/// the Flutter interface but included for completeness.
Future<List<dynamic>> totalJockBoFetchApi() async {
  final resp = await http.get(_buildUri('/all'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch records: ${resp.statusCode}');
  }
  return jsonDecode(resp.body) as List<dynamic>;
}

/// Retrieve the entire list of searchable people.  The Node.js API
/// returns an array of objects with the fields `_id`, `myName`,
/// `myNamechi`, `mySae`, `father`, and `grandPa`.
Future<List<JockBoItemInfo>> jockBoListFetchApi() async {
  final resp = await http.get(_buildUri('/list'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch list: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => JockBoItemInfo.fromJson(e)).toList();
}

/// Retrieve a limited subset of the available data for the `TotalPage`.
Future<List<JockBoItemInfo>> jockBoListFetchApiLimited() async {
  final resp = await http.get(_buildUri('/listlimited'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch limited list: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => JockBoItemInfo.fromJson(e)).toList();
}

/// Perform a search given a query string (for example,
/// `?myName=John`).  The server expects the leading question mark to be
/// present.  This function returns a list of matching items.
Future<List<JockBoItemInfo>> jockBoSearchFetchApi(String query) async {
  final resp = await http.get(_buildUri('/search$query'));
  if (resp.statusCode != 200) {
    throw Exception('Search failed: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => JockBoItemInfo.fromJson(e)).toList();
}

/// Retrieve detailed information for a single individual by id.  The
/// returned record includes a biography (`ect`) and the last
/// modification date (`moddate`).
Future<UserInfo> jockBoDetailFetchApi(int id) async {
  final resp = await http.get(_buildUri('/detail/$id'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch detail for $id: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  return UserInfo.fromJson(data);
}

/// Retrieve the direct lineage for a given individual.  The API
/// returns a tree of ancestors down to five generations.  The Node.js
/// code refers to this endpoint as `/4Sae/:id`, which returns the
/// previous four generations plus the subject.
Future<List<JockBoTreeItemInfo>> jockBo5saeFetchApi(int id) async {
  final resp = await http.get(_buildUri('/4Sae/$id'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch 5‑generation tree: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => JockBoTreeItemInfo.fromJson(e)).toList();
}

/// Retrieve the 8‑cousin tree for an individual.  The endpoint is
/// `/8chon/:id` in the Node.js implementation.  It returns a nested
/// array of people where siblings and cousins appear at the same
/// depth.
Future<List<JockBoTreeItemInfo>> jockBo8saeFetchApi(int id) async {
  final resp = await http.get(_buildUri('/8chon/$id'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch 8‑generation tree: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => JockBoTreeItemInfo.fromJson(e)).toList();
}

/// Change the biography (`ect`) of a given individual.  The API
/// accepts a PATCH request with a JSON body `{ ect: <new value> }`.
Future<void> changeDetailApi(int id, String changeData) async {
  final resp = await http.patch(
    _buildUri('/update/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'ect': changeData}),
  );
  if (resp.statusCode != 200) {
    throw Exception('Failed to update detail: ${resp.statusCode}');
  }
}

/// Retrieve the paginated tree used by the E‑Book view.  Each call
/// returns an array representing five generations (e.g. 1–5 or 6–10).  The
/// original React code calls this endpoint `/whole/:partition` where
/// partition is a 1‑based page number.  Each page includes names and
/// biographies.
Future<List<TotalJockBoTreeItemInfo>> jockBoEBookFetchApi(int partition) async {
  final resp = await http.get(_buildUri('/whole/$partition'));
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch E‑Book data: ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body) as List<dynamic>;
  return data.map((e) => TotalJockBoTreeItemInfo.fromJson(e)).toList();
}

/// Placeholder for the 10‑generation tree.  The original React code
/// references `jockBo10saeFetchApi` but this endpoint is not defined in
/// the supplied TypeScript.  If your backend exposes an endpoint for
/// 10‑generation trees, implement it here.  Currently this method
/// throws to inform you that it is unimplemented.
Future<List<JockBoTreeItemInfo>> jockBo10saeFetchApi(int id) async {
  throw UnimplementedError('jockBo10saeFetchApi is not defined on the server');
}