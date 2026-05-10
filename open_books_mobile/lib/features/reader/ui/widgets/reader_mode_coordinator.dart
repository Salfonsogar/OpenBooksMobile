import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/reader_mode.dart';
import '../../logic/cubit/audio_player_cubit.dart';
import '../../logic/cubit/reader_cubit.dart';
import '../../logic/epub_parser.dart';

class ReaderModeCoordinator {
  ReaderMode? _previousMode;
  final EpubParser parser;

  ReaderModeCoordinator({required this.parser});

  void handleTransition(
    BuildContext context,
    ReaderState state,
  ) {
    if (state is! ReaderLoaded) return;

    final currentMode = state.mode;
    if (_previousMode == currentMode) return;

    if (_previousMode == ReaderMode.audio && currentMode == ReaderMode.reading) {
      context.read<AudioPlayerCubit>().stop();
    }

    if (_previousMode == ReaderMode.reading && currentMode == ReaderMode.audio) {
      final content = state.currentContent;
      final paragraphs = parser.extractParagraphs(content);
      if (context.mounted) {
        context.read<AudioPlayerCubit>().loadParagraphs(paragraphs);
      }
    }

    _previousMode = currentMode;
  }
}