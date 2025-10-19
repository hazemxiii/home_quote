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
    // TODO remove by id & author
    final author = json['author'];
    final tags = List<String>.from(json['tags']);
    _byAuthor[author] ??= [];
    final quote = Quote(
      quote: json['quote'],
      author: author,
      id: json['id'],
      selected: json['selected'],
      tags: tags,
    );
    _byAuthor[author]!.add(quote);
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

  static final Map<String, List<Quote>> _byAuthor = {};
  static final Map<String, List<Quote>> _byTag = {};

  static List<Quote> getQuotesByAuthor(String author) {
    return _byAuthor[author] ?? [];
  }

  static List<Quote> getQuotesByTag(String tag) {
    return _byTag[tag] ?? [];
  }

  void updateWith(Quote quote) {
    quote.quote = quote.quote;
    quote.author = quote.author;
    quote.id = quote.id;
    quote.selected = quote.selected;
    quote.tags = quote.tags;
  }
}
