import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/highlight.dart';

void main() {
  group('Highlight', () {
    final now = DateTime(2026, 5, 10, 12, 0, 0);

    test('constructor creates instance with all fields', () {
      final highlight = Highlight(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        text: 'highlighted text',
        startIndex: 10,
        endIndex: 25,
        color: 'yellow',
        createdAt: now,
      );

      expect(highlight.id, 1);
      expect(highlight.bookId, 42);
      expect(highlight.chapterIndex, 3);
      expect(highlight.text, 'highlighted text');
      expect(highlight.startIndex, 10);
      expect(highlight.endIndex, 25);
      expect(highlight.color, 'yellow');
      expect(highlight.createdAt, now);
    });

    test('id can be null', () {
      final highlight = Highlight(
        bookId: 42,
        chapterIndex: 3,
        text: 'text',
        startIndex: 0,
        endIndex: 4,
        color: 'yellow',
        createdAt: now,
      );

      expect(highlight.id, isNull);
    });

    test('toMap returns correct map', () {
      final highlight = Highlight(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        text: 'highlighted text',
        startIndex: 10,
        endIndex: 25,
        color: 'yellow',
        createdAt: now,
      );

      final map = highlight.toMap();

      expect(map['id'], 1);
      expect(map['book_id'], 42);
      expect(map['chapter_index'], 3);
      expect(map['text'], 'highlighted text');
      expect(map['start_index'], 10);
      expect(map['end_index'], 25);
      expect(map['color'], 'yellow');
      expect(map['created_at'], now.millisecondsSinceEpoch);
    });

    test('fromMap creates Highlight from map', () {
      final map = {
        'id': 1,
        'book_id': 42,
        'chapter_index': 3,
        'text': 'highlighted text',
        'start_index': 10,
        'end_index': 25,
        'color': 'yellow',
        'created_at': now.millisecondsSinceEpoch,
      };

      final highlight = Highlight.fromMap(map);

      expect(highlight.id, 1);
      expect(highlight.bookId, 42);
      expect(highlight.chapterIndex, 3);
      expect(highlight.text, 'highlighted text');
      expect(highlight.startIndex, 10);
      expect(highlight.endIndex, 25);
      expect(highlight.color, 'yellow');
      expect(highlight.createdAt, now);
    });

    test('fromMap handles null id', () {
      final map = {
        'book_id': 42,
        'chapter_index': 3,
        'text': 'text',
        'start_index': 0,
        'end_index': 4,
        'color': 'yellow',
        'created_at': now.millisecondsSinceEpoch,
      };

      final highlight = Highlight.fromMap(map);

      expect(highlight.id, isNull);
    });

    test('toMap and fromMap roundtrip', () {
      final original = Highlight(
        id: 5,
        bookId: 99,
        chapterIndex: 1,
        text: 'important text',
        startIndex: 0,
        endIndex: 14,
        color: 'green',
        createdAt: now,
      );

      final map = original.toMap();
      final restored = Highlight.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.bookId, original.bookId);
      expect(restored.chapterIndex, original.chapterIndex);
      expect(restored.text, original.text);
      expect(restored.startIndex, original.startIndex);
      expect(restored.endIndex, original.endIndex);
      expect(restored.color, original.color);
      expect(restored.createdAt, original.createdAt);
    });

    test('copyWith creates new instance with changed values', () {
      final original = Highlight(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        text: 'original text',
        startIndex: 10,
        endIndex: 25,
        color: 'yellow',
        createdAt: now,
      );

      final copied = original.copyWith(text: 'updated text', color: 'green');

      expect(copied.id, 1);
      expect(copied.bookId, 42);
      expect(copied.chapterIndex, 3);
      expect(copied.text, 'updated text');
      expect(copied.startIndex, 10);
      expect(copied.endIndex, 25);
      expect(copied.color, 'green');
      expect(copied.createdAt, now);
    });

    test('copyWith with no arguments returns equal instance', () {
      final original = Highlight(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        text: 'text',
        startIndex: 0,
        endIndex: 4,
        color: 'yellow',
        createdAt: now,
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.bookId, original.bookId);
      expect(copied.chapterIndex, original.chapterIndex);
      expect(copied.text, original.text);
      expect(copied.startIndex, original.startIndex);
      expect(copied.endIndex, original.endIndex);
      expect(copied.color, original.color);
      expect(copied.createdAt, original.createdAt);
    });

    test('copyWith preserves id when explicitly set to null (null is default)', () {
      final original = Highlight(
        id: 1,
        bookId: 42,
        chapterIndex: 3,
        text: 'text',
        startIndex: 0,
        endIndex: 4,
        color: 'yellow',
        createdAt: now,
      );

      final copied = original.copyWith(id: null);

      expect(copied.id, 1);
    });
  });
}
