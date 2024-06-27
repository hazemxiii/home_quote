import "package:flutter/material.dart";
import 'global.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MyColors(),
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
  bool isMultipleSelection = false;
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
          body: Column(
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 100,
                  margin: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: clrs.getColorC,
                  ),
                  child: Text(
                    "Selected quote is here",
                    style: TextStyle(color: clrs.getTextC),
                  )),
              CheckboxListTile(
                  tileColor: clrs.getTextC,
                  title: Text(
                    "Multiple selection",
                    style: TextStyle(color: clrs.color),
                  ),
                  value: isMultipleSelection,
                  activeColor: clrs.color,
                  onChanged: (v) {
                    setState(() {
                      isMultipleSelection = v!;
                    });
                  }),
              Expanded(
                  child: SingleChildScrollView(
                child: FutureBuilder(
                    future: getQuotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map data = snapshot.data!;
                        List quotes = data['quotes'];
                        List selected = data['selected'];
                        return Column(
                            children: List.generate(
                                quotes.length,
                                (i) => QuoteWidget(
                                      selected: selected.contains("$i"),
                                      quote: quotes[i],
                                      index: i,
                                    )));
                      } else {
                        return Center(
                            child: CircularProgressIndicator(
                          color: clrs.getColorC,
                        ));
                      }
                    }),
              ))
            ],
          ));
    });
  }
}

class QuoteWidget extends StatefulWidget {
  final String quote;
  final int index;
  final bool selected;
  const QuoteWidget(
      {super.key,
      required this.quote,
      required this.index,
      required this.selected});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  bool? selected;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.quote);
    // print(selected);
    return Consumer<MyColors>(builder: (context, clrs, child) {
      return InkWell(
        onTap: () async {
          await selectQuote(widget.index, !selected!);
          setState(() {
            selected = !selected!;
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
          key: const ValueKey(0),
          onDismissed: (direction) {
            deleteQuote(widget.index);
          },
          child: InkWell(
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: clrs.getColorC,
                ),
                child: Text(
                  selected! ? "${widget.quote} selected" : widget.quote,
                  style: TextStyle(
                    color: clrs.getTextC,
                  ),
                )),
          ),
        ),
      );
    });
  }

  void deleteQuote(int index) async {
    SharedPreferences spref = await SharedPreferences.getInstance();
    List<String>? quotes = spref.getStringList("Quotes");
    quotes = quotes!.sublist(0, index) + quotes.sublist(index + 1);
    spref.setStringList("Quotes", quotes);
    selectQuote(index, false);
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

  void addQuote(String quote) async {
    SharedPreferences spref = await SharedPreferences.getInstance();

    List<String>? quotes = spref.getStringList("Quotes");

    quotes!.add(quote);

    spref.setStringList("Quotes", quotes);
  }
}

Future<Map> getQuotes() async {
  SharedPreferences spref = await SharedPreferences.getInstance();

  if (!spref.containsKey("Quotes")) {
    spref.setStringList("Quotes", []);
  }
  if (!spref.containsKey("selected")) {
    spref.setStringList("selected", []);
  }
  return {
    "quotes": spref.getStringList("Quotes"),
    "selected": spref.getStringList("selected")
  };
}

Future<bool> selectQuote(int index, bool select) async {
  SharedPreferences spref = await SharedPreferences.getInstance();
  List<String>? selected = spref.getStringList("selected");
  if (select) {
    selected!.add("$index");
  } else {
    selected!.remove("$index");
  }

  spref.setStringList("selected", selected);

  return Future.value(true);
}
