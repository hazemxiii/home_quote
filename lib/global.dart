import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SelectNotifier extends ChangeNotifier {
  List selected = [];
  bool multiSelection = false;

  void selectionChanged() async {
    SharedPreferences spref = await SharedPreferences.getInstance();
    selected = spref.getStringList("selected")!;
    notifyListeners();
  }

  bool isSelected(String id) {
    return selected.contains(id);
  }

  void setSelected(List s) {
    selected = s;
  }
}
