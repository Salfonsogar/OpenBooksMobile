import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_settings.dart';
import '../../data/repositories/epub_repository.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/cubit/reader_settings_cubit.dart';
import '../widgets/epub_parser.dart';
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
  late final ReaderCubit _readerCubit;
  late final ReaderSettingsCubit _settingsCubit;
  List<ReadingOrderItem> _chapters = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _readerCubit = ReaderCubit(
      getIt<EpubRepository>(),
      widget.libroId,
    );
    _settingsCubit = getIt<ReaderSettingsCubit>();
    _settingsCubit.cargarSettings();
    _readerCubit.cargarLibro();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _readerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _readerCubit),
          BlocProvider.value(value: _settingsCubit),
        ],
        child: BlocBuilder<ReaderSettingsCubit, ReaderSettings>(
          builder: (context, settings) {
            return _buildScaffold(settings);
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(ReaderSettings settings) {
    final themeColors = _getThemeColors(settings.theme);

    return Scaffold(
      backgroundColor: themeColors['background'],
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
                _buildContent(state, settings),
                if (_showUi) _buildHeader(state, settings),
                if (_showUi) _buildFooter(state, settings),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, Color> _getThemeColors(String theme) {
    switch (theme) {
      case 'sepia':
        return {
          'background': const Color(0xFFF4ECD8),
          'text': const Color(0xFF5B4636),
          'header': Colors.brown[800]!,
        };
      case 'dark':
        return {
          'background': Colors.grey[900]!,
          'text': Colors.grey[300]!,
          'header': Colors.black,
        };
      default:
        return {
          'background': Colors.white,
          'text': Colors.black87,
          'header': Colors.black.withValues(alpha: 0.8),
        };
    }
  }

  Widget _buildContent(ReaderState state, ReaderSettings settings) {
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

      final themeColors = _getThemeColors(settings.theme);

      return PageView.builder(
        controller: _pageController,
        itemCount: _chapters.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final chapterPath = _chapters[index].href;
          return FutureBuilder<String?>(
            future: _readerCubit.obtenerContenido(index),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final rawContent = snapshot.data!;
              final fixedContent = _parser.fixImagePaths(rawContent, chapterPath);
              final blocks = _parser.parse(fixedContent);

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
                        child: ChapterContent(
                          blocks: blocks,
                          libroId: widget.libroId,
                          chapterPath: chapterPath,
                          fontSize: settings.fontSize,
                          lineHeight: settings.lineHeight,
                          horizontalMargin: 0,
                          textColor: themeColors['text']!,
                          backgroundColor: themeColors['background']!,
                          fontFamily: settings.fontFamily,
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

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildHeader(ReaderState state, ReaderSettings settings) {
    String titulo = 'Cargando...';
    if (state is ReaderLoaded) {
      titulo = state.manifest.titulo;
    }

    final themeColors = _getThemeColors(settings.theme);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: themeColors['header'],
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: themeColors['background']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  color: themeColors['background'],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: themeColors['background']),
              onPressed: () => _showSettingsSheet(context),
            ),
            IconButton(
              icon: Icon(Icons.list, color: themeColors['background']),
              onPressed: () => _showTocDialog(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ReaderState state, ReaderSettings settings) {
    if (_chapters.isEmpty) {
      return const SizedBox();
    }

    final totalChapters = _chapters.length;
    final progress = ((_currentIndex + 1) / totalChapters * 100).toInt();
    final chapterName = _currentIndex < totalChapters
        ? 'Capítulo ${_currentIndex + 1}'
        : 'Capítulo ${_currentIndex + 1}';

    final themeColors = _getThemeColors(settings.theme);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: themeColors['header'],
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$chapterName ($progress%)',
                  style: TextStyle(
                    color: themeColors['background'],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_currentIndex + 1}/$totalChapters',
                  style: TextStyle(
                    color: themeColors['background'],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTapUp: (details) {
                final width = MediaQuery.of(context).size.width - 32;
                final tapPosition = details.localPosition.dx;
                final percentage = tapPosition / width;
                final targetPage = (percentage * totalChapters).round().clamp(0, totalChapters - 1);
                _pageController.jumpToPage(targetPage);
              },
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width - 32;
                final position = (details.localPosition.dx / width).clamp(0.0, 1.0);
                final targetPage = (position * (totalChapters - 1)).round();
                setState(() {
                  _currentIndex = targetPage.clamp(0, totalChapters - 1);
                });
              },
              onHorizontalDragEnd: (details) {
                _pageController.jumpToPage(_currentIndex);
              },
              child: Container(
                height: 30,
                color: Colors.transparent,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / totalChapters,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(themeColors['background']!),
                      minHeight: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
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

  void _showTocDialog(BuildContext context, ReaderState state) {
    if (state is! ReaderLoaded) return;

    final toc = state.manifest.toc;
    if (toc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay índice disponible')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Índice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: toc.length,
                itemBuilder: (context, index) {
                  final item = toc[index];
                  return ListTile(
                    title: Text(
                      item.titulo,
                      style: TextStyle(
                        fontWeight: index == _currentIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index == _currentIndex
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                    trailing: index == _currentIndex
                        ? Icon(
                            Icons.bookmark,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      final chapterIndex = _chapters.indexWhere(
                        (c) => c.href == item.href,
                      );
                      if (chapterIndex >= 0) {
                        _pageController.jumpToPage(chapterIndex);
                        setState(() {
                          _currentIndex = chapterIndex;
                        });
                        _readerCubit.irACapitulo(chapterIndex);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
