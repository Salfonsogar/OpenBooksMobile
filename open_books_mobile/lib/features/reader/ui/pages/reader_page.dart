import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../../shared/services/sync_service.dart';
import '../../../../shared/services/local_database.dart';
import '../../data/datasources/highlight_datasource.dart';
import '../../data/models/audio_player_state.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/highlight.dart';
import '../../data/models/reader_mode.dart';
import '../../data/models/reader_settings.dart';
import '../../data/repositories/epub_repository.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/bookmark_state.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/highlight_state.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/audio_footer.dart';
import '../widgets/epub_parser.dart';
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
  late ReaderCubit _readerCubit;
  late ReaderSettingsCubit _settingsCubit;
  late BookmarkCubit _bookmarkCubit;
  late HighlightCubit _highlightCubit;
  late AudioPlayerCubit _audioPlayerCubit;
  final HighlightDataSource _highlightDataSource = HighlightDataSource();
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
    print('[DEBUG ReaderPage] _initReader started for libroId: ${widget.libroId}');
    
    try {
      final syncService = getIt<SyncService>();
      final sessionCubit = getIt<SessionCubit>();
      final localDatabase = getIt<LocalDatabase>();
      final sessionState = sessionCubit.state;
      final usuarioId = sessionState is SessionAuthenticated ? sessionState.userId : 1;
      print('[DEBUG ReaderPage] usuarioId: $usuarioId');
      
      int savedPage = 0;
      try {
        print('[DEBUG ReaderPage] Getting saved page from local database...');
        final libro = await localDatabase.bibliotecaLocalDataSource.getByLibroId(widget.libroId, usuarioId);
        print('[DEBUG ReaderPage] Libro found: ${libro != null}, page: ${libro?.page}');
        if (libro != null && libro.page != null) {
          savedPage = libro.page!;
          print('[DEBUG ReaderPage] Saved page: $savedPage');
        }
      } catch (e) {
        print('[DEBUG ReaderPage] Error getting book: $e');
      }
      
      print('[DEBUG ReaderPage] Creating ReaderCubit with initialPage: $savedPage');
      _readerCubit = ReaderCubit(
        getIt<EpubRepository>(),
        widget.libroId,
        initialPage: savedPage,
      );
      print('[DEBUG ReaderPage] ReaderCubit created');
      
      _readerCubit.setOnProgressChanged(({
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
      
      print('[DEBUG ReaderPage] Setting up other cubits...');
      _settingsCubit = getIt<ReaderSettingsCubit>();
      _bookmarkCubit = getIt<BookmarkCubit>();
      _highlightCubit = HighlightCubit(_highlightDataSource);
      _audioPlayerCubit = getIt<AudioPlayerCubit>(param1: widget.libroId);
      
      print('[DEBUG ReaderPage] Loading data...');
      _settingsCubit.cargarSettings();
      _readerCubit.cargarLibro();
      _bookmarkCubit.cargarBookmarks(widget.libroId);
      _highlightCubit.cargarHighlights(widget.libroId);
      
      print('[DEBUG ReaderPage] All loaded, setting state...');
      setState(() {
        _isInitialized = true;
      });
      print('[DEBUG ReaderPage] Done!');
    } catch (e, stack) {
      print('[DEBUG ReaderPage] ERROR: $e');
      print('[DEBUG ReaderPage] STACK: $stack');
      rethrow;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _readerCubit.onReaderClosed();
    _readerCubit.close();
    _bookmarkCubit.close();
    _highlightCubit.close();
    _audioPlayerCubit.close();
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _readerCubit),
          BlocProvider.value(value: _settingsCubit),
          BlocProvider.value(value: _bookmarkCubit),
          BlocProvider.value(value: _highlightCubit),
          BlocProvider.value(value: _audioPlayerCubit),
        ],
        child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
          builder: (context, settings) {
            final themeType = _parseThemeType(settings.theme);
            final colors = ReaderColors.fromTheme(themeType);

            return Scaffold(
              backgroundColor: colors.background,
              body: BlocConsumer<ReaderCubit, ReaderState>(
                listener: (context, state) {
                  print('[DEBUG ReaderPage] BlocConsumer listener: ${state.runtimeType}');
                  if (state is ReaderLoaded) {
                    print('[DEBUG ReaderPage] ReaderLoaded: ${state.manifest.readingOrder.length} capítulos, currentChapterIndex: ${state.currentChapterIndex}');
                    setState(() {
                      _chapters = state.manifest.readingOrder;
                      _currentIndex = state.currentChapterIndex;
                      print('[DEBUG ReaderPage] _chapters actualizado a: ${_chapters.length}');
                    });
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(state.currentChapterIndex);
                    }
                  } else if (state is ReaderError) {
                    print('[DEBUG ReaderPage] ReaderError: ${state.message}');
                  } else if (state is ReaderLoading) {
                    print('[DEBUG ReaderPage] ReaderLoading');
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
                            key: ValueKey(_readerCubit.currentMode),
                            child: _buildContent(state, settings, colors),
                          ),
                        ),
                        if (_showUi) _buildHeader(state, colors),
                        if (_showUi) _buildFooter(state, colors),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
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

  Future<void> _goToChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;

    setState(() {
      _currentIndex = index;
      _paragraphs = [];
    });

    await _readerCubit.cargarCapitulo(index);
    
    if (_readerCubit.currentMode == ReaderMode.audio) {
      final content = await _readerCubit.obtenerContenido(index);
      if (content != null) {
        final paragraphs = _extractParagraphs(content);
        _paragraphs = paragraphs;
        _audioPlayerCubit.loadParagraphs(paragraphs);
      }
    }

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  Widget _buildContent(ReaderState state, ReaderSettings settings, ReaderColors colors) {
    final currentMode = _readerCubit.currentMode;

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
              onPressed: () => _readerCubit.cargarLibro(),
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
          _paragraphs = _extractParagraphs(state.currentContent);
          _audioPlayerCubit.loadParagraphs(_paragraphs);
        }
        return _buildReadingView(state, settings, colors);
      }

      return _buildReadingView(state, settings, colors);
    }

    return const SizedBox();
  }

  List<String> _extractParagraphs(String content) {
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

  Widget _buildReadingView(ReaderLoaded state, ReaderSettings settings, ReaderColors colors) {
    final isAudioMode = _readerCubit.currentMode == ReaderMode.audio;
    
    if (isAudioMode) {
      return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
        buildWhen: (prev, curr) => prev.currentParagraphIndex != curr.currentParagraphIndex,
        builder: (context, audioState) {
          return _buildPageView(state, settings, colors, audioState.currentParagraphIndex, true);
        },
      );
    }
    
    return _buildPageView(state, settings, colors, null, false);
  }

  Widget _buildPageView(ReaderLoaded state, ReaderSettings settings, ReaderColors colors, int? activeParagraphIndex, bool isAudioMode) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _chapters.length,
      onPageChanged: (index) async {
        setState(() {
          _currentIndex = index;
          _paragraphs = [];
        });
        _highlightCubit.cargarHighlightsPorCapitulo(index);
        
        if (_readerCubit.currentMode == ReaderMode.audio) {
          final content = await _readerCubit.obtenerContenido(index);
          if (content != null) {
            final paragraphs = _extractParagraphs(content);
            setState(() {
              _paragraphs = paragraphs;
            });
            _audioPlayerCubit.loadParagraphs(paragraphs);
          }
        }
      },
      itemBuilder: (context, index) {
        final chapterPath = _chapters[index].href;
        print('[DEBUG ReaderPage] itemBuilder índice=$index, chapterPath=$chapterPath');
        return FutureBuilder<String?>(
          future: _readerCubit.obtenerContenido(index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('[DEBUG ReaderPage] Error cargando capítulo $index: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 8),
                    Text('Error al cargar capítulo ${index + 1}'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _readerCubit.cargarCapitulo(index),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 8),
                    Text('Capítulo ${index + 1} no disponible'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _readerCubit.cargarCapitulo(index),
                      child: const Text('Cargar'),
                    ),
                  ],
                ),
              );
            }

            final rawContent = snapshot.data!;
            print('[DEBUG ReaderPage] rawContent índice=$index, length=${rawContent.length}');
            final fixedContent = _parser.fixImagePaths(rawContent, chapterPath);
            final blocks = _parser.parse(fixedContent);
            print('[DEBUG ReaderPage] blocks índice=$index, count=${blocks.length}');

            if (blocks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.article_outlined, size: 48),
                    const SizedBox(height: 8),
                    Text('Capítulo ${index + 1} vacío (raw: ${rawContent.length} chars)'),
                    const SizedBox(height: 8),
                    Text('Ruta: $chapterPath'),
                  ],
                ),
              );
            }

            if (index == _currentIndex && _paragraphs.isEmpty) {
              _paragraphs = _extractParagraphs(fixedContent);
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
        _highlightCubit.crearHighlight(
          bookId: widget.libroId,
          chapterIndex: _currentIndex,
          text: text,
          startIndex: start,
          endIndex: end,
          color: color,
        );
      },
      onHighlightTap: (highlight) {
        _highlightCubit.eliminarHighlight(highlight.id!);
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

  Widget _buildHeader(ReaderState state, ReaderColors colors) {
    String titulo = 'Cargando...';
    if (state is ReaderLoaded) {
      titulo = state.manifest.titulo;
    }

    return ReaderHeader(
      title: titulo,
      colors: colors,
      topPadding: MediaQuery.of(context).padding.top,
      onBack: () {
        _readerCubit.saveProgressNow();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      onSearch: () => _showSearch(state, colors),
      onSettings: () => _showSettings(),
      currentMode: _readerCubit.currentMode,
      onModeChanged: (mode) => _readerCubit.setReaderMode(mode),
    );
  }

  Widget _buildFooter(ReaderState state, ReaderColors colors) {
    final currentMode = _readerCubit.currentMode;

    if (currentMode == ReaderMode.audio) {
      return AudioFooter(
        colors: colors,
        bottomPadding: MediaQuery.of(context).padding.bottom,
        onPreviousChapter: () {
          if (_currentIndex > 0) {
            _goToChapter(_currentIndex - 1);
          }
        },
        onNextChapter: () {
          if (_currentIndex < _chapters.length - 1) {
            _goToChapter(_currentIndex + 1);
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
      onToc: () => _showToc(state, colors),
      onSettings: () => _showSettings(),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: _settingsCubit,
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

  void _showToc(ReaderState state, ReaderColors colors) {
    if (state is! ReaderLoaded) return;

    final toc = state.manifest.toc;
    if (toc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay índice disponible')),
      );
      return;
    }

    final bookmarkState = _bookmarkCubit.state;
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
          _readerCubit.irACapitulo(chapterIndex);
        },
        onCreateBookmark: (title) {
          _bookmarkCubit.crearBookmark(
            bookId: widget.libroId,
            chapterIndex: _currentIndex,
            title: title,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marcador "$title" agregado')),
          );
        },
        onUpdateBookmark: (id, title) {
          _bookmarkCubit.actualizarBookmark(
            id: id,
            bookId: widget.libroId,
            chapterIndex: _currentIndex,
            title: title,
          );
        },
        onDeleteBookmark: (id) {
          _bookmarkCubit.eliminarBookmark(id, widget.libroId);
        },
      ),
    );
  }

  void _showSearch(ReaderState state, ReaderColors colors) {
    if (state is! ReaderLoaded) return;

    showSearchDialog(
      context: context,
      colors: colors,
      callbacks: SearchCallbacks(
        onSearch: (query) async {
          final results = <SearchResult>[];
          final queryLower = query.toLowerCase();

          for (var i = 0; i < _chapters.length; i++) {
            final content = await _readerCubit.obtenerContenido(i);
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
