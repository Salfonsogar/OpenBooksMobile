enum DownloadStatus {
  notDownloaded,
  downloading,
  completed,
  failed,
}

extension DownloadStatusX on DownloadStatus {
  String get value {
    switch (this) {
      case DownloadStatus.notDownloaded:
        return 'not_downloaded';
      case DownloadStatus.downloading:
        return 'downloading';
      case DownloadStatus.completed:
        return 'completed';
      case DownloadStatus.failed:
        return 'failed';
    }
  }

  static DownloadStatus fromString(String value) {
    switch (value) {
      case 'not_downloaded':
        return DownloadStatus.notDownloaded;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      default:
        return DownloadStatus.notDownloaded;
    }
  }
}