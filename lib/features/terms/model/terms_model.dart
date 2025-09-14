class Term {
  final int id;
  final String title;
  final String url;
  final bool required;
  bool agreed;

  Term({
    required this.id,
    required this.title,
    required this.url,
    required this.required,
    this.agreed = false,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'],
      title: json['title'],
      url: json['content'],
      required: json['required'],
    );
  }
}
