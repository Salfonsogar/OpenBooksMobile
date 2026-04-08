import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../data/models/audio_player_state.dart';

class ListeningView extends StatefulWidget {
  final List<String> paragraphs;
  final Function(int)? onParagraphChanged;
  
  const ListeningView({
    super.key, 
    required this.paragraphs,
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
    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => 
        prev.currentParagraphIndex != curr.currentParagraphIndex ||
        prev.status != curr.status,
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: widget.paragraphs.length,
          itemBuilder: (context, index) {
            final isCurrent = index == state.currentParagraphIndex;
            return _ParagraphWidget(
              text: widget.paragraphs[index],
              isCurrent: isCurrent && state.status == AudioStatus.playing,
            );
          },
        );
      },
    );
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