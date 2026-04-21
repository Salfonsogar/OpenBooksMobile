import '../models/epub_manifest.dart';

abstract class EpubRepository {
  Future<EpubManifest> getManifest(int libroId);
  Future<String> getResource(int libroId, String path);
}