import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/highlight.dart';

class HighlightDataSource {
  static const String _highlightsKey = 'highlights';
  static int _nextId = 1;

  Future<List<Map<String, dynamic>>> _getAllHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_highlightsKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> _saveAllHighlights(List<Map<String, dynamic>> highlights) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_highlightsKey, json.encode(highlights));
  }

  Future<int> insertHighlight(Highlight highlight) async {
    final highlights = await _getAllHighlights();
    final newId = _nextId++;

    final newHighlight = {
      'id': newId,
      'book_id': highlight.bookId,
      'chapter_index': highlight.chapterIndex,
      'text': highlight.text,
      'start_index': highlight.startIndex,
      'end_index': highlight.endIndex,
      'color': highlight.color,
      'created_at': highlight.createdAt.millisecondsSinceEpoch,
    };

    highlights.add(newHighlight);
    await _saveAllHighlights(highlights);

    return newId;
  }

  Future<List<Highlight>> getHighlightsByBook(int bookId) async {
    final allHighlights = await _getAllHighlights();

    final filteredHighlights = allHighlights
        .where((h) => h['book_id'] == bookId)
        .toList();

    filteredHighlights.sort((a, b) {
      final aIndex = a['chapter_index'] as int;
      final bIndex = b['chapter_index'] as int;
      if (aIndex != bIndex) return aIndex.compareTo(bIndex);
      final aStart = a['start_index'] as int;
      final bStart = b['start_index'] as int;
      return aStart.compareTo(bStart);
    });

    return filteredHighlights.map((map) => Highlight.fromMap(map)).toList();
  }

  Future<List<Highlight>> getHighlightsByChapter(int bookId, int chapterIndex) async {
    final allHighlights = await _getAllHighlights();

    final filteredHighlights = allHighlights
        .where((h) => h['book_id'] == bookId && h['chapter_index'] == chapterIndex)
        .toList();

    filteredHighlights.sort((a, b) {
      final aStart = a['start_index'] as int;
      final bStart = b['start_index'] as int;
      return aStart.compareTo(bStart);
    });

    return filteredHighlights.map((map) => Highlight.fromMap(map)).toList();
  }

  Future<int> deleteHighlight(int id) async {
    final highlights = await _getAllHighlights();

    final initialLength = highlights.length;
    highlights.removeWhere((h) => h['id'] == id);

    if (highlights.length < initialLength) {
      await _saveAllHighlights(highlights);
      return 1;
    }

    return 0;
  }

  Future<void> deleteHighlightsByBook(int bookId) async {
    final highlights = await _getAllHighlights();
    highlights.removeWhere((h) => h['book_id'] == bookId);
    await _saveAllHighlights(highlights);
  }

  Future<int> deleteHighlightsByChapter(int bookId, int chapterIndex) async {
    final highlights = await _getAllHighlights();
    final initialLength = highlights.length;
    highlights.removeWhere(
      (h) => h['book_id'] == bookId && h['chapter_index'] == chapterIndex,
    );
    await _saveAllHighlights(highlights);
    return initialLength - highlights.length;
  }
}
