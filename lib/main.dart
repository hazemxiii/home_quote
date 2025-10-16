import 'dart:async';
import 'dart:convert';
import 'dart:math';
import "package:flutter/material.dart";
import 'package:home_quote/quotes_page.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map quotes = jsonDecode(prefs.getString("quotes")!);
      List<String> selected = prefs.getStringList("selected")!;
      String visible = prefs.getString("visible")!;

      String random = visible;
      while (random == visible && selected.isNotEmpty) {
        random = quotes[selected[Random().nextInt(selected.length)]];
      }

      prefs.setString("visible", random);

      HomeWidget.saveWidgetData("visible", random);
      HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.example.home_quote.NewAppWidget',
      );
    } catch (e) {
      // print(e);
    }
    return Future.value(true);
  });
}

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // Workmanager().registerPeriodicTask("uniqueName", "taskName",
  //     frequency: const Duration(minutes: 15),
  //     initialDelay: const Duration(minutes: 15));

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
