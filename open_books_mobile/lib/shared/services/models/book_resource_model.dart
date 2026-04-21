class BookResourceModel {
  final int? id;
  final int libroId;
  final String path;
  final String content;

  BookResourceModel({
    this.id,
    required this.libroId,
    required this.path,
    required this.content,
  });

  factory BookResourceModel.fromMap(Map<String, dynamic> map) {
    return BookResourceModel(
      id: map['id'] as int?,
      libroId: map['libro_id'] as int,
      path: map['path'] as String,
      content: map['content'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'libro_id': libroId,
      'path': path,
      'content': content,
    };
  }
}