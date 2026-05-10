import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/logic/epub_parser.dart';

void main() {
  group('EpubParser', () {
    late EpubParser parser;

    setUp(() {
      parser = EpubParser();
    });

    group('parse', () {
      test('parses simple HTML with paragraphs', () {
        final html = '<html><body><p>First paragraph.</p><p>Second paragraph.</p></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 2);
        expect(blocks[0].type, 'p');
        expect(blocks[0].content, 'First paragraph.');
        expect(blocks[1].type, 'p');
        expect(blocks[1].content, 'Second paragraph.');
      });

      test('parses HTML with headings', () {
        final html = '<html><body><h1>Title</h1><h2>Subtitle</h2><h3>Section</h3></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 3);
        expect(blocks[0].type, 'h1');
        expect(blocks[0].content, 'Title');
        expect(blocks[1].type, 'h2');
        expect(blocks[1].content, 'Subtitle');
        expect(blocks[2].type, 'h3');
        expect(blocks[2].content, 'Section');
      });

      test('parses HTML with images', () {
        final html = '<html><body><img src="image.jpg" alt="A photo"/></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'img');
        expect(blocks[0].content, 'image.jpg');
        expect(blocks[0].attributes, isNotNull);
        expect(blocks[0].attributes!['alt'], 'A photo');
      });

      test('parses HTML with images missing alt', () {
        final html = '<html><body><img src="photo.png"/></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'img');
        expect(blocks[0].content, 'photo.png');
        expect(blocks[0].attributes!['alt'], '');
      });

      test('skips images with empty src', () {
        final html = '<html><body><img src="" alt="empty"/></body></html>';
        final blocks = parser.parse(html);

        expect(blocks, isEmpty);
      });

      test('parses HTML with blockquotes', () {
        final html = '<html><body><blockquote>Famous quote.</blockquote></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'blockquote');
        expect(blocks[0].content, 'Famous quote.');
      });

      test('parses links', () {
        final html = '<html><body><a href="http://example.com">Click here</a></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'a');
        expect(blocks[0].content, 'Click here');
        expect(blocks[0].attributes!['href'], 'http://example.com');
      });

      test('parses break elements', () {
        final html = '<html><body><br/></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'br');
        expect(blocks[0].content, '');
      });

      test('handles empty HTML string', () {
        final blocks = parser.parse('');
        expect(blocks, isEmpty);
      });

      test('handles HTML with no body', () {
        final blocks = parser.parse('<html></html>');
        expect(blocks, isEmpty);
      });

      test('removes reference markers like [1]', () {
        final html = '<html><body><p>Some text[1] with reference.</p></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].content, 'Some text with reference.');
      });

      test('removes multiple reference markers', () {
        final html = '<html><body><p>Text[1] with[2] multiple[3].</p></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].content, 'Text with multiple.');
      });

      test('handles nested elements', () {
        final html = '<html><body><div><p>Nested paragraph.</p></div></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'p');
        expect(blocks[0].content, 'Nested paragraph.');
      });

      test('parses images inside paragraphs', () {
        final html = '<html><body><p>Text with <img src="inline.jpg" alt="inline"/> image.</p></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 2);
        expect(blocks[0].type, 'p');
        expect(blocks[0].content, 'Text with image.');
        expect(blocks[1].type, 'img');
        expect(blocks[1].content, 'inline.jpg');
        expect(blocks[1].attributes!['alt'], 'inline');
      });

      test('strips whitespace correctly', () {
        final html = '<html><body><p>   Extra   spaces   </p></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].content, 'Extra spaces');
      });

      test('h4, h5, h6 are parsed as h3', () {
        final html = '<html><body><h4>Sub-section</h4><h5>Detail</h5><h6>Fine print</h6></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 3);
        for (final block in blocks) {
          expect(block.type, 'h3');
        }
      });

      test('unknown elements are traversed for children', () {
        final html = '<html><body><section><p>Inside section</p></section></body></html>';
        final blocks = parser.parse(html);

        expect(blocks.length, 1);
        expect(blocks[0].type, 'p');
        expect(blocks[0].content, 'Inside section');
      });
    });

    group('fixImagePaths', () {
      test('fixes relative image paths starting with ../', () {
        final html = '<html><body><img src="../images/photo.jpg"/></body></html>';
        final result = parser.fixImagePaths(html, 'OEBPS/chapter1.xhtml');

        expect(result, contains('photo.jpg'));
        expect(result, isNot(contains('../')));
      });

      test('does not modify paths without ../ prefix', () {
        final html = '<html><body><img src="images/photo.jpg"/></body></html>';
        final result = parser.fixImagePaths(html, 'OEBPS/chapter1.xhtml');

        expect(result, contains('images/photo.jpg'));
      });

      test('does not modify absolute paths', () {
        final html = '<html><body><img src="/images/photo.jpg"/></body></html>';
        final result = parser.fixImagePaths(html, 'OEBPS/chapter1.xhtml');

        expect(result, contains('/images/photo.jpg'));
      });

      test('handles multiple images', () {
        final html = '<html><body><img src="../img/a.jpg"/><img src="../img/b.jpg"/></body></html>';
        final result = parser.fixImagePaths(html, 'OEBPS/text/chapter.xhtml');

        expect(result, contains('a.jpg'));
        expect(result, contains('b.jpg'));
        expect(result, isNot(contains('../')));
      });

      test('handles HTML with no images', () {
        final html = '<html><body><p>No images.</p></body></html>';
        final result = parser.fixImagePaths(html, 'chapter.xhtml');

        expect(result, contains('<p>No images.</p>'));
      });
    });

    group('extractParagraphs', () {
      test('extracts paragraphs from HTML content', () {
        final content = '<p>First paragraph.</p><p>Second paragraph.</p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 2);
        expect(paragraphs[0], 'First paragraph.');
        expect(paragraphs[1], 'Second paragraph.');
      });

      test('extracts headings', () {
        final content = '<h1>Title</h1><p>Content.</p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 2);
        expect(paragraphs[0], 'Title');
        expect(paragraphs[1], 'Content.');
      });

      test('extracts blockquotes', () {
        final content = '<blockquote>A quote.</blockquote>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'A quote.');
      });

      test('handles empty content', () {
        final paragraphs = parser.extractParagraphs('');
        expect(paragraphs, isEmpty);
      });

      test('strips HTML tags from extracted text', () {
        final content = '<p>Text with <b>bold</b> and <i>italic</i>.</p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Text with bold and italic .');
      });

      test('replaces <br> with space', () {
        final content = '<p>Line 1<br/>Line 2</p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Line 1 Line 2');
      });

      test('removes script tags', () {
        final content = '<p>Visible text</p><script>hidden</script>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Visible text');
      });

      test('removes style tags', () {
        final content = '<p>Content</p><style>.class{color:red;}</style>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Content');
      });

      test('decodes HTML entities', () {
        final content = '<p>Tom &amp; Jerry &lt; 3 &gt; 1</p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Tom & Jerry < 3 > 1');
      });

      test('falls back to line splitting when no block tags match', () {
        final content = '<div>Line one</div><div>Line two</div>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 2);
      });

      test('collapses whitespace', () {
        final content = '<p>   Spaced    text   </p>';
        final paragraphs = parser.extractParagraphs(content);

        expect(paragraphs.length, 1);
        expect(paragraphs[0], 'Spaced text');
      });
    });
  });
}
