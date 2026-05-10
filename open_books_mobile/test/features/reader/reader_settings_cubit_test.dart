import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_books_mobile/features/reader/data/models/reader_settings.dart';
import 'package:open_books_mobile/features/reader/logic/cubit/reader_settings_cubit.dart';

void main() {
  group('ReaderSettingsCubit', () {
    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'initial state is ReaderSettings.defaultSettings',
      build: () => ReaderSettingsCubit(),
      verify: (cubit) {
        expect(cubit.state, equals(ReaderSettings.defaultSettings));
      },
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarFontSize updates fontSize',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarFontSize(20.0),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.fontSize, 'fontSize', 20.0),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarFontSize with small value',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarFontSize(10.0),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.fontSize, 'fontSize', 10.0),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarFontSize with large value',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarFontSize(32.0),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.fontSize, 'fontSize', 32.0),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarLineHeight updates lineHeight',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarLineHeight(2.0),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.lineHeight, 'lineHeight', 2.0),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarTheme updates theme',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarTheme('dark'),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.theme, 'theme', 'dark'),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarFontFamily updates fontFamily',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarFontFamily('serif'),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.fontFamily, 'fontFamily', 'serif'),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarMarginMode updates marginMode',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarMarginMode('wide'),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.marginMode, 'marginMode', 'wide'),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'actualizarAppTheme updates appTheme',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarAppTheme('dark'),
      expect: () => [
        isA<ReaderSettings>().having((s) => s.appTheme, 'appTheme', 'dark'),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'chaining multiple updates works',
      build: () => ReaderSettingsCubit(),
      act: (cubit) {
        cubit.actualizarFontSize(18.0);
        cubit.actualizarLineHeight(1.8);
        cubit.actualizarTheme('sepia');
      },
      expect: () => [
        isA<ReaderSettings>().having((s) => s.fontSize, 'fontSize', 18.0),
        isA<ReaderSettings>().having((s) => s.lineHeight, 'lineHeight', 1.8),
        isA<ReaderSettings>()
          .having((s) => s.theme, 'theme', 'sepia')
          .having((s) => s.fontSize, 'fontSize', 18.0)
          .having((s) => s.lineHeight, 'lineHeight', 1.8),
      ],
    );

    blocTest<ReaderSettingsCubit, ReaderSettings>(
      'previous values are preserved when updating single field',
      build: () => ReaderSettingsCubit(),
      act: (cubit) => cubit.actualizarFontSize(22.0),
      expect: () => [
        isA<ReaderSettings>()
          .having((s) => s.fontSize, 'fontSize', 22.0)
          .having((s) => s.lineHeight, 'lineHeight', 1.6)
          .having((s) => s.marginMode, 'marginMode', 'normal')
          .having((s) => s.theme, 'theme', 'light')
          .having((s) => s.fontFamily, 'fontFamily', 'sans-serif')
          .having((s) => s.appTheme, 'appTheme', 'light'),
      ],
    );
  });
}
