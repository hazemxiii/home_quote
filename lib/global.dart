import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_quote/models/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

final c = Color.lerp(Colors.black, Colors.white, 0.9);

class StyleNotifier extends ChangeNotifier {
  Color textColor = const Color.fromRGBO(255, 255, 255, 1);
  Color color = const Color.fromRGBO(50, 50, 50, 1);
  bool transparent = false;

  StyleNotifier() {
    loadStyle();
  }

  void loadStyle() async {
    /// used when the page first is loaded to get the colors
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("color")) {
      prefs.setString("color", getHex(color));
    }
    if (!prefs.containsKey("textColor")) {
      prefs.setString("textColor", getHex(textColor));
    }
    if (!prefs.containsKey("transparent")) {
      prefs.setBool("transparent", false);
    }

    textColor = parseColorFromHex(prefs.getString("textColor")!);
    color = parseColorFromHex(prefs.getString("color")!);
    transparent = prefs.getBool("transparent")!;

    updateWidgetColors();

    notifyListeners();
  }

  void updateWidgetColors() {
    /// updates the colors of the home widget
    try {
      if (!Platform.isWindows) {
        HomeWidget.saveWidgetData(
            "color", !transparent ? "#${getHex(color)}" : "transparent");
        HomeWidget.saveWidgetData("textColor", "#${getHex(textColor)}");
        HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.example.home_quote.NewAppWidget',
        );
      }
    } catch (e) {
      // print(e);
    }
  }

  void setTextColor(Color c) async {
    /// changes text color
    SharedPreferences prefs = await SharedPreferences.getInstance();
    textColor = c;
    prefs.setString("textColor", getHex(textColor));
    updateWidgetColors();
    notifyListeners();
  }

  void setColor(Color c) async {
    /// changes text widget background color
    SharedPreferences prefs = await SharedPreferences.getInstance();
    color = c;
    prefs.setString("color", getHex(color));
    updateWidgetColors();
    notifyListeners();
  }

  void toggleTransparent() async {
    /// toggles transparent background
    SharedPreferences prefs = await SharedPreferences.getInstance();
    transparent = !transparent;
    prefs.setBool("transparent", transparent);
    updateWidgetColors();
    notifyListeners();
  }

  String getHex(Color c) {
    /// gets the hex code from the color without the "#"
    // Map hexs = {10: "a", 11: "b", 12: "c", 13: "d", 14: "e", 15: "f"};

    // int red0 = (c.red / 16).floor();
    // int red1 = c.red - red0 * 16;
    // int green0 = (c.green / 16).floor();
    // int green1 = c.green - green0 * 16;
    // int blue0 = (c.blue / 16).floor();
    // int blue1 = c.blue - blue0 * 16;

    // String red =
    //     "${red0 > 9 ? hexs[red0] : red0}${red1 > 9 ? hexs[red1] : red1}";
    // String green =
    //     "${green0 > 9 ? hexs[green0] : green0}${green1 > 9 ? hexs[green1] : green1}";
    // String blue =
    //     "${blue0 > 9 ? hexs[blue0] : blue0}${blue1 > 9 ? hexs[blue1] : blue1}";

    // return "$red$green$blue";
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Color parseColorFromHex(String hex) {
    /// gets the color from the hex code
    int r = colorFromChannel(hex.substring(0, 2));
    int g = colorFromChannel(hex.substring(2, 4));
    int b = colorFromChannel(hex.substring(4, 6));

    return Color.fromRGBO(r, g, b, 1);
  }

  int colorFromChannel(String channel) {
    /// gets the the hex code of r or g or b
    channel = channel.toLowerCase();
    Map hex = {"a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15};

    // hex code is defined as ff -> (left)(right)
    int left;
    int right;

    // if it's not a number, then we get the equivalant number in base 16
    try {
      left = int.parse(channel[0]);
    } catch (e) {
      left = hex[channel[0]];
    }

    try {
      right = int.parse(channel[1]);
    } catch (e) {
      right = hex[channel[1]];
    }

    // return the equivalant value in decimal
    return left * 16 + right;
  }

  Color get getTextC => textColor;
  Color? get getColorC => color;
  bool get isTransparent => transparent;
}

class QuotesNotifier extends ChangeNotifier {
  List<Quote> quotes = [];
  // List<String> selected = [];
  Quote? visible;
  // bool isMulti = false;

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
      if (quote.quote == prefs.getString("visible")) {
        visible = quote;
      }
      quotes.add(quote);
    }

    // if (!prefs.containsKey("quotes")) {
    //   prefs.setString("quotes", "{}");
    // }

    // if (!prefs.containsKey("selected")) {
    //   prefs.setStringList("selected", []);
    // }

    // if (!prefs.containsKey("visible")) {
    //   prefs.setString("visible", "");
    // }

    // if (!prefs.containsKey("isMulti")) {
    //   prefs.setBool("isMulti", false);
    // }

    // quotes = jsonDecode(prefs.getString("quotes")!);
    // selected = prefs.getStringList("selected")!;
    // isMulti = prefs.getBool("isMulti")!;
    // visible = prefs.getString("visible")!;

    // changeVisible();

    notifyListeners();

    return true;
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

  // void toggleIsMulti() async {
  //   /// toggles mutli selection
  //   isMulti = !isMulti;
  //   // if we have more than 1 selected and we turned mutli off, deselect all
  //   if (!isMulti && selected.length > 1) {
  //     clearSelection();
  //   }
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool("isMulti", isMulti);
  //   notifyListeners();
  // }

  // bool isSelected(String id) {
  //   return selected.contains(id);
  // }

  void selectAll() async {
    /// selects all

    // if it's single mode change it to multi
    // if (!isMulti) {
    //   toggleIsMulti();
    // }
    for (final q in quotes) {
      q.selected = true;
    }
    // List keys = quotes.keys.toList();
    // for (int i = 0; i < keys.length; i++) {
    //   if (!selected.contains(keys[i])) {
    //     selectQuote(keys[i]);
    //   }
    // }
    notifyListeners();
  }

  void addQuote(Quote quote) async {
    /// adds quote to the data
    quotes.add(quote);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myQuotes", jsonEncode(quotes));
    notifyListeners();
  }

  void deleteQuote(Quote q) async {
    /// deletes a quote
    quotes.remove(q);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myQuotes", jsonEncode(quotes));

    if (visible == q) {
      changeVisible();
    }

    notifyListeners();
  }

  void editQuote(Quote q, Quote newQuote) async {
    /// Edit a quote

    q.updateWith(newQuote);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("quotes", jsonEncode(quotes));

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selected", []);
  }

  Quote? get getVisible => visible;
  // bool get getIsMulti => isMulti;
  List<Quote> get getQuotes => quotes;
  // List get getSelected => selected;
}
