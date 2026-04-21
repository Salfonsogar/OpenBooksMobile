class BookContentModel {
  final int libroId;
  final String manifestJson;
  final DateTime lastSyncedAt;
  final int version;

  BookContentModel({
    required this.libroId,
    required this.manifestJson,
    required this.lastSyncedAt,
    required this.version,
  });

  factory BookContentModel.fromMap(Map<String, dynamic> map) {
    return BookContentModel(
      libroId: map['libro_id'] as int,
      manifestJson: map['manifest_json'] as String,
      lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(
        map['last_synced_at'] as int,
      ),
      version: map['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'libro_id': libroId,
      'manifest_json': manifestJson,
      'last_synced_at': lastSyncedAt.millisecondsSinceEpoch,
      'version': version,
    };
  }
}