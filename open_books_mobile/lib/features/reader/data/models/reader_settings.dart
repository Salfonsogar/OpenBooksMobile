import 'package:equatable/equatable.dart';

class ReaderSettings extends Equatable {
  final double fontSize;
  final double lineHeight;
  final String marginMode;
  final String theme;
  final String fontFamily;
  final String appTheme;

  const ReaderSettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.6,
    this.marginMode = 'normal',
    this.theme = 'light',
    this.fontFamily = 'sans-serif',
    this.appTheme = 'light',
  });

  static const defaultSettings = ReaderSettings();

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    String? marginMode,
    String? theme,
    String? fontFamily,
    String? appTheme,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      marginMode: marginMode ?? this.marginMode,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      appTheme: appTheme ?? this.appTheme,
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
      'fontFamily': fontFamily,
      'appTheme': appTheme,
    };
  }

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      marginMode: json['marginMode'] as String? ?? 'normal',
      theme: json['theme'] as String? ?? 'light',
      fontFamily: json['fontFamily'] as String? ?? 'sans-serif',
      appTheme: json['appTheme'] as String? ?? 'light',
    );
  }

  @override
  List<Object?> get props => [fontSize, lineHeight, marginMode, theme, fontFamily, appTheme];
}
