import "package:flutter/material.dart";
import 'package:home_quote/quotes_notifier.dart';
import 'package:home_quote/quotes_page/quotes_page.dart';
import 'global.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void f() async {
  print((await SharedPreferences.getInstance()).getString("textColor"));
}

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => StyleNotifier()),
      ChangeNotifierProvider(create: (context) => QuotesNotifier())
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: QuotesPage());
  }
}
