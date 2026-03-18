import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../data/models/epub_manifest.dart';
import '../../data/repositories/epub_repository.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../widgets/epub_parser.dart';

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
  List<ReadingOrderItem> _chapters = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _readerCubit = ReaderCubit(
      getIt<EpubRepository>(),
      widget.libroId,
    );
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
      child: BlocProvider.value(
        value: _readerCubit,
        child: BlocConsumer<ReaderCubit, ReaderState>(
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
            return Scaffold(
              backgroundColor: Colors.white,
              body: GestureDetector(
                onTap: () {
                  setState(() {
                    _showUi = !_showUi;
                  });
                },
                child: Stack(
                  children: [
                    _buildContent(state),
                    if (_showUi) _buildHeader(state),
                    if (_showUi) _buildFooter(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ReaderState state) {
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
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 56 + 16,
                      bottom: MediaQuery.of(context).padding.bottom + 100 + 16,
                    ),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: ChapterContent(
                        blocks: blocks,
                        libroId: widget.libroId,
                        chapterPath: chapterPath,
                        fontSize: 16,
                        lineHeight: 1.6,
                        horizontalMargin: 0,
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

  Widget _buildHeader(ReaderState state) {
    String titulo = 'Cargando...';
    if (state is ReaderLoaded) {
      titulo = state.manifest.titulo;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white),
              onPressed: () => _showTocDialog(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ReaderState state) {
    if (_chapters.isEmpty) {
      return const SizedBox();
    }

    final totalChapters = _chapters.length;
    final chapterName = _currentIndex < totalChapters
        ? 'Capítulo ${_currentIndex + 1}'
        : 'Capítulo ${_currentIndex + 1}';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 8,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$chapterName (${_currentIndex + 1}/$totalChapters)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Expanded(
                  child: Slider(
                    value: _currentIndex.toDouble(),
                    min: 0,
                    max: (totalChapters - 1).toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _currentIndex = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      _pageController.jumpToPage(value.toInt());
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _currentIndex < totalChapters - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
