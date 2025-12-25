import 'package:flutter/material.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_quote/quotes_notifier.dart';
import 'package:home_quote/quotes_page/input_dialog.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:provider/provider.dart';

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final styleNot = context.watch<StyleNotifier>();
    const dividerWidth = 2.0;
    final quotesNotX = context.read<QuotesNotifier>();
    const s = 50.0;
    return Container(
      width: 100 + dividerWidth,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: styleNot.appColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: const SizedBox(
              width: s,
              height: s,
              child: Icon(
                Icons.shuffle,
                color: Colors.white,
              ),
            ),
            onTap: () => quotesNotX.changeVisible(),
          ),
          Container(
            color: Colors.white,
            height: 20,
            width: dividerWidth,
          ),
          InkWell(
            child: const SizedBox(
              width: s,
              height: s,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              final Quote? quote = await showDialog(
                  context: context,
                  builder: (context) {
                    return const InputDialogWidget();
                  });
              if (quote != null && context.mounted) {
                quotesNotX.addQuote(quote);
              }
            },
          ),
        ],
      ),
    );
  }
}
