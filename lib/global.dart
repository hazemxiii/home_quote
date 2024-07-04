import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

class MyColors extends ChangeNotifier {
  Color textColor = const Color.fromRGBO(255, 255, 255, 1);
  Color color = const Color.fromRGBO(50, 50, 50, 1);

  void loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("color")) {
      prefs.setString("color", getHex(color));
    }
    if (!prefs.containsKey("textColor")) {
      prefs.setString("textColor", getHex(textColor));
    }

    textColor = parseColorFromHex(prefs.getString("textColor")!);
    color = parseColorFromHex(prefs.getString("color")!);

    updateWidgetColors();

    notifyListeners();
  }

  void updateWidgetColors() {
    try {
      if (!Platform.isWindows) {
        HomeWidget.saveWidgetData("color", "#${getHex(color)}");
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    textColor = c;
    prefs.setString("textColor", getHex(textColor));
    updateWidgetColors();
    notifyListeners();
  }

  void setColor(Color c) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    color = c;
    prefs.setString("color", getHex(color));
    updateWidgetColors();
    notifyListeners();
  }

  String getHex(Color c) {
    Map hexs = {10: "a", 11: "b", 12: "c", 13: "d", 14: "e", 15: "f"};

    int red0 = (c.red / 16).floor();
    int red1 = c.red - red0 * 16;
    int green0 = (c.green / 16).floor();
    int green1 = c.green - green0 * 16;
    int blue0 = (c.blue / 16).floor();
    int blue1 = c.blue - blue0 * 16;

    String red =
        "${red0 > 9 ? hexs[red0] : red0}${red1 > 9 ? hexs[red1] : red1}";
    String green =
        "${green0 > 9 ? hexs[green0] : green0}${green1 > 9 ? hexs[green1] : green1}";
    String blue =
        "${blue0 > 9 ? hexs[blue0] : blue0}${blue1 > 9 ? hexs[blue1] : blue1}";

    return "$red$green$blue";
  }

  Color parseColorFromHex(String hex) {
    int r = colorFromChannel(hex.substring(0, 2));
    int g = colorFromChannel(hex.substring(2, 4));
    int b = colorFromChannel(hex.substring(4, 6));

    return Color.fromRGBO(r, g, b, 1);
  }

  int colorFromChannel(String channel) {
    channel = channel.toLowerCase();
    Map hex = {"a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15};

    int left;
    int right;

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

    return left * 16 + right;
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

    if (selected.contains(id)) {
      selectQuote(id);
    } else {
      notifyListeners();
    }
  }

  selectQuote(String id) async {
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
    try {
      if (!Platform.isWindows) {
        HomeWidget.saveWidgetData("visible", visible);
        HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.example.home_quote.NewAppWidget',
        );
      }
    } catch (e) {
      // print(e);
    }
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
