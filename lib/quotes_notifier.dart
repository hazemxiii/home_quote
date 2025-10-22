import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotesNotifier extends ChangeNotifier {
  List<Quote> quotes = [];
  final Map<String, List<Quote>> _byAuthor = {};
  final Map<String, List<Quote>> _byTag = {};
  Quote? visible;

  QuotesNotifier() {
    loadData();
  }

  Future<bool> loadData() async {
    /// loads the quotes with all relevant data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('myQuotes')) {
      prefs.setString('myQuotes', jsonEncode([]));
    }
    final q = jsonDecode(prefs.getString("myQuotes")!);
    for (final e in q) {
      final quote = Quote.fromJson(Map<String, dynamic>.from(e));
      final author = quote.author;
      final tags = quote.tags;
      if (author != null) {
        _byAuthor[author] ??= [];
        _byAuthor[author]!.add(quote);
      }
      for (final tag in tags) {
        _byTag[tag] ??= [];
        _byTag[tag]!.add(quote);
      }
      if (quote.quote == prefs.getString("visible")) {
        visible = quote;
      }
      quotes.add(quote);
    }
    notifyListeners();

    return true;
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myQuotes", jsonEncode(quotes));
  }

  List<Quote> getQuotesByAuthor(String author) {
    return _byAuthor[author] ?? [];
  }

  List<Quote> getQuotesByTag(String tag) {
    return _byTag[tag] ?? [];
  }

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
    /// adds quote to the data
    quotes.add(quote);
    saveData();
    notifyListeners();
  }

  void deleteQuote(Quote q) async {
    /// deletes a quote
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

    // if the quote is the visible one, change the visible
    if (visible == q) {
      changeVisible();
    }
    notifyListeners();
  }

  void selectQuote(Quote q) async {
    /// selects or deselects a quote
    q.selected = !q.selected;

    // if (selected.contains(id)) {
    //   selected.remove(id);
    //   changeVisible();
    // } else {
    //   // if it's signle selection mode, make it the only quote in selected, else add it
    //   if (isMulti) {
    //     selected.add(id);
    //   } else {
    //     selected = [id];
    //     changeVisible();
    //   }
    // }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setStringList("selected", selected);

    if (q == visible) {
      changeVisible();
    }

    saveData();

    notifyListeners();
  }

  void changeVisible() async {
    /// changes the current visible quote

    // get a random quote from selection
    try {
      // visible = quotes[selected[Random().nextInt(selected.length)]];
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
    /// removes all selected quotes
    for (final q in quotes) {
      q.selected = false;
    }
    visible = null;
    saveData();
    notifyListeners();
  }

  Quote? get getVisible => visible;
  // bool get getIsMulti => isMulti;
  List<Quote> get getQuotes => quotes;
  // List get getSelected => selected;
}
