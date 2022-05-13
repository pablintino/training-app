class PageDto {
  final int pageNumber;
  final int elementsInPage;
  final int count;
  final bool hasNext;
  final List<dynamic> data;

  PageDto(
      {required this.pageNumber,
      required this.elementsInPage,
      required this.count,
      required this.hasNext,
      required this.data});

  factory PageDto.fromJson(Map<String, dynamic> json) => PageDto(
        pageNumber: json['pageNumber'] as int,
        elementsInPage: json['elementsInPage'] as int,
        count: json['count'] as int,
        hasNext: json['hasNext'] as bool,
        data: json['data'] as List<dynamic>,
      );
}
