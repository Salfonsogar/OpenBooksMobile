class ReaderBlock {
  final String type;
  final dynamic content;
  final Map<String, String>? attributes;

  const ReaderBlock({
    required this.type,
    required this.content,
    this.attributes,
  });
}
