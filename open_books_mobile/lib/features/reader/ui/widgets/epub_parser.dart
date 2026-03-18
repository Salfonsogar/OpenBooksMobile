import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:path/path.dart' as p;

class ReaderBlock {
  final String type;
  final dynamic content;
  final Map<String, String>? attributes;

  const ReaderBlock({
    required this.type,
    required this.content,
    this.attributes,
  });
}

class EpubParser {
  String fixImagePaths(String htmlString, String chapterPath) {
    debugPrint('[READER] fixImagePaths - chapterPath: $chapterPath');
    final document = html_parser.parse(htmlString);
    final images = document.getElementsByTagName('img');
    debugPrint('[READER] fixImagePaths - found ${images.length} images');
    
    for (var img in images) {
      final src = img.attributes['src'];
      debugPrint('[READER] fixImagePaths - original src: $src');
      if (src != null && src.startsWith('../')) {
        final baseDir = p.dirname(chapterPath);
        final resolvedPath = p.normalize(p.join(baseDir, src));
        debugPrint('[READER] fixImagePaths - resolved to: $resolvedPath');
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
}

class ChapterContent extends StatelessWidget {
  final List<ReaderBlock> blocks;
  final double fontSize;
  final double lineHeight;
  final double horizontalMargin;
  final Color textColor;
  final Color backgroundColor;
  final int libroId;
  final String chapterPath;
  final Function(String)? onImageTap;

  const ChapterContent({
    super.key,
    required this.blocks,
    required this.libroId,
    required this.chapterPath,
    this.fontSize = 16.0,
    this.lineHeight = 1.6,
    this.horizontalMargin = 16.0,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.onImageTap,
  });

  String _resolveImagePath(String relativePath) {
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    return relativePath;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks.map((block) => _buildBlock(context, block)).toList(),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ReaderBlock block) {
    switch (block.type) {
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 24),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize * 1.8,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: lineHeight,
            ),
          ),
        );
      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 20),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: lineHeight,
            ),
          ),
        );
      case 'h3':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 16),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize * 1.3,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: lineHeight,
            ),
          ),
        );
      case 'p':
        if (block.content.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              height: lineHeight,
            ),
          ),
        );
      case 'img':
        final imagePath = _resolveImagePath(block.content as String);
        final url = 'https://localhost:7080/api/Libros/$libroId/epub/resource?path=${Uri.encodeComponent(imagePath)}';
        debugPrint('[READER] Image - path: $imagePath, url: $url');
        return GestureDetector(
          onTap: onImageTap != null ? () => onImageTap!(url) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  debugPrint('[READER] Image loaded successfully: $url');
                  return child;
                }
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('[READER] Image ERROR - path: $imagePath, error: $error');
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Path: $imagePath', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      case 'blockquote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey[400]!,
                width: 4,
              ),
            ),
            color: Colors.grey[100],
          ),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
              color: textColor,
              height: lineHeight,
            ),
          ),
        );
      case 'br':
        return const SizedBox(height: 8);
      case 'a':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.content,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.blue,
              decoration: TextDecoration.underline,
              height: lineHeight,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
