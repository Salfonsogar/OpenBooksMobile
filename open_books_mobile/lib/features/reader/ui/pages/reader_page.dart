import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/audio_player_state.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/highlight.dart';
import '../../data/models/reader_mode.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/bookmark_state.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/highlight_state.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/audio_footer.dart';
import '../widgets/epub_parser.dart';
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
  final PageController _pageController = PageController();
  final EpubParser _parser = EpubParser();
  bool _showUi = true;
  List<String> _paragraphs = [];

  @override
  void initState() {
    super.initState();
    _initReader();
  }

  Future<void> _initReader() async {
    try {
      final readerCubit = context.read<ReaderCubit>();
      final settingsCubit = context.read<ReaderSettingsCubit>();
      final bookmarkCubit = context.read<BookmarkCubit>();
      final highlightCubit = context.read<HighlightCubit>();

      settingsCubit.cargarSettings();
      readerCubit.cargarLibro();
      bookmarkCubit.cargarBookmarks(widget.libroId);
      highlightCubit.cargarHighlights(widget.libroId);
    } catch (e, stack) {
      debugPrint('[ReaderPage] ERROR: $e');
      debugPrint('[ReaderPage] STACK: $stack');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
        builder: (context, settings) {
          final themeType = _parseThemeType(settings.theme);
          final colors = ReaderColors.fromTheme(themeType);

          return Scaffold(
            backgroundColor: colors.background,
            body: BlocConsumer<ReaderCubit, ReaderState>(
              listener: (context, state) {
                if (state is ReaderLoaded) {
                  if (_pageController.hasClients && _pageController.page?.round() != state.currentChapterIndex) {
                    _pageController.jumpToPage(state.currentChapterIndex);
                  }
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: KeyedSubtree(
                          key: ValueKey(context.read<ReaderCubit>().currentMode),
                          child: _buildContent(context, state, settings, colors),
                        ),
                      ),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReaderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => readerCubit.cargarLibro(),
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
    final isAudioMode = context.read<ReaderCubit>().currentMode == ReaderMode.audio;

    if (isAudioMode && _paragraphs.isEmpty) {
      _paragraphs = _parser.extractParagraphs(state.currentContent);
      if (context.mounted) {
        context.read<AudioPlayerCubit>().loadParagraphs(_paragraphs);
      }
    }

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

    return PageView.builder(
      controller: _pageController,
      itemCount: chapters.length,
      onPageChanged: (index) async {
        context.read<HighlightCubit>().cargarHighlightsPorCapitulo(index);

        if (context.read<ReaderCubit>().currentMode == ReaderMode.audio) {
          final content = await context.read<ReaderCubit>().obtenerContenido(index);
          if (content != null) {
            final paragraphs = _parser.extractParagraphs(content);
            setState(() {
              _paragraphs = paragraphs;
            });
            if (context.mounted) {
              context.read<AudioPlayerCubit>().loadParagraphs(_paragraphs);
            }
          }
        }
      },
      itemBuilder: (context, index) {
        final chapterPath = chapters[index].href;
        return FutureBuilder<String?>(
          future: context.read<ReaderCubit>().obtenerContenido(index),
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
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -100 && state.currentChapterIndex < chapters.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else if (details.primaryVelocity! > 100 && state.currentChapterIndex > 0) {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    }
                  },
                  child: SingleChildScrollView(
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
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
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
      onPageSelected: (index) {
        _pageController.jumpToPage(index);
      },
      onPrevious: () {
        if (currentChapterIndex > 0) {
          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      onNext: () {
        if (currentChapterIndex < totalChapters - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
          _pageController.jumpToPage(chapterIndex);
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
          _pageController.jumpToPage(chapterIndex);
        },
      ),
    );
  }
}
