import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:path/path.dart' as p;

import '../../data/models/highlight.dart';
import '../../../../shared/core/constants/app_constants.dart';

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

class HighlightColor {
  static const Map<String, Color> colors = {
    'yellow': AppColors.highlightYellow,
    'green': AppColors.highlightGreen,
    'blue': AppColors.highlightBlue,
    'pink': AppColors.highlightPink,
    'orange': AppColors.highlightOrange,
  };

  static Color getColor(String name) {
    return colors[name] ?? AppColors.highlightYellow;
  }
}

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

    try {
      final document = html_parser.parse(htmlString);
      final body = document.body;

      if (body == null) return blocks;

      print('[DEBUG EpubParser] parse: body nodes count=${body.nodes.length}');
      _processNodes(body.nodes, blocks);

      print('[DEBUG EpubParser] parse returning ${blocks.length} blocks');
    } catch (e, stack) {
      print('[DEBUG EpubParser] PARSE ERROR: $e');
      print('[DEBUG EpubParser] stack: $stack');
    }

    return blocks;
  }

  void _processNodes(List<dynamic> nodes, List<ReaderBlock> blocks) {
    if (nodes.isEmpty) return;
    
    if (nodes.length == 1 && nodes.first is html_dom.Element) {
      final singleNode = nodes.first as html_dom.Element;
      final singleTag = singleNode.localName?.toLowerCase() ?? '';
      print('[DEBUG EpubParser] UNICO NODO: tag=$singleTag, text length=${singleNode.text.length}');
      
      if (singleTag.isNotEmpty && singleTag != 'body' && singleNode.hasChildNodes()) {
        print('[DEBUG EpubParser] Procesando children del nodo $singleTag');
        _processNodes(singleNode.nodes.toList(), blocks);
        return;
      }
    }
    
    for (var node in nodes) {
      if (node is html_dom.Element) {
        final tagName = node.localName?.toLowerCase() ?? '';
        
        if (tagName.isEmpty) {
          final text = _cleanText(node.text.trim());
          if (text.isNotEmpty) {
            blocks.add(ReaderBlock(type: 'text', content: text));
          }
          continue;
        }

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

class ChapterContent extends StatefulWidget {
  final List<ReaderBlock> blocks;
  final double fontSize;
  final double lineHeight;
  final double horizontalMargin;
  final Color textColor;
  final Color backgroundColor;
  final int libroId;
  final String chapterPath;
  final String fontFamily;
  final List<Highlight> highlights;
  final int? activeParagraphIndex;
  final Function(String text, int startIndex, int endIndex, String color)? onTextSelected;
  final Function(Highlight highlight)? onHighlightTap;
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
    this.fontFamily = 'sans-serif',
    this.highlights = const [],
    this.activeParagraphIndex,
    this.onTextSelected,
    this.onHighlightTap,
    this.onImageTap,
  });

  @override
  State<ChapterContent> createState() => _ChapterContentState();
}

class _ChapterContentState extends State<ChapterContent> {
  OverlayEntry? _overlayEntry;
  String _selectedText = '';
  int _selectionStart = -1;
  int _selectionEnd = -1;
  int _currentBlockIndex = 0;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showHighlightMenu(Offset position) {
    if (_selectedText.isEmpty || _selectionStart < 0 || _selectionEnd <= _selectionStart) {
      return;
    }

    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final globalPosition = renderBox.localToGlobal(position);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: (globalPosition.dx - 65).clamp(10, MediaQuery.of(context).size.width - 150),
        top: (globalPosition.dy - 50).clamp(10, MediaQuery.of(context).size.height - 100),
        child: Material(
          color: Colors.transparent,
          child: _HighlightMenuOverlay(
            backgroundColor: widget.backgroundColor,
            onColorSelected: (color) {
              _createHighlight(color);
              _removeOverlay();
            },
            onDismiss: () {
              _removeOverlay();
              _clearSelection();
            },
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _createHighlight(String colorName) {
    if (_selectedText.isNotEmpty && _selectionStart >= 0 && _selectionEnd > _selectionStart) {
      final blockOffset = _getBlockOffset(_currentBlockIndex);
      widget.onTextSelected?.call(
        _selectedText,
        blockOffset + _selectionStart,
        blockOffset + _selectionEnd,
        colorName,
      );
    }
    _clearSelection();
  }

  void _clearSelection() {
    setState(() {
      _selectedText = '';
      _selectionStart = -1;
      _selectionEnd = -1;
    });
  }

  int _getBlockOffset(int blockIndex) {
    int offset = 0;
    int currentIndex = 0;

    for (final block in widget.blocks) {
      if (currentIndex >= blockIndex) break;

      if (_isTextBlock(block)) {
        offset += block.content.toString().length + 1;
      }
      currentIndex++;
    }

    return offset;
  }

  bool _isTextBlock(ReaderBlock block) {
    return block.type == 'p' || block.type == 'h1' || block.type == 'h2' ||
           block.type == 'h3' || block.type == 'h4' || block.type == 'h5' ||
           block.type == 'h6' || block.type == 'blockquote' || block.type == 'a';
  }

  Widget _buildHighlightableText(String text, int blockIndex) {
    final highlightsInBlock = _getHighlightsForBlock(blockIndex);

    final spans = <TextSpan>[];

    if (highlightsInBlock.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.textColor,
          height: widget.lineHeight,
          fontFamily: widget.fontFamily,
        ),
      ));
    } else {
      final sortedHighlights = List<Highlight>.from(highlightsInBlock)
        ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

      int currentIndex = 0;
      final blockEnd = text.length;

      for (final highlight in sortedHighlights) {
        if (highlight.startIndex >= blockEnd || highlight.endIndex > blockEnd) {
          continue;
        }

        if (highlight.startIndex > currentIndex) {
          spans.add(TextSpan(
            text: text.substring(currentIndex, highlight.startIndex),
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.textColor,
              height: widget.lineHeight,
              fontFamily: widget.fontFamily,
            ),
          ));
        }

        spans.add(TextSpan(
          text: text.substring(highlight.startIndex, highlight.endIndex),
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.textColor,
            height: widget.lineHeight,
            fontFamily: widget.fontFamily,
            backgroundColor: HighlightColor.getColor(highlight.color).withValues(alpha: 0.4),
          ),
          recognizer: null,
        ));

        currentIndex = highlight.endIndex;
      }

      if (currentIndex < blockEnd) {
        spans.add(TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.textColor,
            height: widget.lineHeight,
            fontFamily: widget.fontFamily,
          ),
        ));
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: [
            ContextMenuButtonItem(
              label: 'Resaltar',
              onPressed: () {
                final selection = editableTextState.textEditingValue.selection;
                if (selection.isValid && !selection.isCollapsed) {
                  final start = selection.baseOffset < selection.extentOffset
                      ? selection.baseOffset
                      : selection.extentOffset;
                  final end = selection.baseOffset > selection.extentOffset
                      ? selection.baseOffset
                      : selection.extentOffset;

                  setState(() {
                    _selectedText = text.substring(start, end);
                    _selectionStart = start;
                    _selectionEnd = end;
                    _currentBlockIndex = blockIndex;
                  });

                  ContextMenuController.removeAny();
                  final anchor = editableTextState.contextMenuAnchors;
                  _showHighlightMenu(Offset(anchor.primaryAnchor.dx, anchor.primaryAnchor.dy - 50));
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Highlight> _getHighlightsForBlock(int blockIndex) {
    int currentOffset = 0;
    int currentIndex = 0;

    for (final block in widget.blocks) {
      if (currentIndex >= blockIndex) break;

      if (_isTextBlock(block)) {
        currentOffset += block.content.toString().length + 1;
      }
      currentIndex++;
    }

    return widget.highlights.where((h) {
      return h.startIndex >= currentOffset &&
          h.startIndex < currentOffset + (widget.blocks[blockIndex].content?.toString().length ?? 0);
    }).map((h) {
      return Highlight(
        id: h.id,
        bookId: h.bookId,
        chapterIndex: h.chapterIndex,
        text: h.text,
        startIndex: h.startIndex - currentOffset,
        endIndex: h.endIndex - currentOffset,
        color: h.color,
        createdAt: h.createdAt,
      );
    }).toList();
  }

  String _resolveImagePath(String relativePath) {
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    return relativePath;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildBlocksWithHighlights(),
      ),
    );
  }

  List<Widget> _buildBlocksWithHighlights() {
    final widgets = <Widget>[];
    int blockIndex = 0;

    for (final block in widget.blocks) {
      if (_isTextBlock(block)) {
        widgets.add(_buildBlockWithHighlight(block, blockIndex));
        blockIndex++;
      } else {
        widgets.add(_buildBlock(context, block));
      }
    }

    return widgets;
  }

  Widget _buildBlockWithHighlight(ReaderBlock block, int blockIndex) {
    final text = block.content.toString();
    final isActiveParagraph = widget.activeParagraphIndex != null && 
                               blockIndex == widget.activeParagraphIndex;

    final highlightColor = isActiveParagraph 
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
        : null;

    switch (block.type) {
      case 'h1':
        return Container(
          decoration: isActiveParagraph ? BoxDecoration(color: highlightColor) : null,
          padding: const EdgeInsets.only(bottom: 16, top: 24),
          child: _buildHighlightableText(text, blockIndex),
        );
      case 'h2':
        return Container(
          decoration: isActiveParagraph ? BoxDecoration(color: highlightColor) : null,
          padding: const EdgeInsets.only(bottom: 12, top: 20),
          child: _buildHighlightableText(text, blockIndex),
        );
      case 'h3':
        return Container(
          decoration: isActiveParagraph ? BoxDecoration(color: highlightColor) : null,
          padding: const EdgeInsets.only(bottom: 10, top: 16),
          child: _buildHighlightableText(text, blockIndex),
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
          child: _buildHighlightableText(text, blockIndex),
        );
      case 'a':
        return Container(
          decoration: isActiveParagraph ? BoxDecoration(color: highlightColor) : null,
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHighlightableText(text, blockIndex),
        );
      default:
        return Container(
          decoration: isActiveParagraph ? BoxDecoration(color: highlightColor) : null,
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHighlightableText(text, blockIndex),
        );
    }
  }

  Widget _buildBlock(BuildContext context, ReaderBlock block) {
    switch (block.type) {
      case 'img':
        final imagePath = _resolveImagePath(block.content as String);
        final url = 'http://10.0.2.2:5201/api/Libros/${widget.libroId}/epub/resource?path=${Uri.encodeComponent(imagePath)}';
        return GestureDetector(
          onTap: widget.onImageTap != null ? () => widget.onImageTap!(url) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
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
      case 'br':
        return const SizedBox(height: 8);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HighlightMenuOverlay extends StatelessWidget {
  final Color backgroundColor;
  final Function(String color) onColorSelected;
  final VoidCallback onDismiss;

  const _HighlightMenuOverlay({
    required this.backgroundColor,
    required this.onColorSelected,
    required this.onDismiss,
  });

  static const List<Map<String, dynamic>> _colors = [
    {'name': 'yellow', 'color': Color(0xFFFFEB3B)},
    {'name': 'green', 'color': Color(0xFF4CAF50)},
    {'name': 'blue', 'color': Color(0xFF2196F3)},
    {'name': 'pink', 'color': Color(0xFFE91E63)},
    {'name': 'orange', 'color': Color(0xFFFF9800)},
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _colors.map((colorData) {
            return GestureDetector(
              onTap: () => onColorSelected(colorData['name'] as String),
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
