import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_quote/quotes_page/no_visible_btn.dart';
import 'package:home_quote/style_notifier.dart';
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

  void showFilterDialog(bool isAuthor) {
    showDialog(
        context: context,
        builder: (context) {
          final oldData = {
            ...(isAuthor ? quotesNotX.selectedAuthor : quotesNotX.selectedTag)
          };
          return Consumer<QuotesNotifier>(builder: (context, quotesNot, child) {
            final data = <String>{...oldData};
            for (final quote in quotesNot.quotes) {
              if (isAuthor) {
                if ((quote.author ?? "").isNotEmpty) {
                  data.add(quote.author!);
                }
              } else {
                for (final quote in quotesNot.quotes) {
                  data.addAll(quote.tags);
                }
              }
            }
            return FilterDialog(
                type: isAuthor ? "Author" : "Tags",
                items: data.toList(),
                selected:
                    isAuthor ? quotesNot.selectedAuthor : quotesNot.selectedTag,
                onCancel: () {
                  if (isAuthor) {
                    quotesNot.setSelectedAuthor(oldData.toList());
                  } else {
                    quotesNotX.setSelectedTag(oldData.toList());
                  }
                },
                onPressed: (v) {
                  if (isAuthor) {
                    quotesNotX.toggleAuthorSelect(v);
                  } else {
                    quotesNotX.toggleTagSelect(v);
                  }
                });
          });
        });
  }

  QuotesNotifier get quotesNotX => context.read<QuotesNotifier>();
  QuotesNotifier get quotesNot => context.watch<QuotesNotifier>();

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
              backgroundColor: clrs.appColor,
              foregroundColor: Colors.white,
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
          backgroundColor: clrs.c,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: const Text("My Quotes"),
            backgroundColor: clrs.c,
            foregroundColor: clrs.appColor,
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
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChangeNotifierProvider.value(
                      value: context.read<QuotesNotifier>(),
                      child: SearchWidget(
                          canBeHidden: true,
                          controller: searchController,
                          onClear: () {
                            quotesNotX.setSearch("");
                          },
                          hint: "Search by quote")),
                  Row(
                    children: [
                      FilterBtn(
                        text: "Author",
                        onPressed: () => showFilterDialog(true),
                      ),
                      const SizedBox(width: 5),
                      FilterBtn(
                        text: "Tags",
                        onPressed: () => showFilterDialog(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (quotesNot.getVisible == null)
                    NoVisibleBtn(
                      onTap: quotesNotX.changeVisible,
                    ),
                  Expanded(
                      child: GridView.builder(
                          itemCount: quotesNot.filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  mainAxisExtent: 300,
                                  maxCrossAxisExtent: 400),
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
