import 'package:flutter_test/flutter_test.dart';
import 'package:open_books_mobile/shared/core/enums/download_status.dart';

void main() {
  group('DownloadStatus', () {
    group('value getter', () {
      test('notDownloaded returns "not_downloaded"', () {
        expect(DownloadStatus.notDownloaded.value, equals('not_downloaded'));
      });

      test('downloading returns "downloading"', () {
        expect(DownloadStatus.downloading.value, equals('downloading'));
      });

      test('completed returns "completed"', () {
        expect(DownloadStatus.completed.value, equals('completed'));
      });

      test('failed returns "failed"', () {
        expect(DownloadStatus.failed.value, equals('failed'));
      });
    });

    group('fromString', () {
      test('parses "not_downloaded" to notDownloaded', () {
        expect(DownloadStatusX.fromString('not_downloaded'), equals(DownloadStatus.notDownloaded));
      });

      test('parses "downloading" to downloading', () {
        expect(DownloadStatusX.fromString('downloading'), equals(DownloadStatus.downloading));
      });

      test('parses "completed" to completed', () {
        expect(DownloadStatusX.fromString('completed'), equals(DownloadStatus.completed));
      });

      test('parses "failed" to failed', () {
        expect(DownloadStatusX.fromString('failed'), equals(DownloadStatus.failed));
      });

      test('parses unknown value to notDownloaded (default)', () {
        expect(DownloadStatusX.fromString('unknown'), equals(DownloadStatus.notDownloaded));
      });

      test('parses null-like value to notDownloaded (default)', () {
        expect(DownloadStatusX.fromString(''), equals(DownloadStatus.notDownloaded));
      });
    });
  });
}