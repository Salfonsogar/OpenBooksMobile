import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final int? id;
  final int bookId;
  final int chapterIndex;
  final String title;
  final DateTime createdAt;

  const Bookmark({
    this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_index': chapterIndex,
      'title': title,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      chapterIndex: map['chapter_index'] as int,
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Bookmark copyWith({
    int? id,
    int? bookId,
    int? chapterIndex,
    String? title,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, bookId, chapterIndex, title, createdAt];
}
