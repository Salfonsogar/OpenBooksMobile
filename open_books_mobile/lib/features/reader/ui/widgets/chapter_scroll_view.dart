import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/highlight.dart';
import '../../data/models/reader_block.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/highlight_state.dart';
import '../../logic/cubit/reader_cubit.dart';
import 'reader_blocks.dart';
import 'reader_colors.dart';

class ChapterScrollView extends StatefulWidget {
  final int index;
  final int currentChapterIndex;
  final int totalChapters;
  final ScrollController scrollController;
  final bool shouldRestoreScroll;
  final double initialScrollPosition;
  final List<ReaderBlock> blocks;
  final String chapterPath;
  final ReaderSettings settings;
  final ReaderColors colors;
  final int? activeParagraphIndex;
  final int libroId;
  final void Function() onNextPage;
  final void Function() onPreviousPage;
  final VoidCallback onScrollRestored;

  const ChapterScrollView({
    super.key,
    required this.index,
    required this.currentChapterIndex,
    required this.totalChapters,
    required this.scrollController,
    required this.shouldRestoreScroll,
    required this.initialScrollPosition,
    required this.blocks,
    required this.chapterPath,
    required this.settings,
    required this.colors,
    this.activeParagraphIndex,
    required this.libroId,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.onScrollRestored,
  });

  @override
  State<ChapterScrollView> createState() => _ChapterScrollViewState();
}

class _ChapterScrollViewState extends State<ChapterScrollView> {
  @override
  void initState() {
    super.initState();
    _attemptScrollRestore();
  }

  void _attemptScrollRestore() {
    if (!widget.shouldRestoreScroll) return;
    if (widget.index != widget.currentChapterIndex) return;
    if (widget.initialScrollPosition <= 0) return;

    int attempts = 0;
    void restoreScroll(Duration _) {
      if (!widget.scrollController.hasClients) return;
      if (widget.scrollController.position.maxScrollExtent > 0) {
        final targetPixels = widget.initialScrollPosition * widget.scrollController.position.maxScrollExtent;
        widget.scrollController.jumpTo(
          targetPixels.clamp(0.0, widget.scrollController.position.maxScrollExtent),
        );
        widget.onScrollRestored();
      } else if (attempts < 20) {
        attempts++;
        WidgetsBinding.instance.addPostFrameCallback(restoreScroll);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback(restoreScroll);
  }

  int _getActiveTextBlockIndex(List<ReaderBlock> blocks, int paragraphIndex) {
    int textBlockIndex = 0;
    for (int i = 0; i < blocks.length && textBlockIndex <= paragraphIndex; i++) {
      if (blocks[i].type == 'text' || blocks[i].type == 'p') {
        if (textBlockIndex == paragraphIndex) {
          return i;
        }
        textBlockIndex++;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -100 && widget.currentChapterIndex < widget.totalChapters - 1) {
                widget.onNextPage();
              } else if (details.primaryVelocity! > 100 && widget.currentChapterIndex > 0) {
                widget.onPreviousPage();
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification && widget.index == widget.currentChapterIndex) {
                final metrics = notification.metrics;
                if (metrics.maxScrollExtent > 0) {
                  final scrollFraction = metrics.pixels / metrics.maxScrollExtent;
                  context.read<ReaderCubit>().saveProgress(
                    scrollFraction,
                    chapterIndex: widget.currentChapterIndex,
                  );
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.only(
                left: widget.settings.marginHorizontal,
                right: widget.settings.marginHorizontal,
                top: MediaQuery.of(context).padding.top + 56 + 16,
                bottom: MediaQuery.of(context).padding.bottom + 100 + 16,
              ),
              child: SizedBox(
                width: constraints.maxWidth,
                child: BlocBuilder<HighlightCubit, HighlightState>(
                  builder: (context, highlightState) {
                    final highlights = highlightState is HighlightLoaded
                        ? highlightState.highlights
                        : <Highlight>[];
                    return _buildChapterContent(context, highlights);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterContent(BuildContext context, List<Highlight> highlights) {
    final readerCubit = context.read<ReaderCubit>();
    final readerState = readerCubit.state;
    final currentChapterIndex = readerState is ReaderLoaded ? readerState.currentChapterIndex : 0;

    final activeIndex = widget.activeParagraphIndex != null
        ? _getActiveTextBlockIndex(widget.blocks, widget.activeParagraphIndex!)
        : null;

    return ChapterContent(
      blocks: widget.blocks,
      libroId: widget.libroId,
      chapterPath: widget.chapterPath,
      fontSize: widget.settings.fontSize,
      lineHeight: widget.settings.lineHeight,
      horizontalMargin: 0,
      textColor: widget.colors.text,
      backgroundColor: widget.colors.background,
      fontFamily: widget.settings.fontFamily,
      highlights: highlights,
      activeParagraphIndex: activeIndex,
      onTextSelected: (text, start, end, color) {
        context.read<HighlightCubit>().crearHighlight(
          bookId: widget.libroId,
          chapterIndex: currentChapterIndex,
          text: text,
          startIndex: start,
          endIndex: end,
          color: color,
        );
      },
      onHighlightTap: (highlight) {
        context.read<HighlightCubit>().eliminarHighlight(highlight.id!);
      },
    );
  }
}