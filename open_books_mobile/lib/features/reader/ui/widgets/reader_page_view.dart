import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/audio_player_state.dart';
import '../../data/models/reader_mode.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/epub_parser.dart';
import 'reader_colors.dart';
import 'scroll_controller_registry.dart';
import 'chapter_scroll_view.dart';

class ReaderPageView extends StatelessWidget {
  final PageController pageController;
  final ReaderLoaded state;
  final ReaderSettings settings;
  final ReaderColors colors;
  final ScrollControllerRegistry scrollControllerRegistry;
  final EpubParser parser;
  final List<String> paragraphs;
  final bool shouldRestoreScroll;
  final int libroId;
  final void Function(List<String> paragraphs) onParagraphsChanged;
  final VoidCallback onScrollRestored;

  const ReaderPageView({
    super.key,
    required this.pageController,
    required this.state,
    required this.settings,
    required this.colors,
    required this.scrollControllerRegistry,
    required this.parser,
    required this.paragraphs,
    required this.shouldRestoreScroll,
    required this.libroId,
    required this.onParagraphsChanged,
    required this.onScrollRestored,
  });

  @override
  Widget build(BuildContext context) {
    final isAudioMode = state.mode == ReaderMode.audio;

    if (isAudioMode) {
      return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
        buildWhen: (prev, curr) => prev.currentParagraphIndex != curr.currentParagraphIndex,
        builder: (context, audioState) {
          return _buildPageView(context, audioState.currentParagraphIndex);
        },
      );
    }

    return _buildPageView(context, null);
  }

  Widget _buildPageView(BuildContext context, int? activeParagraphIndex) {
    final chapters = state.manifest.readingOrder;
    final readerCubit = context.read<ReaderCubit>();

    return PageView.builder(
      controller: pageController,
      itemCount: chapters.length,
      onPageChanged: (index) async {
        final oldState = readerCubit.state;
        if (oldState is ReaderLoaded) {
          final oldController = scrollControllerRegistry.controller(oldState.currentChapterIndex);
          if (oldController != null && oldController.hasClients && oldController.position.maxScrollExtent > 0) {
            final scrollFraction = oldController.position.pixels / oldController.position.maxScrollExtent;
            readerCubit.saveProgress(scrollFraction, chapterIndex: oldState.currentChapterIndex);
          }
        }

        context.read<HighlightCubit>().cargarHighlightsPorCapitulo(index);
        readerCubit.cargarCapitulo(index);

        if (readerCubit.currentMode == ReaderMode.audio) {
          final content = await readerCubit.obtenerContenido(index);
          if (content != null && context.mounted) {
            final newParagraphs = parser.extractParagraphs(content);
            context.read<AudioPlayerCubit>().loadParagraphs(newParagraphs);
            onParagraphsChanged(newParagraphs);
          }
        }
      },
      itemBuilder: (context, index) {
        final chapterPath = chapters[index].href;
        final scrollController = scrollControllerRegistry.getController(index);

        return FutureBuilder<String?>(
          future: readerCubit.obtenerContenido(index),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawContent = snapshot.data!;
            final fixedContent = parser.fixImagePaths(rawContent, chapterPath);
            final blocks = parser.parse(fixedContent);

            if (index == state.currentChapterIndex && paragraphs.isEmpty) {
              final extracted = parser.extractParagraphs(fixedContent);
              onParagraphsChanged(extracted);
            }

            return ChapterScrollView(
              index: index,
              currentChapterIndex: state.currentChapterIndex,
              totalChapters: chapters.length,
              scrollController: scrollController,
              shouldRestoreScroll: shouldRestoreScroll,
              initialScrollPosition: state.scrollPosition,
              blocks: blocks,
              chapterPath: chapterPath,
              settings: settings,
              colors: colors,
              activeParagraphIndex: activeParagraphIndex,
              libroId: libroId,
              onNextPage: () => pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              onPreviousPage: () => pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              onScrollRestored: onScrollRestored,
            );
          },
        );
      },
    );
  }
}