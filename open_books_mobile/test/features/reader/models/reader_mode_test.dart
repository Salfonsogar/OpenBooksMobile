import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/features/reader/data/models/reader_mode.dart';

void main() {
  group('ReaderMode', () {
    test('has reading value', () {
      expect(ReaderMode.reading, isA<ReaderMode>());
    });

    test('has audio value', () {
      expect(ReaderMode.audio, isA<ReaderMode>());
    });

    test('has hybrid value', () {
      expect(ReaderMode.hybrid, isA<ReaderMode>());
    });

    test('reading and audio are different', () {
      expect(ReaderMode.reading, isNot(equals(ReaderMode.audio)));
    });

    test('reading and hybrid are different', () {
      expect(ReaderMode.reading, isNot(equals(ReaderMode.hybrid)));
    });

    test('audio and hybrid are different', () {
      expect(ReaderMode.audio, isNot(equals(ReaderMode.hybrid)));
    });

    test('can be compared with ==', () {
      expect(ReaderMode.reading == ReaderMode.reading, isTrue);
      expect(ReaderMode.reading == ReaderMode.audio, isFalse);
    });

    test('values contains all three modes', () {
      expect(ReaderMode.values.length, 3);
      expect(ReaderMode.values, containsAll([ReaderMode.reading, ReaderMode.audio, ReaderMode.hybrid]));
    });
  });
}
