import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/highlight_state.dart';
import '../../data/models/highlight.dart';
import 'epub_parser.dart';

class ReadingView extends StatelessWidget {
  final List<ReadingOrderItem> chapters;
  final int currentIndex;
  final ReaderSettings settings;
  final Color textColor;
  final Color backgroundColor;
  final int libroId;
  final Future<String?> Function(int) getChapterContent;
  final Function(int) onChapterChanged;
  final Function(String, int, int, String) onTextSelected;
  final Function(Highlight) onHighlightTap;
  final PageController pageController;

  const ReadingView({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.settings,
    required this.textColor,
    required this.backgroundColor,
    required this.libroId,
    required this.getChapterContent,
    required this.onChapterChanged,
    required this.onTextSelected,
    required this.onHighlightTap,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final parser = EpubParser();

    return PageView.builder(
      controller: pageController,
      itemCount: chapters.length,
      onPageChanged: onChapterChanged,
      itemBuilder: (context, index) {
        final chapterPath = chapters[index].href;
        return FutureBuilder<String?>(
          future: getChapterContent(index),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawContent = snapshot.data!;
            final fixedContent = parser.fixImagePaths(rawContent, chapterPath);
            final blocks = parser.parse(fixedContent);

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: settings.marginHorizontal,
                    right: settings.marginHorizontal,
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
                        return ChapterContent(
                          blocks: blocks,
                          libroId: libroId,
                          chapterPath: chapterPath,
                          fontSize: settings.fontSize,
                          lineHeight: settings.lineHeight,
                          horizontalMargin: 0,
                          textColor: textColor,
                          backgroundColor: backgroundColor,
                          fontFamily: settings.fontFamily,
                          highlights: highlights,
                          onTextSelected: onTextSelected,
                          onHighlightTap: onHighlightTap,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}