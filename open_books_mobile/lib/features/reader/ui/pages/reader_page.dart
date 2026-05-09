import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../data/models/audio_player_state.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/highlight.dart';
import '../../data/models/reader_mode.dart';
import '../../data/models/reader_block.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/bookmark_state.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/highlight_state.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/audio_footer.dart';
import '../../logic/epub_parser.dart';
import '../widgets/reader_blocks.dart';
import '../widgets/reader_colors.dart';
import '../widgets/reader_header.dart';
import '../widgets/reader_footer.dart';
import '../widgets/toc_dialog.dart';
import '../widgets/search_dialog.dart';
import '../widgets/reader_settings.dart';

class ReaderPage extends StatefulWidget {
  final int libroId;

  const ReaderPage({super.key, required this.libroId});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  PageController? _pageController;
  final EpubParser _parser = EpubParser();
  bool _showUi = true;
  List<String> _paragraphs = [];
  final Map<int, ScrollController> _scrollControllers = {};
  bool _shouldRestoreScroll = false;
  ReaderMode? _previousMode;

  @override
  void initState() {
    super.initState();
    _shouldRestoreScroll = true;
    _initReader();
  }

  Future<void> _initReader() async {
    try {
      final readerCubit = context.read<ReaderCubit>();
      final settingsCubit = context.read<ReaderSettingsCubit>();
      final bookmarkCubit = context.read<BookmarkCubit>();
      final highlightCubit = context.read<HighlightCubit>();

      int? usuarioId;
      final sessionState = context.read<SessionCubit>().state;
      if (sessionState is SessionAuthenticated) {
        usuarioId = sessionState.user.id;
      }

      await readerCubit.cargarLibro(usuarioId: usuarioId);

      await Future.wait([
        settingsCubit.cargarSettings(),
        bookmarkCubit.cargarBookmarks(widget.libroId),
        highlightCubit.cargarHighlights(widget.libroId),
      ]);
    } catch (e, stack) {
      debugPrint('[ReaderPage] ERROR: $e');
      debugPrint('[ReaderPage] STACK: $stack');
    }
  }

