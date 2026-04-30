import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import '../../logic/cubit/audio_player_cubit.dart';
import '../../data/models/audio_player_state.dart';
import '../widgets/epub_parser.dart';
import '../widgets/reader_blocks.dart';

class ListeningView extends StatefulWidget {
  final List<String> paragraphs;
  final String content;
  final int currentParagraphIndex;
  final int libroId;
  final String? chapterPath;
  final Function(int)? onParagraphChanged;
  
  const ListeningView({
    super.key, 
    required this.paragraphs,
    required this.content,
    required this.currentParagraphIndex,
    required this.libroId,
    this.chapterPath,
    this.onParagraphChanged,
  });
  
  @override
  State<ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<ListeningView> {
  StreamSubscription? _subscription;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    _subscription = context.read<AudioPlayerCubit>().stream.listen((state) {
      if (state.status == AudioStatus.playing) {
        _scrollToParagraph(state.currentParagraphIndex);
      }
    });
  }
  
  void _scrollToParagraph(int index) {
    if (_scrollController.hasClients) {
      final position = index * 200.0;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final parser = EpubParser();
    final blocks = parser.parse(widget.content);

    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => 
        prev.currentParagraphIndex != curr.currentParagraphIndex ||
        prev.status != curr.status,
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 60,
            bottom: MediaQuery.of(context).padding.bottom + 150,
            left: 16,
            right: 16,
          ),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            
            if (block.type == 'image') {
              final imageSrc = _getImageSrc(block);
              if (imageSrc == null) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.network(
                  imageSrc,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              );
            }
            
            final textIndex = _getTextIndex(blocks, index);
            final isCurrent = textIndex == state.currentParagraphIndex && 
                              state.status == AudioStatus.playing;
            final text = block.content?.toString() ?? '';
            
            if (text.trim().isEmpty) return const SizedBox();
            
            return _ParagraphWidget(
              text: text,
              isCurrent: isCurrent,
            );
          },
        );
      },
    );
  }

  int _getTextIndex(List<ReaderBlock> blocks, int blockIndex) {
    int textIndex = 0;
        for (int i = 0; i < blockIndex; i++) {
      if (blocks[i].type == 'text') {
        textIndex++;
      }
    }
    return textIndex;
  }

  String? _getImageSrc(ReaderBlock block) {
    if (block.type == 'image') {
      final relativePath = block.attributes?['src'];
      if (relativePath == null) return null;
      
      final imagePath = _resolveImagePath(relativePath);
      return 'http://10.0.2.2:5201/api/Libros/${widget.libroId}/epub/resource?path=${Uri.encodeComponent(imagePath)}';
    }
    return null;
  }

  String _resolveImagePath(String imagePath) {
    if (widget.chapterPath == null) return imagePath;
    
    if (imagePath.startsWith('../')) {
      final baseDir = p.dirname(widget.chapterPath!);
      return p.normalize(p.join(baseDir, imagePath));
    }
    return imagePath;
  }
}

class _ParagraphWidget extends StatelessWidget {
  final String text;
  final bool isCurrent;
  
  const _ParagraphWidget({required this.text, required this.isCurrent});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}