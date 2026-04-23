import '../datasources/epub_datasource.dart';
import '../models/epub_manifest.dart';
import '../../../../shared/services/local_database.dart';
import '../../../../shared/services/network_info.dart';
import 'epub_repository.dart';

class EpubRepositoryImpl implements EpubRepository {
  final EpubDataSource _dataSource;
  final LocalDatabase _localDatabase;
  final NetworkInfo _networkInfo;

  EpubRepositoryImpl({
    required EpubDataSource dataSource,
    required LocalDatabase localDatabase,
    required NetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _localDatabase = localDatabase,
        _networkInfo = networkInfo;

  @override
  Future<EpubManifest> getManifest(int libroId) async {
    final isConnected = await _networkInfo.isConnected;
    if (isConnected) {
      return _dataSource.getManifest(libroId);
    }

    final localManifest =
        await _localDatabase.bookContentLocalDataSource.getManifest(libroId);
    if (localManifest != null) {
      return localManifest;
    }

    throw Exception(
      'Sin conexión y sin manifiesto local disponible para este libro',
    );
  }

  @override
  Future<String> getResource(int libroId, String path) async {
    final isConnected = await _networkInfo.isConnected;
    if (isConnected) {
      return _dataSource.getResource(libroId, path);
    }

    final localResource =
        await _localDatabase.bookContentLocalDataSource.getResource(
      libroId,
      path,
    );
    if (localResource != null) {
      return localResource;
    }

    throw Exception(
      'Sin conexión y sin recurso local disponible: $path',
    );
  }
}