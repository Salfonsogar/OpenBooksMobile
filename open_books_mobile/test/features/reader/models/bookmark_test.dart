import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/bookmark.dart';

void main() {
  group('Bookmark', () {
    final now = DateTime(2026, 5, 10, 12, 0, 0);

    test('constructor creates instance with all fields', () {
      final bookmark = Bookmark(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      expect(bookmark.id, 1);
      expect(bookmark.bookId, 42);
      expect(bookmark.chapterIndex, 3);
      expect(bookmark.title, 'Chapter 3');
      expect(bookmark.createdAt, now);
    });

    test('id can be null', () {
      final bookmark = Bookmark(
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      expect(bookmark.id, isNull);
    });

    test('toMap returns correct map', () {
      final bookmark = Bookmark(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      final map = bookmark.toMap();

      expect(map['id'], 1);
      expect(map['book_id'], 42);
      expect(map['chapter_index'], 3);
      expect(map['title'], 'Chapter 3');
      expect(map['created_at'], now.millisecondsSinceEpoch);
    });

    test('fromMap creates Bookmark from map', () {
      final map = {
        'id': 1,
        'book_id': 42,
        'chapter_index': 3,
        'title': 'Chapter 3',
        'created_at': now.millisecondsSinceEpoch,
      };

      final bookmark = Bookmark.fromMap(map);

      expect(bookmark.id, 1);
      expect(bookmark.bookId, 42);
      expect(bookmark.chapterIndex, 3);
      expect(bookmark.title, 'Chapter 3');
      expect(bookmark.createdAt, now);
    });

    test('fromMap handles null id', () {
      final map = {
        'book_id': 42,
        'chapter_index': 3,
        'title': 'Chapter 3',
        'created_at': now.millisecondsSinceEpoch,
      };

      final bookmark = Bookmark.fromMap(map);

      expect(bookmark.id, isNull);
    });

    test('toMap and fromMap roundtrip', () {
      final original = Bookmark(
        id: 5,
        bookId: 99,
        chapterIndex: 1,
        title: 'Introduction',
        createdAt: now,
      );

      final map = original.toMap();
      final restored = Bookmark.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.bookId, original.bookId);
      expect(restored.chapterIndex, original.chapterIndex);
      expect(restored.title, original.title);
      expect(restored.createdAt, original.createdAt);
    });

    test('copyWith creates new instance with changed values', () {
      final original = Bookmark(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      final copied = original.copyWith(title: 'Updated Title');

      expect(copied.id, 1);
      expect(copied.bookId, 42);
      expect(copied.chapterIndex, 3);
      expect(copied.title, 'Updated Title');
      expect(copied.createdAt, now);
    });

    test('copyWith with no arguments returns equal instance', () {
      final original = Bookmark(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.bookId, original.bookId);
      expect(copied.chapterIndex, original.chapterIndex);
      expect(copied.title, original.title);
      expect(copied.createdAt, original.createdAt);
    });

    test('copyWith preserves id when explicitly set to null (null is default)', () {
      final original = Bookmark(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        title: 'Chapter 3',
        createdAt: now,
      );

      final copied = original.copyWith(id: null);

      expect(copied.id, 1);
    });

    test('Equatable value equality', () {
      final a = Bookmark(id: 1, bookId: 42, chapterIndex: 3, title: 'Ch3', createdAt: now);
      final b = Bookmark(id: 1, bookId: 42, chapterIndex: 3, title: 'Ch3', createdAt: now);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Equatable inequality when fields differ', () {
      final a = Bookmark(id: 1, bookId: 42, chapterIndex: 3, title: 'Ch3', createdAt: now);
      final b = Bookmark(id: 2, bookId: 42, chapterIndex: 3, title: 'Ch3', createdAt: now);

      expect(a, isNot(equals(b)));
    });

    test('props returns correct list', () {
      final bookmark = Bookmark(id: 1, bookId: 42, chapterIndex: 3, title: 'Ch3', createdAt: now);

      expect(bookmark.props, [1, 42, 3, 'Ch3', now]);
    });
  });
}
