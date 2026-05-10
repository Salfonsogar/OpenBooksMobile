import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/epub_manifest.dart';

void main() {
  group('TocItem', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'titulo': 'Chapter 1',
        'href': 'chapter1.xhtml',
      };

      final item = TocItem.fromJson(json);

      expect(item.titulo, 'Chapter 1');
      expect(item.href, 'chapter1.xhtml');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final item = TocItem.fromJson(json);

      expect(item.titulo, '');
      expect(item.href, '');
    });

    test('toJson returns correct map', () {
      const item = TocItem(titulo: 'Chapter 1', href: 'chapter1.xhtml');

      final json = item.toJson();

      expect(json['titulo'], 'Chapter 1');
      expect(json['href'], 'chapter1.xhtml');
    });

    test('toJson and fromJson roundtrip', () {
      final original = TocItem(titulo: 'Introduction', href: 'intro.xhtml');

      final json = original.toJson();
      final restored = TocItem.fromJson(json);

      expect(restored.titulo, original.titulo);
      expect(restored.href, original.href);
    });
  });

  group('ReadingOrderItem', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'href': 'chapter1.xhtml',
        'type': 'application/xhtml+xml',
      };

      final item = ReadingOrderItem.fromJson(json);

      expect(item.href, 'chapter1.xhtml');
      expect(item.type, 'application/xhtml+xml');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final item = ReadingOrderItem.fromJson(json);

      expect(item.href, '');
      expect(item.type, '');
    });

    test('toJson returns correct map', () {
      const item = ReadingOrderItem(
        href: 'chapter1.xhtml',
        type: 'application/xhtml+xml',
      );

      expect(item.href, 'chapter1.xhtml');
      expect(item.type, 'application/xhtml+xml');
    });
  });

  group('EpubManifest', () {
    final readingOrder = [
      ReadingOrderItem(href: 'chapter1.xhtml', type: 'application/xhtml+xml'),
      ReadingOrderItem(href: 'chapter2.xhtml', type: 'application/xhtml+xml'),
    ];

    final toc = [
      TocItem(titulo: 'Chapter 1', href: 'chapter1.xhtml'),
      TocItem(titulo: 'Chapter 2', href: 'chapter2.xhtml'),
    ];

    test('fromJson creates instance with all fields', () {
      final json = {
        'id': 1,
        'titulo': 'Test Book',
        'autor': 'Test Author',
        'readingOrder': [
          {'href': 'chapter1.xhtml', 'type': 'application/xhtml+xml'},
        ],
        'toc': [
          {'titulo': 'Chapter 1', 'href': 'chapter1.xhtml'},
        ],
        'version': 2,
      };

      final manifest = EpubManifest.fromJson(json);

      expect(manifest.id, 1);
      expect(manifest.titulo, 'Test Book');
      expect(manifest.autor, 'Test Author');
      expect(manifest.readingOrder.length, 1);
      expect(manifest.readingOrder[0].href, 'chapter1.xhtml');
      expect(manifest.toc.length, 1);
      expect(manifest.toc[0].titulo, 'Chapter 1');
      expect(manifest.version, 2);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final manifest = EpubManifest.fromJson(json);

      expect(manifest.id, 0);
      expect(manifest.titulo, '');
      expect(manifest.autor, '');
      expect(manifest.readingOrder, isEmpty);
      expect(manifest.toc, isEmpty);
      expect(manifest.version, isNull);
    });

    test('fromJson handles missing version', () {
      final json = {
        'id': 1,
        'titulo': 'Book',
        'autor': 'Author',
        'readingOrder': [],
        'toc': [],
      };

      final manifest = EpubManifest.fromJson(json);

      expect(manifest.version, isNull);
    });

    test('toJson returns correct map', () {
      const manifest = EpubManifest(
        id: 1,
        titulo: 'Test Book',
        autor: 'Test Author',
        readingOrder: [],
        toc: [],
        version: 1,
      );

      final json = manifest.toJson();

      expect(json['id'], 1);
      expect(json['titulo'], 'Test Book');
      expect(json['autor'], 'Test Author');
      expect(json['readingOrder'], isEmpty);
      expect(json['toc'], isEmpty);
      expect(json['version'], 1);
    });

    test('toJson serializes nested items correctly', () {
      final manifest = EpubManifest(
        id: 1,
        titulo: 'Test Book',
        autor: 'Test Author',
        readingOrder: readingOrder,
        toc: toc,
      );

      final json = manifest.toJson();

      expect((json['readingOrder'] as List).length, 2);
      expect((json['readingOrder'] as List)[0]['href'], 'chapter1.xhtml');
      expect((json['toc'] as List).length, 2);
      expect((json['toc'] as List)[0]['titulo'], 'Chapter 1');
    });

    test('toJson excludes null version', () {
      final manifest = EpubManifest(
        id: 1,
        titulo: 'Test Book',
        autor: 'Test Author',
        readingOrder: [],
        toc: [],
      );

      final json = manifest.toJson();

      expect(json.containsKey('version'), true);
      expect(json['version'], isNull);
    });

    test('toJson and fromJson roundtrip', () {
      final original = EpubManifest(
        id: 42,
        titulo: 'Roundtrip Book',
        autor: 'Roundtrip Author',
        readingOrder: readingOrder,
        toc: toc,
        version: 3,
      );

      final json = original.toJson();
      final restored = EpubManifest.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.titulo, original.titulo);
      expect(restored.autor, original.autor);
      expect(restored.readingOrder.length, original.readingOrder.length);
      expect(restored.readingOrder[0].href, original.readingOrder[0].href);
      expect(restored.toc.length, original.toc.length);
      expect(restored.toc[0].titulo, original.toc[0].titulo);
      expect(restored.version, original.version);
    });
  });
}
