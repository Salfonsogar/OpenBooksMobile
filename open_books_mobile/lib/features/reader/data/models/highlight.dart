class Highlight {
  final int? id;
  final int bookId;
  final int chapterIndex;
  final String text;
  final int startIndex;
  final int endIndex;
  final String color;
  final DateTime createdAt;

  const Highlight({
    this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_index': chapterIndex,
      'text': text,
      'start_index': startIndex,
      'end_index': endIndex,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      chapterIndex: map['chapter_index'] as int,
      text: map['text'] as String,
      startIndex: map['start_index'] as int,
      endIndex: map['end_index'] as int,
      color: map['color'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as int?,
      bookId: json['bookId'] as int? ?? json['book_id'] as int,
      chapterIndex: json['chapterIndex'] as int? ?? json['chapter_index'] as int,
      text: json['text'] as String,
      startIndex: json['startIndex'] as int? ?? json['start_index'] as int,
      endIndex: json['endIndex'] as int? ?? json['end_index'] as int,
      color: json['color'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int? ?? 0),
    );
  }

  Highlight copyWith({
    int? id,
    int? bookId,
    int? chapterIndex,
    String? text,
    int? startIndex,
    int? endIndex,
    String? color,
    DateTime? createdAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      text: text ?? this.text,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
