class Quote {
  late String _quote;
  late String? _author;
  String id;
  bool selected;
  late List<String> _tags;
  Quote({
    required String quote,
    String? author,
    required this.id,
    required this.selected,
    List<String>? tags,
  }) {
    _quote = quote.trim();
    _author = author?.trim();
    _tags = [...(tags ?? [])];
  }

  String get quote => _quote;
  String? get author => _author;
  List<String> get tags => _tags;

  set quote(String quote) {
    _quote = quote.trim();
  }

  set author(String? author) {
    _author = author?.trim();
  }

  void addTag(String tag) {
    _tags.add(tag.trim());
  }

  void removeTag(String tag) {
    _tags.remove(tag.trim());
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    final tags = List<String>.from(json['tags']);
    final quote = Quote(
      quote: json['quote'],
      author: json['author'],
      id: json['id'],
      selected: json['selected'],
      tags: tags,
    );
    return quote;
  }

  Map<String, dynamic> toJson() {
    return {
      'quote': _quote,
      'author': _author,
      'id': id,
      'selected': selected,
      'tags': tags,
    };
  }

  void updateWith(Quote quote) {
    this.quote = quote.quote;
    author = quote.author;
    id = quote.id;
    selected = quote.selected;
    _tags = quote.tags;
  }
}