  ScrollController _getScrollController(int index) {
    if (!_scrollControllers.containsKey(index)) {
      _scrollControllers[index] = ScrollController();
    }
    return _scrollControllers[index]!;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        await _saveCurrentProgress();
        
        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/library');
          }
        }
      },
      child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          final themeType = _parseThemeType(settings.theme);
          final colors = ReaderColors.fromTheme(themeType);

          return Scaffold(
            backgroundColor: colors.background,
            body: BlocConsumer<ReaderCubit, ReaderState>(
              listener: (context, state) {
                if (state is ReaderLoaded) {
                  if (_pageController == null) {
                    _pageController = PageController(initialPage: state.currentChapterIndex);
                  } else if (_pageController!.hasClients && _pageController!.page?.round() != state.currentChapterIndex) {
                    _pageController!.jumpToPage(state.currentChapterIndex);
                  }
                  _handleModeTransition(context, state);
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _showUi = !_showUi;
                    });
                  },
              child: Stack(
                children: [
                  _buildContent(context, state, settings, colors),
                  if (_showUi) _buildHeader(context, state, colors),
                  if (_showUi) _buildFooter(context, state, colors),
                ],
              ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveCurrentProgress() async {
    final readerCubit = context.read<ReaderCubit>();
    final state = readerCubit.state;
    if (state is ReaderLoaded) {
      final controller = _scrollControllers[state.currentChapterIndex];
      if (controller != null && controller.hasClients && controller.position.maxScrollExtent > 0) {
        final scrollFraction = controller.position.pixels / controller.position.maxScrollExtent;
        await readerCubit.saveProgress(scrollFraction, chapterIndex: state.currentChapterIndex);
      } else if (state.scrollPosition > 0) {
        // If no controller or no extent, save the current state's scroll position just in case
        await readerCubit.saveProgress(state.scrollPosition, chapterIndex: state.currentChapterIndex);
      } else {
        await readerCubit.saveProgress(0.0, chapterIndex: state.currentChapterIndex);
      }
    }
  }

  void _handleModeTransition(BuildContext context, ReaderState state) {
    if (state is! ReaderLoaded) return;

    final currentMode = state.mode;
    if (_previousMode == currentMode) return;

    if (_previousMode == ReaderMode.audio && currentMode == ReaderMode.reading) {
      context.read<AudioPlayerCubit>().stop();
    }

    if (_previousMode == ReaderMode.reading && currentMode == ReaderMode.audio) {
      _initializeAudio(context, state);
    }

    _previousMode = currentMode;
  }

  void _initializeAudio(BuildContext context, ReaderLoaded state) {
    final content = state.currentContent;
    _paragraphs = _parser.extractParagraphs(content);
    if (context.mounted) {
      context.read<AudioPlayerCubit>().loadParagraphs(_paragraphs);
    }
  }

  ReaderThemeType _parseThemeType(String theme) {
    switch (theme) {
      case 'sepia':
        return ReaderThemeType.sepia;
      case 'dark':
        return ReaderThemeType.dark;
      default:
        return ReaderThemeType.light;
    }
  }

  Widget _buildContent(BuildContext context, ReaderState state, ReaderSettings settings, ReaderColors colors) {
    final readerCubit = context.read<ReaderCubit>();
    final currentMode = readerCubit.currentMode;

    if (state is ReaderLoading) {
      String message;
      switch (state.step) {
        case 'manifest':
          message = 'Cargando libro...';
          break;
        case 'progress':
          message = 'Restaurando progreso...';
          break;
        case 'chapter':
          message = 'Cargando capítulo...';
          break;
        default:
          message = 'Cargando...';
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      );
    }

    if (state is ReaderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(state.message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final sessionState = context.read<SessionCubit>().state;
                int? usuarioId;
                if (sessionState is SessionAuthenticated) {
                  usuarioId = sessionState.user.id;
                }
                readerCubit.cargarLibro(usuarioId: usuarioId);
              },
              child: const Text('Reintentar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    if (state is ReaderLoaded) {
      if (state.manifest.readingOrder.isEmpty) {
        return const Center(child: Text('No hay capítulos'));
      }

      if (currentMode == ReaderMode.audio) {
        return _buildReadingView(context, state, settings, colors);
      }

      return _buildReadingView(context, state, settings, colors);
    }

    return const SizedBox();
  }

  Widget _buildReadingView(BuildContext context, ReaderLoaded state, ReaderSettings settings, ReaderColors colors) {
    final isAudioMode = state.mode == ReaderMode.audio;

    if (isAudioMode) {
      return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
        buildWhen: (prev, curr) => prev.currentParagraphIndex != curr.currentParagraphIndex,
        builder: (context, audioState) {
          return _buildPageView(context, state, settings, colors, audioState.currentParagraphIndex);
        },
      );
    }

    return _buildPageView(context, state, settings, colors, null);
  }

  Widget _buildPageView(BuildContext context, ReaderLoaded state, ReaderSettings settings, ReaderColors colors, int? activeParagraphIndex) {
    final chapters = state.manifest.readingOrder;
    final readerCubit = context.read<ReaderCubit>();

    if (_pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: chapters.length,
      onPageChanged: (index) async {
        final oldState = readerCubit.state;
        if (oldState is ReaderLoaded) {
          final oldController = _scrollControllers[oldState.currentChapterIndex];
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
            _paragraphs = _parser.extractParagraphs(content);
            context.read<AudioPlayerCubit>().loadParagraphs(_paragraphs);
          }
        }
      },
      itemBuilder: (context, index) {
        final chapterPath = chapters[index].href;
        final scrollController = _getScrollController(index);

        if (index == state.currentChapterIndex && state.scrollPosition > 0 && _shouldRestoreScroll) {
          int attempts = 0;
          void restoreScroll(Duration _) {
            if (!scrollController.hasClients) return;
            if (scrollController.position.maxScrollExtent > 0) {
              final targetPixels = state.scrollPosition * scrollController.position.maxScrollExtent;
              scrollController.jumpTo(targetPixels.clamp(0.0, scrollController.position.maxScrollExtent));
              _shouldRestoreScroll = false;
            } else if (attempts < 20) {
              attempts++;
              WidgetsBinding.instance.addPostFrameCallback(restoreScroll);
            }
          }
          WidgetsBinding.instance.addPostFrameCallback(restoreScroll);
        }

        return FutureBuilder<String?>(
          future: readerCubit.obtenerContenido(index),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawContent = snapshot.data!;
            final fixedContent = _parser.fixImagePaths(rawContent, chapterPath);
            final blocks = _parser.parse(fixedContent);

            if (index == state.currentChapterIndex && _paragraphs.isEmpty) {
              _paragraphs = _parser.extractParagraphs(fixedContent);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null && _pageController != null) {
                      if (details.primaryVelocity! < -100 && state.currentChapterIndex < chapters.length - 1) {
                        _pageController!.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else if (details.primaryVelocity! > 100 && state.currentChapterIndex > 0) {
                        _pageController!.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    }
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification && index == state.currentChapterIndex) {
                        final metrics = notification.metrics;
                        if (metrics.maxScrollExtent > 0) {
                          final scrollFraction = metrics.pixels / metrics.maxScrollExtent;
                          readerCubit.saveProgress(scrollFraction, chapterIndex: state.currentChapterIndex);
                        }
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
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
                            return _buildChapterContent(
                              context,
                              blocks,
                              chapterPath,
                              settings,
                              colors,
                              highlights,
                              activeParagraphIndex: activeParagraphIndex != null
                                  ? _getActiveTextBlockIndex(blocks, activeParagraphIndex)
                                  : null,
                            );
                          },
                        ),
                      ),
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

  Widget _buildChapterContent(
    BuildContext context,
    List<ReaderBlock> blocks,
    String chapterPath,
    ReaderSettings settings,
    ReaderColors colors,
    List<Highlight> highlights, {
    int? activeParagraphIndex,
  }) {
    final currentChapterIndex = context.read<ReaderCubit>().state is ReaderLoaded
        ? (context.read<ReaderCubit>().state as ReaderLoaded).currentChapterIndex
        : 0;

    return ChapterContent(
      blocks: blocks,
      libroId: widget.libroId,
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

  Widget _buildHeader(BuildContext context, ReaderState state, ReaderColors colors) {
    String titulo = 'Cargando...';
    if (state is ReaderLoaded) {
      titulo = state.manifest.titulo;
    }

    return ReaderHeader(
      title: titulo,
      colors: colors,
      topPadding: MediaQuery.of(context).padding.top,
      onBack: () async {
        await _saveCurrentProgress();
        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/library');
          }
        }
      },
      onSearch: () => _showSearch(context, state, colors),
      onSettings: () => _showSettings(context),
      currentMode: context.read<ReaderCubit>().currentMode,
      onModeChanged: (mode) => context.read<ReaderCubit>().setReaderMode(mode),
    );
  }

  Widget _buildFooter(BuildContext context, ReaderState state, ReaderColors colors) {
    final currentMode = context.read<ReaderCubit>().currentMode;
    final currentChapterIndex = state is ReaderLoaded ? state.currentChapterIndex : 0;
    final totalChapters = state is ReaderLoaded ? state.manifest.readingOrder.length : 0;
    final scrollPosition = state is ReaderLoaded ? state.scrollPosition : 0.0;

    if (currentMode == ReaderMode.audio) {
      return AudioFooter(
        colors: colors,
        bottomPadding: MediaQuery.of(context).padding.bottom,
        onPreviousChapter: () {
          if (currentChapterIndex > 0) {
            context.read<ReaderCubit>().cargarCapitulo(currentChapterIndex - 1);
          }
        },
        onNextChapter: () {
          if (currentChapterIndex < totalChapters - 1) {
            context.read<ReaderCubit>().cargarCapitulo(currentChapterIndex + 1);
          }
        },
      );
    }

    return ReaderFooter(
      currentIndex: currentChapterIndex,
      totalChapters: totalChapters,
      colors: colors,
      bottomPadding: MediaQuery.of(context).padding.bottom,
      progressFraction: scrollPosition,
      onPageSelected: (index) {
        _pageController?.jumpToPage(index);
      },
      onPrevious: () {
        if (currentChapterIndex > 0) {
          _pageController?.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      onNext: () {
        if (currentChapterIndex < totalChapters - 1) {
          _pageController?.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      onToc: () => _showToc(context, state, colors),
      onSettings: () => _showSettings(context),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ReaderSettingsCubit>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ReaderSettingsSheet(),
        ),
      ),
    );
  }

  void _showToc(BuildContext context, ReaderState state, ReaderColors colors) {
    if (state is! ReaderLoaded) return;

    final toc = state.manifest.toc;
    if (toc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay índice disponible')),
      );
      return;
    }

    final bookmarkState = context.read<BookmarkCubit>().state;
    final bookmarks = bookmarkState is BookmarkLoaded ? bookmarkState.bookmarks : <Bookmark>[];

    showTocDialog(
      context: context,
      colors: colors,
      bookTitle: state.manifest.titulo,
      toc: toc,
      bookmarks: bookmarks,
      currentChapterIndex: state.currentChapterIndex,
      chapters: state.manifest.readingOrder,
      callbacks: TocDialogCallbacks(
        onChapterTap: (chapterIndex) {
          _pageController?.jumpToPage(chapterIndex);
          context.read<ReaderCubit>().irACapitulo(chapterIndex);
        },
        onCreateBookmark: (title) {
          context.read<BookmarkCubit>().crearBookmark(
            bookId: widget.libroId,
            chapterIndex: state.currentChapterIndex,
            title: title,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marcador "$title" agregado')),
          );
        },
        onUpdateBookmark: (id, title) {
          context.read<BookmarkCubit>().actualizarBookmark(
            id: id,
            bookId: widget.libroId,
            chapterIndex: state.currentChapterIndex,
            title: title,
          );
        },
        onDeleteBookmark: (id) {
          context.read<BookmarkCubit>().eliminarBookmark(id, widget.libroId);
        },
      ),
    );
  }

  void _showSearch(BuildContext context, ReaderState state, ReaderColors colors) {
    if (state is! ReaderLoaded) return;

    showSearchDialog(
      context: context,
      colors: colors,
      callbacks: SearchCallbacks(
        onSearch: (query) async {
          final results = <SearchResult>[];
          final queryLower = query.toLowerCase();
          final chapters = state.manifest.readingOrder;

          for (var i = 0; i < chapters.length; i++) {
            final content = await context.read<ReaderCubit>().obtenerContenido(i);
            if (content != null && content.toLowerCase().contains(queryLower)) {
              final toc = state.manifest.toc;
              String chapterTitle = 'Capítulo ${i + 1}';
              if (i < toc.length) {
                chapterTitle = toc[i].titulo;
              }

              results.add(SearchResult(
                text: content,
                chapterIndex: i,
                chapterTitle: chapterTitle,
              ));

              if (results.length >= 10) break;
            }
          }

          return results;
        },
        onResultTap: (chapterIndex, text) {
          _pageController?.jumpToPage(chapterIndex);
        },
      ),
    );
  }
}
