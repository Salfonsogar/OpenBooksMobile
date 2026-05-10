import 'reader_colors.dart';

ReaderThemeType parseThemeType(String theme) {
  switch (theme) {
    case 'sepia':
      return ReaderThemeType.sepia;
    case 'dark':
      return ReaderThemeType.dark;
    default:
      return ReaderThemeType.light;
  }
}