import 'package:equatable/equatable.dart';

enum AudioStatus { idle, playing, paused, stopped, error }

class AudioPlaybackState extends Equatable {
  final AudioStatus status;
  final int currentParagraphIndex;
  final int totalParagraphs;
  final String? errorMessage;
  final double speed;

  const AudioPlaybackState({
    this.status = AudioStatus.idle,
    this.currentParagraphIndex = 0,
    this.totalParagraphs = 0,
    this.errorMessage,
    this.speed = 1.0,
  });

  @override
  List<Object?> get props => [status, currentParagraphIndex, totalParagraphs, errorMessage, speed];

  AudioPlaybackState copyWith({
    AudioStatus? status,
    int? currentParagraphIndex,
    int? totalParagraphs,
    String? errorMessage,
    double? speed,
  }) {
    return AudioPlaybackState(
      status: status ?? this.status,
      currentParagraphIndex: currentParagraphIndex ?? this.currentParagraphIndex,
      totalParagraphs: totalParagraphs ?? this.totalParagraphs,
      errorMessage: errorMessage,
      speed: speed ?? this.speed,
    );
  }
}