import 'package:flutter/material.dart';

class MyColors extends ChangeNotifier {
  Color textColor = const Color.fromRGBO(255, 255, 255, 1);
  Color? color = Colors.blueGrey;

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
