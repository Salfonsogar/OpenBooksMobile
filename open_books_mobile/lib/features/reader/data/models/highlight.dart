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
