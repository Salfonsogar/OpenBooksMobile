import '../datasources/epub_datasource.dart';
import '../models/epub_manifest.dart';

class EpubRepository {
  final EpubDataSource _dataSource;

  EpubRepository(this._dataSource);

  Future<EpubManifest> getManifest(int libroId) {
    return _dataSource.getManifest(libroId);
  }

  Future<String> getResource(int libroId, String path) {
    return _dataSource.getResource(libroId, path);
  }
}
