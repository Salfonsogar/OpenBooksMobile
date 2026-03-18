import 'package:equatable/equatable.dart';

class ReaderSettings extends Equatable {
  final double fontSize;
  final double lineHeight;
  final String marginMode;
  final String theme;

  const ReaderSettings({
    this.fontSize = 1.0,
    this.lineHeight = 1.6,
    this.marginMode = 'normal',
    this.theme = 'light',
  });

  static const defaultSettings = ReaderSettings();

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    String? marginMode,
    String? theme,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      marginMode: marginMode ?? this.marginMode,
      theme: theme ?? this.theme,
    );
  }

  double get marginHorizontal {
    switch (marginMode) {
      case 'narrow':
        return 8.0;
      case 'wide':
        return 32.0;
      default:
        return 16.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'marginMode': marginMode,
      'theme': theme,
    };
  }

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 1.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      marginMode: json['marginMode'] as String? ?? 'normal',
      theme: json['theme'] as String? ?? 'light',
    );
  }

  @override
  List<Object?> get props => [fontSize, lineHeight, marginMode, theme];
}
