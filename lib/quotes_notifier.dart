import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotesNotifier extends ChangeNotifier {
  List<Quote> quotes = [];
  // final Map<String, List<Quote>> _byAuthor = {};
  // final Map<String, List<Quote>> _byTag = {};
  Quote? visible;
  String _search = "";
  final _selectedTag = <String>[];
  final _selectedAuthor = <String>[];

  QuotesNotifier() {
    loadData();
  }

  List<String> get selectedAuthor => _selectedAuthor;
  List<String> get selectedTag => _selectedTag;

  List<Quote> get filtered {
    return quotes.where((quote) => !isFilteredOut(quote)).toList();
  }

  bool isFilteredOut(Quote quote) {
    if (_search.isNotEmpty) {
      final r = ratio(quote.quote, _search);
      if (r < 25) {
        return true;
      }
    }
    if (!_findAnyInAList(selectedTag, quote.tags)) {
      return true;
    }
    if (quote.author != null &&
        !_findAnyInAList(selectedAuthor, [quote.author ?? ''])) {
      return true;
    }
    return false;
  }

  bool _findAnyInAList(List<String> list, List<String> search) {
    if (list.isEmpty) {
      return true;
    }
    for (final e in list) {
      if (search.contains(e)) {
        return true;
      }
    }
    return false;
  }

  void setSelectedAuthor(List<String> author) {
    _selectedAuthor.clear();
    _selectedAuthor.addAll(author);
    notifyListeners();
  }

  void setSelectedTag(List<String> tag) {
    _selectedTag.clear();
    _selectedTag.addAll(tag);
    notifyListeners();
  }

  Future<bool> loadData() async {
    final migrated = await migrateQuotes();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('myQuotes')) {
      prefs.setString('myQuotes', jsonEncode([]));
    }
    final q = jsonDecode(prefs.getString("myQuotes")!);
    for (final e in q) {
      final quote = Quote.fromJson(Map<String, dynamic>.from(e));
      // final author = quote.author;
      // final tags = quote.tags;
      // if (author != null) {
      //   _byAuthor[author] ??= [];
      //   _byAuthor[author]!.add(quote);
      // }
      // for (final tag in tags) {
      //   _byTag[tag] ??= [];
      //   _byTag[tag]!.add(quote);
      // }
      if (quote.quote == prefs.getString("visible")) {
        visible = quote;
      }
      quotes.add(quote);
    }
    if (migrated) {
      saveData();
    }
    notifyListeners();

    return true;
  }

  Future<bool> migrateQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool migrated = prefs.getBool('migrated') ?? false;
    if (migrated) {
      return false;
    }
    Map oldQuotes = jsonDecode(prefs.getString('quotes') ?? "{}");
    for (final e in oldQuotes.entries) {
      Quote quote = Quote(
        id: e.key,
        quote: e.value,
        author: null,
        tags: [],
        selected: false,
      );
      quotes.add(quote);
    }
    prefs.setBool('migrated', true);
    return true;
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myQuotes", jsonEncode(quotes));
  }

  // List<String> get authors => _byAuthor.keys.toList();

  // List<String> get tags => _byTag.keys.toList();

  void setDataFromFile(File f) async {
    List data = (await f.readAsString()).split("\n");

    String quotesString = data[0];
    quotes = jsonDecode(quotesString);
    // selected = data[1].split(",");

    // if (selected.length > 1 && !isMulti) {
    //   toggleIsMulti();
    // }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("quotes", quotesString);
    // prefs.setStringList("selected", selected);

    changeVisible();
  }

  void selectAll() async {
    for (final q in quotes) {
      q.selected = true;
    }
    saveData();
    notifyListeners();
  }

  void addQuote(Quote quote) async {
    quotes.add(quote);
    saveData();
    notifyListeners();
  }

  void deleteQuote(Quote q) async {
    quotes.remove(q);
    saveData();

    if (visible == q) {
      changeVisible();
    }

    notifyListeners();
  }

  void editQuote(Quote q, Quote newQuote) async {
    q.updateWith(newQuote);
    saveData();
    if (visible == q) {
      changeVisible();
    }
    notifyListeners();
  }

  void selectQuote(Quote q) async {
    q.selected = !q.selected;

    if (q == visible) {
      changeVisible();
    }

    saveData();

    notifyListeners();
  }

  void changeVisible() async {
    try {
      final selected = quotes.where((q) => q.selected).toList();
      if (selected.isEmpty) {
        visible = null;
      } else {
        visible = selected[Random().nextInt(selected.length)];
      }
    } catch (e) {
      visible = null;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("visible", visible?.quote ?? "");

    notifyListeners();

    try {
      if (!Platform.isWindows) {
        HomeWidget.saveWidgetData("visible", visible?.quote ?? "");
        HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.example.home_quote.NewAppWidget',
        );
      }
    } catch (e) {
      // print(e);
    }
  }

  void clearSelection() async {
    for (final q in quotes) {
      q.selected = false;
    }
    visible = null;
    saveData();
    notifyListeners();
  }

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void toggleAuthorSelect(String author) {
    if (selectedAuthor.contains(author)) {
      selectedAuthor.remove(author);
    } else {
      selectedAuthor.add(author);
    }
    notifyListeners();
  }

  void toggleTagSelect(String tag) {
    if (selectedTag.contains(tag)) {
      selectedTag.remove(tag);
    } else {
      selectedTag.add(tag);
    }
    notifyListeners();
  }

  Quote? get getVisible => visible;
  List<Quote> get getQuotes => quotes;
  String get search => _search;
}
