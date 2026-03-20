import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/models/reader_settings.dart';
import '../../data/repositories/epub_repository.dart';
import '../../logic/cubit/bookmark_cubit.dart';
import '../../logic/cubit/bookmark_state.dart';
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
  late final BookmarkCubit _bookmarkCubit;
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
    _bookmarkCubit = getIt<BookmarkCubit>();
    _settingsCubit.cargarSettings();
    _readerCubit.cargarLibro();
    _bookmarkCubit.cargarBookmarks(widget.libroId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _readerCubit.close();
    _bookmarkCubit.close();
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
          BlocProvider.value(value: _bookmarkCubit),
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
          'header': const Color(0xFFF4ECD8),
          'icon': const Color(0xFF5B4636),
          'accent': const Color(0xFF8B4513),
        };
      case 'dark':
        return {
          'background': Colors.grey[900]!,
          'text': Colors.grey[300]!,
          'header': Colors.black,
          'icon': Colors.white,
          'accent': Colors.white,
        };
      default:
        return {
          'background': Colors.white,
          'text': Colors.black87,
          'header': Colors.white,
          'icon': Colors.black87,
          'accent': const Color(0xFF2196F3),
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
          top: MediaQuery.of(context).padding.top + 4,
          left: 12,
          right: 12,
          bottom: 12,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: themeColors['icon'], size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  color: themeColors['icon'],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: themeColors['icon'], size: 28),
              onPressed: () => _showSearchDialog(context, state, settings),
            ),
            IconButton(
              icon: Icon(Icons.list, color: themeColors['icon'], size: 28),
              onPressed: () => _showTocDialog(context, state, settings),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: themeColors['icon'], size: 28),
              onPressed: () => _showSettingsSheet(context),
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
          bottom: MediaQuery.of(context).padding.bottom + 12,
          left: 16,
          right: 16,
          top: 12,
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
                    color: themeColors['icon'],
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_currentIndex + 1}/$totalChapters',
                  style: TextStyle(
                    color: themeColors['icon'],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                height: 40,
                color: Colors.transparent,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / totalChapters,
                      backgroundColor: themeColors['text']!.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColors['text']!),
                      minHeight: 12,
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

  void _showTocDialog(BuildContext context, ReaderState state, ReaderSettings settings) {
    if (state is! ReaderLoaded) return;

    final toc = state.manifest.toc;
    if (toc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay índice disponible')),
      );
      return;
    }

    final themeColors = _getThemeColors(settings.theme);
    final bookTitle = state.manifest.titulo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: _bookmarkCubit,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: themeColors['background'],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        bookTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColors['text'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: themeColors['icon']),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<BookmarkCubit, BookmarkState>(
                  builder: (context, bookmarkState) {
                    final bookmarks = bookmarkState is BookmarkLoaded
                        ? bookmarkState.bookmarks
                        : <Bookmark>[];

                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: themeColors['accent'],
                            unselectedLabelColor: themeColors['text'],
                            indicatorColor: themeColors['accent'],
                            dividerColor: themeColors['text']!.withValues(alpha: 0.2),
                            tabs: [
                              Tab(text: 'Índice (${toc.length})'),
                              Tab(text: 'Marcadores (${bookmarks.length})'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTocList(toc, themeColors),
                                _buildBookmarksList(bookmarks, toc, themeColors),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTocList(List<TocItem> toc, Map<String, Color> themeColors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ? themeColors['accent']
                  : themeColors['text'],
            ),
          ),
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
    );
  }

  Widget _buildBookmarksList(List<Bookmark> bookmarks, List<TocItem> toc, Map<String, Color> themeColors) {
    return Column(
      children: [
        InkWell(
          onTap: () => _crearMarcador(toc, themeColors),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: themeColors['text']!.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: themeColors['accent']),
                const SizedBox(width: 12),
                Text(
                  'Agregar marcador en capítulo actual',
                  style: TextStyle(
                    color: themeColors['accent'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: themeColors['text']!.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay marcadores',
                        style: TextStyle(
                          color: themeColors['text']!.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    return ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        color: themeColors['accent'],
                      ),
                      title: Text(
                        bookmark.title,
                        style: TextStyle(
                          fontWeight: bookmark.chapterIndex == _currentIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: themeColors['text'],
                        ),
                      ),
                      subtitle: Text(
                        'Capítulo ${bookmark.chapterIndex + 1}',
                        style: TextStyle(
                          color: themeColors['text']!.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: themeColors['text'],
                        ),
                        color: themeColors['background'],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editarMarcador(bookmark, themeColors);
                          } else if (value == 'delete') {
                            _eliminarMarcador(bookmark, themeColors);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: themeColors['text']),
                                const SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: themeColors['text'])),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: themeColors['text']),
                                const SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: themeColors['text'])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pageController.jumpToPage(bookmark.chapterIndex);
                        setState(() {
                          _currentIndex = bookmark.chapterIndex;
                        });
                        _readerCubit.irACapitulo(bookmark.chapterIndex);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _crearMarcador(List<TocItem> toc, Map<String, Color> themeColors) {
    final currentTocItem = toc.isNotEmpty && _currentIndex < toc.length
        ? toc[_currentIndex]
        : null;

    final defaultTitle = currentTocItem?.titulo ?? 'Capítulo ${_currentIndex + 1}';
    final controller = TextEditingController(text: defaultTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeColors['background'],
        title: Text(
          'Agregar marcador',
          style: TextStyle(color: themeColors['text']),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: themeColors['text']),
          cursorColor: themeColors['text'],
          decoration: InputDecoration(
            labelText: 'Nombre del marcador',
            labelStyle: TextStyle(color: themeColors['text']!.withValues(alpha: 0.7)),
            filled: true,
            fillColor: themeColors['text']!.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['text']!.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['accent']!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['text']!.withValues(alpha: 0.3)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar', style: TextStyle(color: themeColors['text'])),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                _bookmarkCubit.crearBookmark(
                  bookId: widget.libroId,
                  chapterIndex: _currentIndex,
                  title: title,
                );
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marcador "$title" agregado'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _editarMarcador(Bookmark bookmark, Map<String, Color> themeColors) {
    final controller = TextEditingController(text: bookmark.title);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeColors['background'],
        title: Text(
          'Editar marcador',
          style: TextStyle(color: themeColors['text']),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: themeColors['text']),
          cursorColor: themeColors['text'],
          decoration: InputDecoration(
            labelText: 'Nombre del marcador',
            labelStyle: TextStyle(color: themeColors['text']!.withValues(alpha: 0.7)),
            filled: true,
            fillColor: themeColors['text']!.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['text']!.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['accent']!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColors['text']!.withValues(alpha: 0.3)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar', style: TextStyle(color: themeColors['text'])),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                _bookmarkCubit.actualizarBookmark(
                  id: bookmark.id!,
                  bookId: widget.libroId,
                  chapterIndex: bookmark.chapterIndex,
                  title: title,
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marcador actualizado a "$title"'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarMarcador(Bookmark bookmark, Map<String, Color> themeColors) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeColors['background'],
        title: Text(
          'Eliminar marcador',
          style: TextStyle(color: themeColors['text']),
        ),
        content: Text(
          '¿Eliminar el marcador "${bookmark.title}"?',
          style: TextStyle(color: themeColors['text']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar', style: TextStyle(color: themeColors['text'])),
          ),
          FilledButton(
            onPressed: () {
              _bookmarkCubit.eliminarBookmark(bookmark.id!, widget.libroId);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marcador "${bookmark.title}" eliminado'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, ReaderState state, ReaderSettings settings) {
    if (state is! ReaderLoaded) return;

    final themeColors = _getThemeColors(settings.theme);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: themeColors['background'],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: themeColors['text']!.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                style: TextStyle(color: themeColors['text']),
                decoration: InputDecoration(
                  hintText: 'Buscar en el libro...',
                  hintStyle: TextStyle(color: themeColors['text']!.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: themeColors['icon']),
                  filled: true,
                  fillColor: themeColors['text']!.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (query) {
                  // TODO: Implement search logic
                },
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Escribe para buscar en el contenido',
                  style: TextStyle(color: themeColors['text']!.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
