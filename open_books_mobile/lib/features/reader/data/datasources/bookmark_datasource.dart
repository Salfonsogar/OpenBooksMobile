import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bookmark.dart';

class BookmarkDataSource {
  static const String _bookmarksKey = 'bookmarks';
  static int _nextId = 1;

  Future<List<Map<String, dynamic>>> _getAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookmarksKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> _saveAllBookmarks(List<Map<String, dynamic>> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  Future<int> insertBookmark(Bookmark bookmark) async {
    final bookmarks = await _getAllBookmarks();
    final newId = _nextId++;
    
    final newBookmark = {
      'id': newId,
      'book_id': bookmark.bookId,
      'chapter_index': bookmark.chapterIndex,
      'title': bookmark.title,
      'created_at': bookmark.createdAt.millisecondsSinceEpoch,
    };
    
    bookmarks.add(newBookmark);
    await _saveAllBookmarks(bookmarks);
    
    return newId;
  }

  Future<List<Bookmark>> getBookmarksByBook(int bookId) async {
    final allBookmarks = await _getAllBookmarks();
    
    final filteredBookmarks = allBookmarks
        .where((b) => b['book_id'] == bookId)
        .toList();
    
    filteredBookmarks.sort((a, b) {
      final aIndex = a['chapter_index'] as int;
      final bIndex = b['chapter_index'] as int;
      return aIndex.compareTo(bIndex);
    });
    
    return filteredBookmarks.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<int> deleteBookmark(int id) async {
    final bookmarks = await _getAllBookmarks();
    
    final initialLength = bookmarks.length;
    bookmarks.removeWhere((b) => b['id'] == id);
    
    if (bookmarks.length < initialLength) {
      await _saveAllBookmarks(bookmarks);
      return 1;
    }
    
    return 0;
  }

  Future<void> updateBookmark({required int id, required String title}) async {
    final bookmarks = await _getAllBookmarks();
    
    for (var i = 0; i < bookmarks.length; i++) {
      if (bookmarks[i]['id'] == id) {
        bookmarks[i]['title'] = title;
        break;
      }
    }
    
    await _saveAllBookmarks(bookmarks);
  }

  Future<int> deleteBookmarksByBook(int bookId) async {
    final bookmarks = await _getAllBookmarks();
    
    final initialLength = bookmarks.length;
    bookmarks.removeWhere((b) => b['book_id'] == bookId);
    
    await _saveAllBookmarks(bookmarks);
    return initialLength - bookmarks.length;
  }

  Future<Bookmark?> getBookmarkByChapter(int bookId, int chapterIndex) async {
    final bookmarks = await _getAllBookmarks();
    
    final bookmark = bookmarks.firstWhere(
      (b) => b['book_id'] == bookId && b['chapter_index'] == chapterIndex,
      orElse: () => <String, dynamic>{},
    );
    
    if (bookmark.isEmpty) {
      return null;
    }
    
    return Bookmark.fromMap(bookmark);
  }
}