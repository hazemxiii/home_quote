import 'dart:io';

import "package:flutter/material.dart";
import 'package:home_quote/quotes_notifier.dart';
import 'package:home_quote/quotes_page/quotes_page.dart';
import 'style_notifier.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
        const Duration(minutes: 15), 0, changeVisible);
  }
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

@pragma('vm:entry-point')
Future<void> changeVisible() async {
  final quotesNotifier = QuotesNotifier(skipLoading: true);
  await quotesNotifier.loadData();
  quotesNotifier.changeVisible();
}
