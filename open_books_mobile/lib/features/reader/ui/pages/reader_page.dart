import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../data/models/reader_mode.dart';
import '../../data/models/reader_settings.dart';
import '../../logic/cubit/highlight_cubit.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/audio_footer.dart';
import '../../logic/epub_parser.dart';
import '../widgets/reader_colors.dart';
import '../widgets/reader_header.dart';
import '../widgets/reader_footer.dart';
import '../widgets/reader_states_view.dart';
import '../widgets/reader_dialogs.dart';
import '../widgets/scroll_controller_registry.dart';
import '../widgets/reader_progress_saver.dart';
import '../widgets/reader_page_view.dart';
import '../widgets/reader_block_utils.dart';
import '../widgets/reader_mode_coordinator.dart';

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
  final ScrollControllerRegistry _scrollControllerRegistry = ScrollControllerRegistry();
  bool _shouldRestoreScroll = false;
  late final ReaderModeCoordinator _modeCoordinator;

  @override
  void initState() {
    super.initState();
    _shouldRestoreScroll = true;
    _modeCoordinator = ReaderModeCoordinator(parser: _parser);
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



  @override
  void dispose() {
    _pageController?.dispose();
    _scrollControllerRegistry.dispose();
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
          final themeType = parseThemeType(settings.theme);
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
                  _modeCoordinator.handleTransition(context, state);
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
      await ReaderProgressSaver.saveProgress(
        readerCubit,
        _scrollControllerRegistry,
        state,
      );
    }
  }

  Widget _buildContent(BuildContext context, ReaderState state, ReaderSettings settings, ReaderColors colors) {
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
      return ReaderStatesView(
        isLoading: true,
        loadingMessage: message,
        hasError: false,
        errorMessage: '',
        onRetry: () {},
        onGoBack: () {},
      );
    }

    if (state is ReaderError) {
      return ReaderStatesView(
        isLoading: false,
        loadingMessage: '',
        hasError: true,
        errorMessage: state.message,
        onRetry: () {
          final sessionState = context.read<SessionCubit>().state;
          int? usuarioId;
          if (sessionState is SessionAuthenticated) {
            usuarioId = sessionState.user.id;
          }
          context.read<ReaderCubit>().cargarLibro(usuarioId: usuarioId);
        },
        onGoBack: () => context.pop(),
      );
    }

    if (state is ReaderLoaded) {
      if (state.manifest.readingOrder.isEmpty) {
        return const Center(child: Text('No hay capítulos'));
      }

      if (_pageController == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return ReaderPageView(
        pageController: _pageController!,
        state: state,
        settings: settings,
        colors: colors,
        scrollControllerRegistry: _scrollControllerRegistry,
        parser: _parser,
        paragraphs: _paragraphs,
        shouldRestoreScroll: _shouldRestoreScroll,
        libroId: widget.libroId,
        onParagraphsChanged: (paragraphs) => setState(() => _paragraphs = paragraphs),
        onScrollRestored: () => setState(() => _shouldRestoreScroll = false),
      );
    }

    return const SizedBox();
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
onSearch: () => ReaderDialogs.showSearch(
  context: context,
  state: state,
  colors: colors,
  onResultTap: (chapterIndex, _) => _pageController?.jumpToPage(chapterIndex),
),
onSettings: () => ReaderDialogs.showSettings(context),
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
      onToc: () => ReaderDialogs.showToc(
        context: context,
        state: state,
        colors: colors,
        libroId: widget.libroId,
        onChapterTap: (chapterIndex) {
          _pageController?.jumpToPage(chapterIndex);
          context.read<ReaderCubit>().irACapitulo(chapterIndex);
        },
      ),
      onSettings: () => ReaderDialogs.showSettings(context),
    );
  }
}
