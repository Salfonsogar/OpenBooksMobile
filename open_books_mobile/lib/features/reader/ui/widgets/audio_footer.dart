import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../data/models/audio_player_state.dart';
import 'reader_colors.dart';

class AudioFooter extends StatelessWidget {
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  final double bottomPadding;
  final ReaderColors colors;
  
  const AudioFooter({
    super.key,
    this.onPreviousChapter,
    this.onNextChapter,
    this.bottomPadding = 0,
    required this.colors,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlaybackState>(
      buildWhen: (prev, curr) => prev.status != curr.status || prev.speed != curr.speed || 
                                 prev.currentParagraphIndex != curr.currentParagraphIndex ||
                                 prev.totalParagraphs != curr.totalParagraphs,
      builder: (context, state) {
        final isPlaying = state.status == AudioStatus.playing;
        
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              bottom: bottomPadding + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [BoxShadow(color: colors.text.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SpeedSelector(currentSpeed: state.speed, colors: colors),
                  const SizedBox(height: 12),
                  _ProgressIndicator(
                    current: state.currentParagraphIndex,
                    total: state.totalParagraphs,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: colors.icon),
                        onPressed: onPreviousChapter,
                        iconSize: 32,
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: colors.icon),
                        onPressed: () => context.read<AudioPlayerCubit>().previousParagraph(),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.background,
                        onPressed: () {
                          final cubit = context.read<AudioPlayerCubit>();
                          isPlaying ? cubit.pause() : cubit.play();
                        },
                        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.skip_next, color: colors.icon),
                        onPressed: () => context.read<AudioPlayerCubit>().nextParagraph(),
                        iconSize: 32,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: colors.icon),
                        onPressed: onNextChapter,
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ReaderColors colors;
  
  const _SpeedSelector({required this.currentSpeed, required this.colors});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [0.5, 0.75, 1.0, 1.5, 2.0].map((speed) {
        final isSelected = currentSpeed == speed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            onPressed: () => context.read<AudioPlayerCubit>().setSpeed(speed),
            child: Text(
              '${speed}x',
              style: TextStyle(
                color: isSelected ? colors.accent : colors.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  final ReaderColors colors;
  
  const _ProgressIndicator({required this.current, required this.total, required this.colors});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: total > 0 ? (current + 1) / total : 0,
          backgroundColor: colors.text.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(colors.accent),
        ),
        const SizedBox(height: 4),
        Text(
          '${current + 1} / $total',
          style: TextStyle(color: colors.text),
        ),
      ],
    );
  }
}
