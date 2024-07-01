import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
// import "quotes_prefs.dart";

class MyColors extends ChangeNotifier {
  Color textColor = const Color.fromRGBO(73, 73, 71, 1);
  Color color = const Color.fromRGBO(53, 255, 105, 1);

  void setTextColor(Color c) {
    textColor = c;
    notifyListeners();
  }

  void setColor(Color c) {
    color = c;
    notifyListeners();
  }

  Color get getTextC => textColor;
  Color? get getColorC => color;
}

class QuotesNotifier extends ChangeNotifier {
  /*
  prefs keys:
  quotes -> map of {id:quote}
  selected -> list of selected ids
  visible -> the current visible quote
  isMulti -> multiple selection active
   */

  Map quotes = {};
  List<String> selected = [];
  String visible = "";
  bool isMulti = false;
  Future<bool> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("quotes")) {
      prefs.setString("quotes", "{}");
    }

    if (!prefs.containsKey("selected")) {
      prefs.setStringList("selected", []);
    }

    if (!prefs.containsKey("visible")) {
      prefs.setString("visible", "");
    }

    if (!prefs.containsKey("isMulti")) {
      prefs.setBool("isMulti", false);
    }

    quotes = jsonDecode(prefs.getString("quotes")!);
    selected = prefs.getStringList("selected")!;
    isMulti = prefs.getBool("isMulti")!;

    changeVisible();

    notifyListeners();

    return Future.value(true);
  }

  void toggleIsMulti() async {
    isMulti = !isMulti;
    if (!isMulti && selected.length > 1) {
      clearSelection();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isMulti", isMulti);
    notifyListeners();
  }

  bool isSelected(String id) {
    return selected.contains(id);
  }

  void addQuote(String quote) async {
    String key = DateTime.now().toString();
    quotes[key] = quote;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("quotes", jsonEncode(quotes));
    notifyListeners();
  }

  void deleteQuote(String id) async {
    quotes.remove(id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("quotes", jsonEncode(quotes));
    notifyListeners();
  }

  void selectQuote(String id) async {
    if (selected.contains(id)) {
      selected.remove(id);
      changeVisible();
    } else {
      if (isMulti) {
        selected.add(id);
      } else {
        selected = [id];
        changeVisible();
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selected", selected);

    notifyListeners();
  }

  void changeVisible() async {
    if (selected.isNotEmpty) {
      visible = quotes[selected[Random().nextInt(selected.length)]];
    } else {
      visible = "";
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("visible", visible);

    notifyListeners();

    HomeWidget.saveWidgetData("visible", visible);

    HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.example.home_quote.NewAppWidget',
    );
  }

  void clearSelection() async {
    selected = [];
    visible = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("selected", []);
  }

  String get getVisible => visible;
  bool get getIsMulti => isMulti;
  Map get getQuotes => quotes;
}
