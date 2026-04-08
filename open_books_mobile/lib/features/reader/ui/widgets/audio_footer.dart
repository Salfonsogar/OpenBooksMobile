import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../data/models/audio_player_state.dart';

class AudioFooter extends StatelessWidget {
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  
  const AudioFooter({super.key, this.onPreviousChapter, this.onNextChapter});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => prev.status != curr.status || prev.speed != curr.speed || 
                                 prev.currentParagraphIndex != curr.currentParagraphIndex ||
                                 prev.totalParagraphs != curr.totalParagraphs,
      builder: (context, state) {
        final isPlaying = state.status == AudioStatus.playing;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SpeedSelector(currentSpeed: state.speed),
                const SizedBox(height: 12),
                _ProgressIndicator(
                  current: state.currentParagraphIndex,
                  total: state.totalParagraphs,
                ),
                const SizedBox(height: 12),
                _Controls(
                  isPlaying: isPlaying,
                  onPrevious: () => context.read<AudioPlayerCubit>().previousParagraph(),
                  onPlayPause: () {
                    final cubit = context.read<AudioPlayerCubit>();
                    isPlaying ? cubit.pause() : cubit.play();
                  },
                  onNext: () => context.read<AudioPlayerCubit>().nextParagraph(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  
  const _SpeedSelector({required this.currentSpeed});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
        final isSelected = currentSpeed == speed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            onPressed: () => context.read<AudioPlayerCubit>().setSpeed(speed),
            child: Text(
              '${speed}x',
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  
  const _ProgressIndicator({required this.current, required this.total});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: total > 0 ? (current + 1) / total : 0,
        ),
        const SizedBox(height: 4),
        Text(
          '${current + 1} / $total',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  
  const _Controls({
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: onPrevious,
          iconSize: 32,
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: onPlayPause,
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: onNext,
          iconSize: 32,
        ),
      ],
    );
  }
}