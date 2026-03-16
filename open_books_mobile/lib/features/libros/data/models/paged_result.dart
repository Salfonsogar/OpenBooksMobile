class PagedResult<T> {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final List<T> data;

  PagedResult({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
