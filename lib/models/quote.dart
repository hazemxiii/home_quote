class Quote {
  String quote;
  String? author;
  String id;
  bool selected;
  List<String> tags;

  Quote({
    required this.quote,
    this.author,
    required this.id,
    required this.selected,
    required this.tags,
  });

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
      'quote': quote,
      'author': author,
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
    tags = quote.tags;
  }
}
