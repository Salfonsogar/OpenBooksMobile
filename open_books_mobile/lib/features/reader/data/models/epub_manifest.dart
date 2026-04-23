class TocItem {
  final String titulo;
  final String href;

  const TocItem({
    required this.titulo,
    required this.href,
  });

  factory TocItem.fromJson(Map<String, dynamic> json) {
    return TocItem(
      titulo: json['titulo'] as String? ?? json['title'] as String? ?? json['label'] as String? ?? '',
      href: json['href'] as String? ?? json['src'] as String? ?? json['path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'href': href,
    };
  }
}

class ReadingOrderItem {
  final String href;
  final String type;

  const ReadingOrderItem({
    required this.href,
    required this.type,
  });

  factory ReadingOrderItem.fromJson(Map<String, dynamic> json) {
    return ReadingOrderItem(
      href: json['href'] as String? ?? json['src'] as String? ?? json['path'] as String? ?? '',
      type: json['type'] as String? ?? json['contentType'] as String? ?? '',
    );
  }
}

class EpubManifest {
  final int id;
  final String titulo;
  final String autor;
  final List<ReadingOrderItem> readingOrder;
  final List<TocItem> toc;
  final int? version;

  const EpubManifest({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.readingOrder,
    required this.toc,
    this.version,
  });

  factory EpubManifest.fromJson(Map<String, dynamic> json) {
    final readingOrderList = json['readingOrder'] as List<dynamic>? ?? 
                         json['chapters'] as List<dynamic>? ?? 
                         json['pages'] as List<dynamic>? ?? 
                         [];
    final tocList = json['toc'] as List<dynamic>? ?? 
                  json['tableOfContents'] as List<dynamic>? ?? 
                  json['tableOfContent'] as List<dynamic>? ?? 
                  [];
    
    return EpubManifest(
      id: json['id'] as int? ?? json['libroId'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? json['title'] as String? ?? '',
      autor: json['autor'] as String? ?? json['author'] as String? ?? '',
      readingOrder: readingOrderList
              .map((e) => ReadingOrderItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      toc: tocList
          .map((e) => TocItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      version: json['version'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'readingOrder': readingOrder.map((e) => {'href': e.href, 'type': e.type}).toList(),
      'toc': toc.map((e) => e.toJson()).toList(),
      'version': version,
    };
  }
}