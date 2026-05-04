import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:path/path.dart' as p;

import '../widgets/reader_blocks.dart';

class EpubParser {
  String fixImagePaths(String htmlString, String chapterPath) {
    final document = html_parser.parse(htmlString);
    final images = document.getElementsByTagName('img');

    for (var img in images) {
      final src = img.attributes['src'];
      if (src != null && src.startsWith('../')) {
        final baseDir = p.dirname(chapterPath);
        final resolvedPath = p.normalize(p.join(baseDir, src));
        img.attributes['src'] = resolvedPath;
      }
    }

    return document.outerHtml;
  }

  List<ReaderBlock> parse(String htmlString) {
    final blocks = <ReaderBlock>[];

    final document = html_parser.parse(htmlString);
    final body = document.body;

    if (body == null) return blocks;

    _processNodes(body.nodes, blocks);

    return blocks;
  }

  void _processNodes(List<dynamic> nodes, List<ReaderBlock> blocks) {
    for (var node in nodes) {
      if (node is html_dom.Element) {
        final tagName = node.localName?.toLowerCase() ?? '';

        switch (tagName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
          case 'p':
            _parseTextAndImages(node, tagName == 'h1' || tagName == 'h2' || tagName == 'h3' ? tagName : (tagName == 'p' ? 'p' : 'h3'), blocks);
            break;
          case 'img':
            final src = node.attributes['src'] ?? '';
            final alt = node.attributes['alt'] ?? '';
            if (src.isNotEmpty) {
              blocks.add(ReaderBlock(
                type: 'img',
                content: src,
                attributes: {'alt': alt},
              ));
            }
            break;
          case 'blockquote':
            final text = _cleanText(node.text.trim());
            if (text.isNotEmpty) {
              blocks.add(ReaderBlock(
                type: 'blockquote',
                content: text,
              ));
            }
            break;
          case 'br':
            blocks.add(const ReaderBlock(type: 'br', content: ''));
            break;
          case 'a':
            final href = node.attributes['href'] ?? '';
            final text = _cleanText(node.text.trim());
            if (href.isNotEmpty && text.isNotEmpty) {
              blocks.add(ReaderBlock(
                type: 'a',
                content: text,
                attributes: {'href': href},
              ));
            }
            break;
          default:
            if (node.hasChildNodes()) {
              _processNodes(node.nodes.toList(), blocks);
            }
        }
      }
    }
  }

  void _parseTextAndImages(html_dom.Element node, String type, List<ReaderBlock> blocks) {
    final text = _cleanText(node.text.trim());

    if (text.isNotEmpty) {
      blocks.add(ReaderBlock(type: type, content: text));
    }

    for (var child in node.nodes) {
      if (child is html_dom.Element && child.localName?.toLowerCase() == 'img') {
        final src = child.attributes['src'] ?? '';
        final alt = child.attributes['alt'] ?? '';
        if (src.isNotEmpty) {
          blocks.add(ReaderBlock(
            type: 'img',
            content: src,
            attributes: {'alt': alt},
          ));
        }
      }
    }
  }

  String _cleanText(String text) {
    text = text.replaceAll(RegExp(r'\[\d+\]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  List<String> extractParagraphs(String content) {
    final paragraphs = <String>[];
    
    if (content.isEmpty) return paragraphs;
    
    var cleanContent = content;
    
    cleanContent = cleanContent.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    cleanContent = cleanContent.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
    
    final blockTags = RegExp(r'<(p|div|span|h[1-6]|li|tr|blockquote)[^>]*>(.*?)</\1>', dotAll: true);
    final matches = blockTags.allMatches(cleanContent);
    
    for (final match in matches) {
      var text = match.group(2) ?? '';
      
      text = text.replaceAll(RegExp(r'<br\s*/?>'), ' ');
      text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
      text = text.replaceAll(RegExp(r'&nbsp;'), ' ');
      text = text.replaceAll(RegExp(r'&amp;'), '&');
      text = text.replaceAll(RegExp(r'&lt;'), '<');
      text = text.replaceAll(RegExp(r'&gt;'), '>');
      text = text.replaceAll(RegExp(r'&quot;'), '"');
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (text.isNotEmpty) {
        paragraphs.add(text);
      }
    }
    
    if (paragraphs.isEmpty && content.isNotEmpty) {
      final lines = content.split(RegExp(r'\n'));
      for (var line in lines) {
        line = line.trim();
        line = line.replaceAll(RegExp(r'<[^>]+>'), '').trim();
        if (line.isNotEmpty) {
          paragraphs.add(line);
        }
      }
    }
    
    return paragraphs;
  }
}
