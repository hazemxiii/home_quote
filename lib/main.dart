import 'dart:convert';

import "package:flutter/material.dart";
import 'global.dart';
import 'package:provider/provider.dart';
import "quotes_prefs.dart";

void main() {
  // runApp(ChangeNotifierProvider(
  //   create: (context) => MyColors(),
  //   child: const App(),
  // ));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MyColors()),
      ChangeNotifierProvider(create: (context) => SelectNotifier())
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
  Widget build(BuildContext context) {
    return Consumer<MyColors>(builder: (context, clrs, child) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
              foregroundColor: clrs.getColorC,
              backgroundColor: clrs.getTextC,
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
          ),
          body: FutureBuilder(
              future: getQuotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  Map data = snapshot.data!;
                  Map quotes = jsonDecode(data['quotes']);
                  List selected = data['selected'];
                  Provider.of<SelectNotifier>(context, listen: false)
                      .setSelected(selected);
                  bool multi = data['multi'];
                  String current = data["current"];

                  return Column(
                    children: [
                      Container(
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
                          child: Text(
                            current,
                            style: TextStyle(color: clrs.getTextC),
                          )),
                      MultipleSelectionWidget(isOn: multi),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                            children: List.generate(quotes.length, (i) {
                          MapEntry quote = quotes.entries.elementAt(i);
                          return QuoteWidget(
                            // selected: selected.contains(quote.key),
                            quote: quote.value,
                            id: quote.key,
                          );
                        })),
                      ))
                    ],
                  );
                } else {
                  return CircularProgressIndicator(
                    color: clrs.getColorC,
                  );
                }
              }));
    });
  }
}

class QuoteWidget extends StatefulWidget {
  final String quote;
  final String id;
  // final bool selected;
  const QuoteWidget({
    super.key,
    required this.quote,
    required this.id,
    // required this.selected
  });

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  bool? selected;

  @override
  void initState() {
    // selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyColors>(builder: (context, clrs, child) {
      return Consumer<SelectNotifier>(builder: (context, selection, child2) {
        bool selected = selection.isSelected(widget.id);
        return InkWell(
          onTap: () async {
            await selectQuote(widget.id, !selected);
            if (context.mounted) {
              Provider.of<SelectNotifier>(context, listen: false)
                  .selectionChanged();
            }
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
            key: const ValueKey(0),
            onDismissed: (direction) {
              deleteQuote(widget.id);
            },
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border.all(color: clrs.getColorC!),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: selected ? clrs.getTextC : clrs.getColorC,
                ),
                child: Text(
                  widget.quote,
                  style: TextStyle(
                    color: selected ? clrs.getColorC : clrs.getTextC,
                  ),
                )),
          ),
        );
      });
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
  Widget build(BuildContext context) {
    return Consumer<MyColors>(builder: (context, clrs, child) {
      TextStyle btnStyle = TextStyle(color: clrs.getColorC);
      InputBorder border =
          UnderlineInputBorder(borderSide: BorderSide(color: clrs.getColorC!));

      return AlertDialog(
        content: TextField(
            controller: textEditingController,
            style: TextStyle(color: clrs.getColorC),
            decoration: InputDecoration(focusedBorder: border, border: border)),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel", style: btnStyle)),
          TextButton(
              onPressed: () {
                addQuote(textEditingController.text);
                Provider.of<MyColors>(context, listen: false)
                    .setColor(clrs.getColorC!);
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
  final bool isOn;
  const MultipleSelectionWidget({super.key, required this.isOn});

  @override
  State<MultipleSelectionWidget> createState() =>
      _MultipleSelectionWidgetState();
}

class _MultipleSelectionWidgetState extends State<MultipleSelectionWidget> {
  bool? isMultipleSelection;

  @override
  void initState() {
    isMultipleSelection = widget.isOn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyColors>(builder: (context, clrs, child) {
      return CheckboxListTile(
          tileColor: clrs.getTextC,
          title: Text(
            "Multiple selection",
            style: TextStyle(color: clrs.color),
          ),
          value: isMultipleSelection,
          activeColor: clrs.color,
          onChanged: (v) {
            setState(() {
              toggleMultiSelection();
              isMultipleSelection = v!;
              Provider.of<SelectNotifier>(context, listen: false)
                  .selectionChanged();
            });
          });
    });
  }
}
