import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map> getQuotes() async {
  SharedPreferences spref = await SharedPreferences.getInstance();

  if (!spref.containsKey("Quotes")) {
    spref.setString("Quotes", "{}");
  }
  if (!spref.containsKey("selected")) {
    spref.setStringList("selected", []);
  }
  if (!spref.containsKey("maxID")) {
    spref.setInt("maxID", 0);
  }
  if (!spref.containsKey("multiSelection")) {
    spref.setBool("multiSelection", false);
  }
  if (!spref.containsKey("currentVisible")) {
    spref.setString("currentVisible", "");
  }

  return {
    "quotes": spref.getString("Quotes"),
    "selected": spref.getStringList("selected"),
    "multi": spref.getBool("multiSelection"),
    "current": spref.getString("currentVisible")
  };
}

void deleteQuote(String id) async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  Map quotes = jsonDecode(spref.getString("Quotes")!);
  quotes.remove(id);
  spref.setString("Quotes", jsonEncode(quotes));

  selectQuote(id, false);
  changeVisible();
}

void addQuote(String quote) async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  Map quotes = jsonDecode(spref.getString("Quotes")!);
  int? newMaxID = spref.getInt("maxID")! + 1;

  String newID = "$newMaxID";

  quotes[newID] = quote;

  spref.setString("Quotes", jsonEncode(quotes));
  spref.setInt("maxID", newMaxID);

  changeVisible();
}

Future<bool> selectQuote(String id, bool select) async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  List<String>? selected = spref.getStringList("selected");
  bool multi = spref.getBool("multiSelection")!;

  if (!multi) {
    if (select) {
      spref.setStringList("selected", [id]);
      changeVisible();
    }
    return Future.value(true);
  }

  if (select) {
    selected!.add(id);
  } else {
    selected!.remove(id);
  }

  spref.setStringList("selected", selected);
  changeVisible();

  return Future.value(true);
}

void toggleMultiSelection() async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  bool oldVal = spref.getBool("multiSelection")!;
  int selectedNum = spref.getStringList("selected")!.length;
  if (oldVal && selectedNum > 1) {
    spref.setStringList("selected", []);
    spref.setString("currentVisible", "");
  }
  spref.setBool("multiSelection", !oldVal);
}

void changeVisible() async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  List selected = spref.getStringList("selected")!;
  if (selected.isNotEmpty) {
    int randomIDIndex = Random().nextInt(selected.length);
    String selectedID = selected[randomIDIndex];
    spref.setString("currentVisible", selectedID);
  }
}
