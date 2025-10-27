import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:home_quote/quotes_page/filter_btn.dart';
import 'package:home_quote/quotes_page/filter_dialog.dart';
import 'package:home_quote/quotes_page/input_dialog.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_quote/quotes_page/quote_widget.dart';
import 'package:home_quote/quotes_notifier.dart';
import 'package:home_quote/quotes_page/search_widget.dart';
import 'package:home_quote/settings.dart';
import 'package:provider/provider.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  Timer? timer;
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchQueryChange);
  }

  void onSearchQueryChange() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(const Duration(milliseconds: 500), () {
      context.read<QuotesNotifier>().setSearch(searchController.text);
    });
  }

  QuotesNotifier get quotesNotX => context.read<QuotesNotifier>();
  QuotesNotifier get quotesNot => context.watch<QuotesNotifier>();

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
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: const Column(
                              children: [
                                Icon(Icons.shuffle, color: Colors.black),
                                Text("No Quote Selected",
                                    style: TextStyle(color: Colors.black))
                              ],
                            ),
                          );
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChangeNotifierProvider.value(
                            value: context.read<QuotesNotifier>(),
                            child: SearchWidget(controller: searchController)),
                      ),
                      const SizedBox(width: 10),
                      FilterBtn(
                        text: "Author",
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                final oldAuthor = quotesNotX.selectedAuthor;
                                return Consumer<QuotesNotifier>(
                                    builder: (context, quotesNot, child) {
                                  return FilterDialog(
                                      type: "Author",
                                      items: quotesNot.authors,
                                      selected: quotesNot.selectedAuthor,
                                      onCancel: () {
                                        quotesNot.setSelectedAuthor(oldAuthor);
                                      },
                                      onPressed: (v) {
                                        quotesNot.toggleAuthorSelect(v);
                                      });
                                });
                              });
                        },
                      ),
                      const SizedBox(width: 5),
                      FilterBtn(
                        text: "Tags",
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                final oldTag = quotesNotX.selectedTag;
                                return Consumer<QuotesNotifier>(
                                    builder: (context, quotesNot, child) {
                                  return FilterDialog(
                                      type: "Tags",
                                      items: quotesNot.tags,
                                      selected: quotesNot.selectedTag,
                                      onCancel: () {
                                        quotesNot.setSelectedTag(oldTag);
                                      },
                                      onPressed: (v) {
                                        quotesNot.toggleTagSelect(v);
                                      });
                                });
                              });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: GridView.builder(
                          itemCount: quotesNot.filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  mainAxisExtent: 300,
                                  maxCrossAxisExtent: 300),
                          itemBuilder: (context, index) {
                            final quote = quotesNotX.filtered[index];
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
