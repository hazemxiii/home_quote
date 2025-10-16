import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:home_quote/input_dialog.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_quote/quote_widget.dart';
import 'package:home_quote/settings.dart';
import 'package:provider/provider.dart';

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
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
              backgroundColor: clrs.getColorC,
              foregroundColor: clrs.getTextC,
              child: const Icon(Icons.add),
              onPressed: () async {
                final Quote? quote = await showDialog(
                    context: context,
                    builder: (context) {
                      return const InputDialogWidget();
                    });
                if (quote != null && context.mounted) {
                  Provider.of<QuotesNotifier>(context, listen: false)
                      .addQuote(quote);
                }
              }),
          backgroundColor: c,
          appBar: AppBar(
            title: const Text("My Quotes"),
            backgroundColor: c,
            foregroundColor: Colors.black,
            actions: [
              IconButton(
                onPressed: () {
                  Provider.of<QuotesNotifier>(context, listen: false)
                      .selectAll();
                },
                icon: const Icon(Icons.select_all),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SettingsPageWidget()));
                  },
                  icon: const Icon(Icons.settings))
            ],
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Provider.of<QuotesNotifier>(context, listen: false)
                          .changeVisible();
                    },
                    child: Consumer<QuotesNotifier>(
                      builder: (context, qNotifier, child) {
                        if (qNotifier.getVisible == null) {
                          return const Text("No Quotes");
                        }
                        return IgnorePointer(
                          ignoring: true,
                          child: QuoteWidget(
                            isDisplay: true,
                            quote: qNotifier.getVisible!,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: GridView.builder(
                          itemCount:
                              context.watch<QuotesNotifier>().getQuotes.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  mainAxisExtent: 300,
                                  maxCrossAxisExtent: 300),
                          itemBuilder: (context, index) {
                            final quote =
                                context.read<QuotesNotifier>().getQuotes[index];
                            return QuoteWidget(quote: quote);
                          })),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ));
    });
  }
}
