import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../../shared/services/sync_service.dart';
import '../../../../shared/services/local_database.dart';
import '../../data/models/audio_player_state.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/epub_manifest.dart';
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
  List<ReadingOrderItem> _chapters = [];
  int _currentIndex = 0;
  List<String> _paragraphs = [];
  bool _isInitialized = false;

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
      final sessionCubit = context.read<SessionCubit>();
      final syncService = context.read<SyncService>();
      final localDatabase = context.read<LocalDatabase>();
      
      final sessionState = sessionCubit.state;
      final usuarioId = sessionState is SessionAuthenticated ? sessionState.userId : 1;
      
      int savedPage = 0;
      try {
        final libro = await localDatabase.bibliotecaLocalDataSource.getByLibroId(widget.libroId, usuarioId);
        if (libro != null && libro.page != null) {
          savedPage = libro.page!;
        }
      } catch (e) {
        debugPrint('[ReaderPage] Error getting saved page: $e');
      }
      
      readerCubit.setOnProgressChanged(({
        required int libroId,
        required double progreso,
        required int page,
        required int totalPages,
      }) async {
        final currentSessionState = sessionCubit.state;
        final currentUsuarioId = currentSessionState is SessionAuthenticated ? currentSessionState.userId : usuarioId;
        await syncService.addProgressUpdateToQueue(
          libroId: libroId,
          usuarioId: currentUsuarioId,
          progreso: progreso,
          page: page,
        );
      });
      
      settingsCubit.cargarSettings();
      readerCubit.cargarLibro(initialPage: savedPage);
      bookmarkCubit.cargarBookmarks(widget.libroId);
      highlightCubit.cargarHighlights(widget.libroId);
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e, stack) {
      debugPrint('[ReaderPage] ERROR: $e');
      debugPrint('[ReaderPage] STACK: $stack');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    context.read<ReaderCubit>().onReaderClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  setState(() {
                    _chapters = state.manifest.readingOrder;
                    _currentIndex = state.currentChapterIndex;
                  });
                  if (_pageController.hasClients) {
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

  Future<void> _goToChapter(BuildContext context, int index) async {
    if (index < 0 || index >= _chapters.length) return;

    final readerCubit = context.read<ReaderCubit>();
    final audioPlayerCubit = context.read<AudioPlayerCubit>();

    setState(() {
      _currentIndex = index;
      _paragraphs = [];
    });

    await readerCubit.cargarCapitulo(index);
    
    if (readerCubit.currentMode == ReaderMode.audio) {
      final content = await readerCubit.obtenerContenido(index);
      if (content != null) {
        final paragraphs = _parser.extractParagraphs(content);
        _paragraphs = paragraphs;
        if (context.mounted) {
          audioPlayerCubit.loadParagraphs(paragraphs);
        }
      }
    }

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
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
      if (_chapters.isEmpty) {
        return const Center(child: Text('No hay capítulos'));
      }

      if (currentMode == ReaderMode.audio) {
        if (_paragraphs.isEmpty) {
          _paragraphs = _parser.extractParagraphs(state.currentContent);
          if (context.mounted) {
            context.read<AudioPlayerCubit>().loadParagraphs(_paragraphs);
          }
        }
        return _buildReadingView(context, state, settings, colors);
      }

      return _buildReadingView(context, state, settings, colors);
    }

    return const SizedBox();
  }

  Widget _buildReadingView(BuildContext context, ReaderLoaded state, ReaderSettings settings, ReaderColors colors) {
    final isAudioMode = context.read<ReaderCubit>().currentMode == ReaderMode.audio;
    
    if (isAudioMode) {
      return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
        buildWhen: (prev, curr) => prev.currentParagraphIndex != curr.currentParagraphIndex,
        builder: (context, audioState) {
          return _buildPageView(context, state, settings, colors, audioState.currentParagraphIndex, true);
        },
      );
    }
    
    return _buildPageView(context, state, settings, colors, null, false);
  }

  Widget _buildPageView(BuildContext context, ReaderLoaded state, ReaderSettings settings, ReaderColors colors, int? activeParagraphIndex, bool isAudioMode) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _chapters.length,
      onPageChanged: (index) async {
        setState(() {
          _currentIndex = index;
          _paragraphs = [];
        });
        context.read<HighlightCubit>().cargarHighlightsPorCapitulo(index);
        
        if (context.read<ReaderCubit>().currentMode == ReaderMode.audio) {
          final content = await context.read<ReaderCubit>().obtenerContenido(index);
          if (content != null) {
            final paragraphs = _parser.extractParagraphs(content);
            setState(() {
              _paragraphs = paragraphs;
            });
            if (context.mounted) {
              context.read<AudioPlayerCubit>().loadParagraphs(paragraphs);
            }
          }
        }
      },
      itemBuilder: (context, index) {
        final chapterPath = _chapters[index].href;
        return FutureBuilder<String?>(
          future: context.read<ReaderCubit>().obtenerContenido(index),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawContent = snapshot.data!;
            final fixedContent = _parser.fixImagePaths(rawContent, chapterPath);
            final blocks = _parser.parse(fixedContent);

            if (index == _currentIndex && _paragraphs.isEmpty) {
              _paragraphs = _parser.extractParagraphs(fixedContent);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -100 && _currentIndex < _chapters.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else if (details.primaryVelocity! > 100 && _currentIndex > 0) {
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
          chapterIndex: _currentIndex,
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
        context.read<ReaderCubit>().saveProgressNow();
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

    if (currentMode == ReaderMode.audio) {
      return AudioFooter(
        colors: colors,
        bottomPadding: MediaQuery.of(context).padding.bottom,
        onPreviousChapter: () {
          if (_currentIndex > 0) {
            _goToChapter(context, _currentIndex - 1);
          }
        },
        onNextChapter: () {
          if (_currentIndex < _chapters.length - 1) {
            _goToChapter(context, _currentIndex + 1);
          }
        },
      );
    }

    return ReaderFooter(
      currentIndex: _currentIndex,
      totalChapters: _chapters.length,
      colors: colors,
      bottomPadding: MediaQuery.of(context).padding.bottom,
      onPageSelected: (index) {
        _pageController.jumpToPage(index);
        setState(() {
          _currentIndex = index;
        });
      },
      onPrevious: () {
        if (_currentIndex > 0) {
          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      onNext: () {
        if (_currentIndex < _chapters.length - 1) {
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
      currentChapterIndex: _currentIndex,
      chapters: _chapters,
      callbacks: TocDialogCallbacks(
        onChapterTap: (chapterIndex) {
          _pageController.jumpToPage(chapterIndex);
          setState(() {
            _currentIndex = chapterIndex;
          });
          context.read<ReaderCubit>().irACapitulo(chapterIndex);
        },
        onCreateBookmark: (title) {
          context.read<BookmarkCubit>().crearBookmark(
            bookId: widget.libroId,
            chapterIndex: _currentIndex,
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
            chapterIndex: _currentIndex,
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

          for (var i = 0; i < _chapters.length; i++) {
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
          setState(() {
            _currentIndex = chapterIndex;
          });
        },
      ),
    );
  }
}
