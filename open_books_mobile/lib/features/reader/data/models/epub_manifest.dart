class TocItem {
  final String titulo;
  final String href;

  const TocItem({
    required this.titulo,
    required this.href,
  });

  factory TocItem.fromJson(Map<String, dynamic> json) {
    return TocItem(
      titulo: json['titulo'] as String? ?? '',
      href: json['href'] as String? ?? '',
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
      href: json['href'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

class EpubManifest {
  final int id;
  final String titulo;
  final String autor;
  final List<ReadingOrderItem> readingOrder;
  final List<TocItem> toc;

  const EpubManifest({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.readingOrder,
    required this.toc,
  });

  factory EpubManifest.fromJson(Map<String, dynamic> json) {
    return EpubManifest(
      id: json['id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? '',
      autor: json['autor'] as String? ?? '',
      readingOrder: (json['readingOrder'] as List<dynamic>?)
              ?.map((e) => ReadingOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      toc: (json['toc'] as List<dynamic>?)
              ?.map((e) => TocItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'readingOrder': readingOrder.map((e) => {'href': e.href, 'type': e.type}).toList(),
      'toc': toc.map((e) => e.toJson()).toList(),
    };
  }
}
