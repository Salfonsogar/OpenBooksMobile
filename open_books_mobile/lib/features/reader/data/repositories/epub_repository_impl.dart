import '../datasources/epub_datasource.dart';
import '../models/epub_manifest.dart';
import 'epub_repository.dart';

class EpubRepositoryImpl implements EpubRepository {
  final EpubDataSource _dataSource;

  EpubRepositoryImpl({
    required EpubDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<EpubManifest> getManifest(int libroId) async {
    return await _dataSource.getManifest(libroId);
  }

  @override
  Future<String> getResource(int libroId, String path) async {
    return await _dataSource.getResource(libroId, path);
  }
}