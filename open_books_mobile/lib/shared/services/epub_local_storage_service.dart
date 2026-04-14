import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'local_database.dart';
import 'network_info.dart';
import 'models/epub_download_model.dart';
import '../../features/reader/data/datasources/epub_datasource.dart';

class EpubLocalStorageService {
  final LocalDatabase localDatabase;
  final EpubDataSource epubDataSource;
  final NetworkInfo networkInfo;

  static const int _maxConcurrentDownloads = 5;
  final List<int> _downloadQueue = [];
  bool _isProcessing = false;

  EpubLocalStorageService({
    required this.localDatabase,
    required this.epubDataSource,
    required this.networkInfo,
  });

  Future<String> get _epubBasePath async {
    final directory = await getApplicationDocumentsDirectory();
    final epubDir = Directory(path.join(directory.path, 'epub'));
    if (!await epubDir.exists()) {
      await epubDir.create(recursive: true);
    }
    return epubDir.path;
  }

  Future<String> _getBookPath(int libroId) async {
    final basePath = await _epubBasePath;
    final bookDir = Directory(path.join(basePath, libroId.toString()));
    if (!await bookDir.exists()) {
      await bookDir.create(recursive: true);
    }
    return bookDir.path;
  }

  Future<bool> isDownloaded(int libroId) async {
    return localDatabase.epubDownloadsDataSource.isDownloaded(libroId);
  }

  Future<Set<int>> getAllDownloadedIds() async {
    return localDatabase.epubDownloadsDataSource.getAllDownloadedIds();
  }

  Future<void> queueDownload(int libroId) async {
    if (_downloadQueue.contains(libroId)) return;

    final isAlreadyDownloaded = await isDownloaded(libroId);
    if (isAlreadyDownloaded) return;

    _downloadQueue.add(libroId);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _downloadQueue.isEmpty) return;

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    _isProcessing = true;

    while (_downloadQueue.isNotEmpty) {
      final batch = _downloadQueue.take(_maxConcurrentDownloads).toList();

      await Future.wait(
        batch.map((libroId) => _downloadSingleEpub(libroId)),
        eagerError: false,
      );

      _downloadQueue.removeWhere((id) => batch.contains(id));
    }

    _isProcessing = false;
  }

  Future<void> _downloadSingleEpub(int libroId) async {
    try {
      await localDatabase.epubDownloadsDataSource.insert(
        EpubDownloadModel(
          libroId: libroId,
          downloadPath: await _getBookPath(libroId),
          downloadedAt: DateTime.now().millisecondsSinceEpoch,
          status: EpubDownloadModel.statusDownloading,
          totalSize: 0,
        ),
      );

      final manifest = await epubDataSource.getManifest(libroId);
      final bookPath = await _getBookPath(libroId);

      int totalSize = 0;

      if (manifest.readingOrder.isNotEmpty) {
        for (final resource in manifest.readingOrder) {
          try {
            final content = await epubDataSource.getResource(libroId, resource.href);
            final resourcePath = path.join(bookPath, 'content', resource.href);
            final resourceDir = Directory(path.dirname(resourcePath));
            if (!await resourceDir.exists()) {
              await resourceDir.create(recursive: true);
            }
            await File(resourcePath).writeAsString(content);
            totalSize += content.length;
          } catch (_) {}
        }
      }

      final manifestJson = jsonEncode(manifest.toJson());
      final download = await localDatabase.epubDownloadsDataSource.getByLibroId(libroId);
      if (download != null) {
        await localDatabase.epubDownloadsDataSource.update(
          download.copyWith(
            manifestJson: manifestJson,
            totalSize: totalSize,
            downloadedAt: DateTime.now().millisecondsSinceEpoch,
            status: EpubDownloadModel.statusCompleted,
          ),
        );
      }
    } catch (e) {
      final download = await localDatabase.epubDownloadsDataSource.getByLibroId(libroId);
      if (download != null) {
        await localDatabase.epubDownloadsDataSource.updateStatus(
          libroId,
          EpubDownloadModel.statusFailed,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> deleteEpub(int libroId) async {
    final bookPath = await _getBookPath(libroId);
    final bookDir = Directory(bookPath);
    if (await bookDir.exists()) {
      await bookDir.delete(recursive: true);
    }
    await localDatabase.epubDownloadsDataSource.deleteByLibroId(libroId);
  }

  Future<String?> getResourcePath(int libroId, String resourcePath) async {
    final isDownloaded = await this.isDownloaded(libroId);
    if (!isDownloaded) return null;

    final bookPath = await _getBookPath(libroId);
    final resolvedPath = _resolveRelativePath(resourcePath, bookPath);
    final file = File(resolvedPath);

    if (await file.exists()) {
      return resolvedPath;
    }
    return null;
  }

  String _resolveRelativePath(String relativePath, String basePath) {
    var result = relativePath;
    if (result.startsWith('/')) {
      result = result.substring(1);
    }
    if (result.startsWith('../')) {
      result = result.substring(3);
      basePath = path.dirname(basePath);
    }
    return path.join(basePath, result);
  }

  Future<Map<String, dynamic>?> getManifest(int libroId) async {
    final download = await localDatabase.epubDownloadsDataSource.getByLibroId(libroId);
    if (download == null || download.status != EpubDownloadModel.statusCompleted) {
      return null;
    }
    if (download.manifestJson == null) return null;
    return jsonDecode(download.manifestJson!) as Map<String, dynamic>;
  }

  Future<String?> getChapterContent(int libroId, String chapterPath) async {
    final resourcePath = await getResourcePath(libroId, chapterPath);
    if (resourcePath == null) return null;

    final file = File(resourcePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  Future<int> getDownloadSize(int libroId) async {
    final download = await localDatabase.epubDownloadsDataSource.getByLibroId(libroId);
    if (download == null) return 0;
    return download.totalSize;
  }

  bool isDownloading(int libroId) {
    return _downloadQueue.contains(libroId);
  }

  Future<void> cancelDownload(int libroId) async {
    _downloadQueue.remove(libroId);
  }
}
