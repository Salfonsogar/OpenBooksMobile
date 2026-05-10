import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/reader_settings.dart';

void main() {
  group('ReaderSettings', () {
    test('default settings values', () {
      const settings = ReaderSettings();

      expect(settings.fontSize, 16.0);
      expect(settings.lineHeight, 1.6);
      expect(settings.marginMode, 'normal');
      expect(settings.theme, 'light');
      expect(settings.fontFamily, 'sans-serif');
      expect(settings.appTheme, 'light');
    });

    test('defaultSettings static const has default values', () {
      const settings = ReaderSettings.defaultSettings;

      expect(settings.fontSize, 16.0);
      expect(settings.lineHeight, 1.6);
      expect(settings.marginMode, 'normal');
      expect(settings.theme, 'light');
      expect(settings.fontFamily, 'sans-serif');
      expect(settings.appTheme, 'light');
    });

    test('constructor overrides default values', () {
      const settings = ReaderSettings(
        fontSize: 20.0,
        lineHeight: 2.0,
        marginMode: 'wide',
        theme: 'sepia',
        fontFamily: 'serif',
        appTheme: 'dark',
      );

      expect(settings.fontSize, 20.0);
      expect(settings.lineHeight, 2.0);
      expect(settings.marginMode, 'wide');
      expect(settings.theme, 'sepia');
      expect(settings.fontFamily, 'serif');
      expect(settings.appTheme, 'dark');
    });

    test('copyWith creates new instance with changed values', () {
      const original = ReaderSettings();

      final copied = original.copyWith(fontSize: 18.0, lineHeight: 1.8);

      expect(copied.fontSize, 18.0);
      expect(copied.lineHeight, 1.8);
      expect(copied.marginMode, 'normal');
      expect(copied.theme, 'light');
      expect(copied.fontFamily, 'sans-serif');
      expect(copied.appTheme, 'light');
    });

    test('copyWith with no arguments returns instance with same values', () {
      const original = ReaderSettings(fontSize: 20.0, marginMode: 'wide');
      final copied = original.copyWith();

      expect(copied.fontSize, 20.0);
      expect(copied.marginMode, 'wide');
    });

    test('copyWith can change all fields', () {
      const original = ReaderSettings();
      final copied = original.copyWith(
        fontSize: 22.0,
        lineHeight: 2.2,
        marginMode: 'narrow',
        theme: 'dark',
        fontFamily: 'monospace',
        appTheme: 'dark',
      );

      expect(copied.fontSize, 22.0);
      expect(copied.lineHeight, 2.2);
      expect(copied.marginMode, 'narrow');
      expect(copied.theme, 'dark');
      expect(copied.fontFamily, 'monospace');
      expect(copied.appTheme, 'dark');
    });

    group('marginHorizontal', () {
      test('returns 16.0 for normal margin mode', () {
        const settings = ReaderSettings(marginMode: 'normal');
        expect(settings.marginHorizontal, 16.0);
      });

      test('returns 8.0 for narrow margin mode', () {
        const settings = ReaderSettings(marginMode: 'narrow');
        expect(settings.marginHorizontal, 8.0);
      });

      test('returns 32.0 for wide margin mode', () {
        const settings = ReaderSettings(marginMode: 'wide');
        expect(settings.marginHorizontal, 32.0);
      });

      test('returns 16.0 for unknown margin mode', () {
        const settings = ReaderSettings(marginMode: 'unknown');
        expect(settings.marginHorizontal, 16.0);
      });
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        const settings = ReaderSettings(
          fontSize: 18.0,
          lineHeight: 2.0,
          marginMode: 'wide',
          theme: 'sepia',
          fontFamily: 'serif',
          appTheme: 'dark',
        );

        final json = settings.toJson();

        expect(json['fontSize'], 18.0);
        expect(json['lineHeight'], 2.0);
        expect(json['marginMode'], 'wide');
        expect(json['theme'], 'sepia');
        expect(json['fontFamily'], 'serif');
        expect(json['appTheme'], 'dark');
      });

      test('fromJson creates ReaderSettings from JSON map', () {
        final json = {
          'fontSize': 18.0,
          'lineHeight': 2.0,
          'marginMode': 'wide',
          'theme': 'sepia',
          'fontFamily': 'serif',
          'appTheme': 'dark',
        };

        final settings = ReaderSettings.fromJson(json);

        expect(settings.fontSize, 18.0);
        expect(settings.lineHeight, 2.0);
        expect(settings.marginMode, 'wide');
        expect(settings.theme, 'sepia');
        expect(settings.fontFamily, 'serif');
        expect(settings.appTheme, 'dark');
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final settings = ReaderSettings.fromJson(json);

        expect(settings.fontSize, 16.0);
        expect(settings.lineHeight, 1.6);
        expect(settings.marginMode, 'normal');
        expect(settings.theme, 'light');
        expect(settings.fontFamily, 'sans-serif');
        expect(settings.appTheme, 'light');
      });

      test('fromJson handles null values with defaults', () {
        final json = {
          'fontSize': null,
          'lineHeight': null,
          'marginMode': null,
          'theme': null,
          'fontFamily': null,
          'appTheme': null,
        };

        final settings = ReaderSettings.fromJson(json);

        expect(settings.fontSize, 16.0);
        expect(settings.lineHeight, 1.6);
        expect(settings.marginMode, 'normal');
        expect(settings.theme, 'light');
        expect(settings.fontFamily, 'sans-serif');
        expect(settings.appTheme, 'light');
      });

      test('fromJson handles int values for fontSize and lineHeight', () {
        final json = {
          'fontSize': 18,
          'lineHeight': 2,
          'marginMode': 'narrow',
          'theme': 'dark',
          'fontFamily': 'monospace',
          'appTheme': 'dark',
        };

        final settings = ReaderSettings.fromJson(json);

        expect(settings.fontSize, 18.0);
        expect(settings.lineHeight, 2.0);
      });

      test('toJson and fromJson roundtrip', () {
        const original = ReaderSettings(
          fontSize: 20.0,
          lineHeight: 1.8,
          marginMode: 'narrow',
          theme: 'dark',
          fontFamily: 'serif',
          appTheme: 'dark',
        );

        final json = original.toJson();
        final restored = ReaderSettings.fromJson(json);

        expect(restored.fontSize, original.fontSize);
        expect(restored.lineHeight, original.lineHeight);
        expect(restored.marginMode, original.marginMode);
        expect(restored.theme, original.theme);
        expect(restored.fontFamily, original.fontFamily);
        expect(restored.appTheme, original.appTheme);
      });
    });

    group('Equatable', () {
      test('supports value equality', () {
        const a = ReaderSettings(fontSize: 18.0, marginMode: 'wide');
        const b = ReaderSettings(fontSize: 18.0, marginMode: 'wide');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('inequality when fields differ', () {
        const a = ReaderSettings(fontSize: 18.0);
        const b = ReaderSettings(fontSize: 20.0);

        expect(a, isNot(equals(b)));
      });

      test('props returns correct list', () {
        const settings = ReaderSettings(
          fontSize: 16.0,
          lineHeight: 1.6,
          marginMode: 'normal',
          theme: 'light',
          fontFamily: 'sans-serif',
          appTheme: 'light',
        );

        expect(settings.props, [16.0, 1.6, 'normal', 'light', 'sans-serif', 'light']);
      });
    });
  });
}
