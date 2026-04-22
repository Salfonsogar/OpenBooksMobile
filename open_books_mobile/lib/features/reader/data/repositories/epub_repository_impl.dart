import '../datasources/epub_datasource.dart';
import '../models/epub_manifest.dart';
import 'epub_repository.dart';
import '../../../../shared/core/exceptions/offline_reading_exception.dart';
import '../../../../shared/services/network_info.dart';
import '../../../../shared/services/datasources/book_content_local_datasource.dart';

class EpubRepositoryImpl implements EpubRepository {
  final EpubDataSource _remoteDataSource;
  final BookContentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  EpubRepositoryImpl({
    required EpubDataSource remoteDataSource,
    required BookContentLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<EpubManifest> getManifest(int libroId) async {
    final localManifest = await _localDataSource.getManifest(libroId);
    if (localManifest != null && localManifest.readingOrder.isNotEmpty) {
      print('[DEBUG EpubRepository] getManifest $libroId: desde LOCAL, ${localManifest.readingOrder.length} capítulos');
      return localManifest;
    }

    if (!await _networkInfo.isConnected) {
      throw OfflineReadingException('No hay contenido offline disponible');
    }

    print('[DEBUG EpubRepository] getManifest $libroId: descargando desde REMOTO');
    final manifest = await _remoteDataSource.getManifest(libroId);
    await _localDataSource.saveManifest(libroId, manifest);
    return manifest;
  }

  bool _isValidContent(String? content) {
    if (content == null || content.isEmpty) return false;
    if (content.length < 500) return false;
    return content.contains('<') && content.contains('>');
  }

  @override
  Future<String> getResource(int libroId, String path) async {
    final localResource = await _localDataSource.getResource(libroId, path);
    if (_isValidContent(localResource)) {
      print('[DEBUG EpubRepository] getResource $libroId/$path: desde LOCAL, length=${localResource!.length}');
      return localResource!;
    }

    if (!await _networkInfo.isConnected) {
      if (localResource != null && localResource.isNotEmpty) {
        print('[DEBUG EpubRepository] getResource $libroId/$path: offline fallback con ${localResource.length} chars');
        return localResource!;
      }
      throw OfflineReadingException('Capítulo no disponible offline');
    }

    print('[DEBUG EpubRepository] getResource $libroId/$path: descargando desde REMOTO (local length=${localResource?.length ?? 0}, inválido)');
    final content = await _remoteDataSource.getResource(libroId, path);
    if (_isValidContent(content)) {
      await _localDataSource.saveResource(libroId, path, content);
    }
    return content;
  }
}