import 'package:equatable/equatable.dart';

import '../../data/models/highlight.dart';

abstract class HighlightState extends Equatable {
  const HighlightState();

  @override
  List<Object?> get props => [];
}

class HighlightInitial extends HighlightState {}

class HighlightLoading extends HighlightState {}

class HighlightLoaded extends HighlightState {
  final List<Highlight> highlights;
  final int currentChapter;

  const HighlightLoaded({
    required this.highlights,
    required this.currentChapter,
  });

  @override
  List<Object?> get props => [highlights, currentChapter];
}

class HighlightError extends HighlightState {
  final String message;

  const HighlightError(this.message);

  @override
  List<Object?> get props => [message];
}
