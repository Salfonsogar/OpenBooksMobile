import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../data/models/reader_settings.dart';
import '../../data/models/highlight.dart';
import '../../data/models/reader_block.dart';
import '../widgets/reader_blocks.dart';
import '../widgets/reader_colors.dart';

// ignore: avoid_classes_with_only_static_members
class ReaderContentBuilder {
  static Widget buildChapterContent({
    required BuildContext context,
    required List<ReaderBlock> blocks,
    required String chapterPath,
    required ReaderSettings settings,
    required ReaderColors colors,
    required List<Highlight> highlights,
    required int libroId,
    int? activeParagraphIndex,
  }) {
    final currentChapterIndex = context.read<ReaderCubit>().state is ReaderLoaded
        ? (context.read<ReaderCubit>().state as ReaderLoaded).currentChapterIndex
        : 0;

    return ChapterContent(
      blocks: blocks,
      libroId: libroId,
      chapterPath: chapterPath,
      fontSize: settings.fontSize,
      lineHeight: settings.lineHeight,
      horizontalMargin: 0,
      textColor: colors.text,
      backgroundColor: colors.background,
      fontFamily: settings.fontFamily,
      highlights: highlights,
      activeParagraphIndex: activeParagraphIndex,
      onTextSelected: (text, start, end, color) {
        context.read<HighlightCubit>().crearHighlight(
          bookId: libroId,
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

  static int getActiveTextBlockIndex(List<ReaderBlock> blocks, int paragraphIndex) {
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
}