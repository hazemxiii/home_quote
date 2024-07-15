import 'dart:async';
import 'dart:convert';
import 'dart:math';
import "package:flutter/material.dart";
import 'package:home_quote/settings.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
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

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<StyleNotifier>(context, listen: false).loadStyle();
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return FutureBuilder(
          future:
              Provider.of<QuotesNotifier>(context, listen: false).loadData(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: clrs.getColorC),
              );
            }
            return Scaffold(
                floatingActionButton: FloatingActionButton(
                    backgroundColor: clrs.getColorC,
                    foregroundColor: clrs.getTextC,
                    child: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const InputDialogWidget();
                          });
                    }),
                backgroundColor: clrs.getTextC,
                appBar: AppBar(
                  title: const Text("My Quotes"),
                  backgroundColor: clrs.getTextC,
                  foregroundColor: clrs.getColorC,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Provider.of<QuotesNotifier>(context, listen: false)
                            .selectAll();
                      },
                      icon: Icon(
                        Icons.select_all,
                        color: clrs.getColorC,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SettingsPageWidget()));
                        },
                        icon: const Icon(Icons.settings))
                  ],
                ),
                body: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Provider.of<QuotesNotifier>(context, listen: false)
                            .changeVisible();
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: 100,
                          margin: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: clrs.getColorC,
                          ),
                          child: Consumer<QuotesNotifier>(
                            builder: (context, qNotifier, child) {
                              return Text(
                                qNotifier.getVisible,
                                style: TextStyle(color: clrs.getTextC),
                              );
                            },
                          )),
                    ),
                    const MultipleSelectionWidget(),
                    Expanded(child: SingleChildScrollView(
                      child: Consumer<QuotesNotifier>(
                          builder: (context, qNotifier, child) {
                        Map data = qNotifier.getQuotes;
                        return Column(
                            children: List.generate(data.length, (i) {
                          MapEntry quote = data.entries.elementAt(i);
                          return QuoteWidget(
                            selected: qNotifier.isSelected(quote.key),
                            quote: quote.value,
                            id: quote.key,
                          );
                        }));
                      }),
                    )),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ));
          });
    });
  }
}

class QuoteWidget extends StatefulWidget {
  final String quote;
  final String id;
  final bool selected;
  const QuoteWidget(
      {super.key,
      required this.quote,
      required this.id,
      required this.selected});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  late TextEditingController editController;
  @override
  void initState() {
    editController = TextEditingController(text: widget.quote);
    super.initState();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      TextStyle btnStyle = TextStyle(color: clrs.getTextC);
      InputBorder border =
          UnderlineInputBorder(borderSide: BorderSide(color: clrs.getTextC));
      return InkWell(
        onTap: () {
          Provider.of<QuotesNotifier>(context, listen: false)
              .selectQuote(widget.id);
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: clrs.getColorC,
                  content: TextField(
                      cursorColor: clrs.getTextC,
                      controller: editController,
                      style: TextStyle(color: clrs.getTextC),
                      decoration: InputDecoration(
                          focusedBorder: border, border: border)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("cancel", style: btnStyle)),
                    TextButton(
                        onPressed: () {
                          Provider.of<QuotesNotifier>(context, listen: false)
                              .editQuote(widget.id, editController.text);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "save",
                          style: btnStyle,
                        ))
                  ],
                );
              });
        },
        child: Dismissible(
          confirmDismiss: (direction) async {
            return await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: clrs.getColorC,
                    content: Text("Delete \"${widget.quote}\"",
                        style: TextStyle(color: clrs.getTextC)),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("Delete",
                              style: TextStyle(color: clrs.getTextC)))
                    ],
                  );
                });
          },
          key: Key(widget.id),
          onDismissed: (direction) {
            Provider.of<QuotesNotifier>(context, listen: false)
                .deleteQuote(widget.id);
          },
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: clrs.getColorC!),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: widget.selected ? clrs.getTextC : clrs.getColorC,
              ),
              child: Text(
                widget.quote,
                style: TextStyle(
                  color: widget.selected ? clrs.getColorC : clrs.getTextC,
                ),
              )),
        ),
      );
    });
  }
}

class InputDialogWidget extends StatefulWidget {
  const InputDialogWidget({super.key});

  @override
  State<InputDialogWidget> createState() => _InputDialogWidgetState();
}

class _InputDialogWidgetState extends State<InputDialogWidget> {
  late TextEditingController textEditingController;
  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      TextStyle btnStyle = TextStyle(color: clrs.getTextC);
      InputBorder border =
          UnderlineInputBorder(borderSide: BorderSide(color: clrs.getTextC));

      return AlertDialog(
        backgroundColor: clrs.getColorC,
        content: TextField(
            cursorColor: clrs.getTextC,
            controller: textEditingController,
            style: TextStyle(color: clrs.getTextC),
            decoration: InputDecoration(focusedBorder: border, border: border)),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel", style: btnStyle)),
          TextButton(
              onPressed: () {
                Provider.of<QuotesNotifier>(context, listen: false)
                    .addQuote(textEditingController.text);

                Navigator.of(context).pop();
              },
              child: Text(
                "save",
                style: btnStyle,
              ))
        ],
      );
    });
  }
}

class MultipleSelectionWidget extends StatefulWidget {
  const MultipleSelectionWidget({super.key});

  @override
  State<MultipleSelectionWidget> createState() =>
      _MultipleSelectionWidgetState();
}

class _MultipleSelectionWidgetState extends State<MultipleSelectionWidget> {
  bool? isMultipleSelection;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return Consumer<QuotesNotifier>(builder: (context, qNotifer, child) {
        return CheckboxListTile(
            tileColor: clrs.getTextC,
            title: Text(
              "Multiple selection",
              style: TextStyle(color: clrs.getColorC),
            ),
            value: qNotifer.getIsMulti,
            activeColor: clrs.getColorC,
            checkColor: clrs.getTextC,
            onChanged: (v) {
              Provider.of<QuotesNotifier>(context, listen: false)
                  .toggleIsMulti();
            });
      });
    });
  }
}
