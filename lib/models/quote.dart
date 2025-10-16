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
    return Quote(
      quote: json['quote'],
      author: json['author'],
      id: json['id'],
      selected: json['selected'],
      tags: List<String>.from(json['tags']),
    );
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
    quote.quote = quote.quote;
    quote.author = quote.author;
    quote.id = quote.id;
    quote.selected = quote.selected;
    quote.tags = quote.tags;
  }
}
