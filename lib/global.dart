import 'dart:io';
import 'package:flutter/material.dart';
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
