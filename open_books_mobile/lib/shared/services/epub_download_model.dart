class EpubDownloadModel {
  final int? id;
  final int libroId;
  final String downloadPath;
  final String? manifestJson;
  final int totalSize;
  final int downloadedAt;
  final String status;
  final String? errorMessage;

  EpubDownloadModel({
    this.id,
    required this.libroId,
    required this.downloadPath,
    this.manifestJson,
    required this.totalSize,
    required this.downloadedAt,
    this.status = 'pending',
    this.errorMessage,
  });

  factory EpubDownloadModel.fromMap(Map<String, dynamic> map) {
    return EpubDownloadModel(
      id: map['id'] as int?,
      libroId: map['libro_id'] as int,
      downloadPath: map['download_path'] as String,
      manifestJson: map['manifest_json'] as String?,
      totalSize: map['total_size'] as int? ?? 0,
      downloadedAt: map['downloaded_at'] as int,
      status: map['status'] as String? ?? 'pending',
      errorMessage: map['error_message'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'libro_id': libroId,
      'download_path': downloadPath,
      'manifest_json': manifestJson,
      'total_size': totalSize,
      'downloaded_at': downloadedAt,
      'status': status,
      'error_message': errorMessage,
    };
  }

  EpubDownloadModel copyWith({
    int? id,
    int? libroId,
    String? downloadPath,
    String? manifestJson,
    int? totalSize,
    int? downloadedAt,
    String? status,
    String? errorMessage,
  }) {
    return EpubDownloadModel(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      downloadPath: downloadPath ?? this.downloadPath,
      manifestJson: manifestJson ?? this.manifestJson,
      totalSize: totalSize ?? this.totalSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static const String statusPending = 'pending';
  static const String statusDownloading = 'downloading';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
}
