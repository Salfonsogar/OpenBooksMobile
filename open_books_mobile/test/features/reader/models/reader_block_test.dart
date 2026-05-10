import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/reader_block.dart';

void main() {
  group('ReaderBlock', () {
    test('constructor creates instance with correct values', () {
      final block = ReaderBlock(
        type: 'p',
        content: 'Hello world',
      );

      expect(block.type, 'p');
      expect(block.content, 'Hello world');
      expect(block.attributes, isNull);
    });

    test('supports different types', () {
      final p = ReaderBlock(type: 'p', content: 'Paragraph');
      final h1 = ReaderBlock(type: 'h1', content: 'Heading 1');
      final img = ReaderBlock(type: 'img', content: 'image.jpg', attributes: {'alt': 'An image'});
      final blockquote = ReaderBlock(type: 'blockquote', content: 'Quote');
      final a = ReaderBlock(type: 'a', content: 'Link', attributes: {'href': 'http://example.com'});
      final br = ReaderBlock(type: 'br', content: '');

      expect(p.type, 'p');
      expect(h1.type, 'h1');
      expect(img.type, 'img');
      expect(blockquote.type, 'blockquote');
      expect(a.type, 'a');
      expect(br.type, 'br');
    });

    test('attributes map is stored correctly', () {
      final block = ReaderBlock(
        type: 'img',
        content: 'photo.png',
        attributes: {'alt': 'A photo', 'width': '300'},
      );

      expect(block.attributes, isNotNull);
      expect(block.attributes!['alt'], 'A photo');
      expect(block.attributes!['width'], '300');
    });

    test('attributes can be null', () {
      final block = ReaderBlock(type: 'p', content: 'text');
      expect(block.attributes, isNull);
    });
  });
}
