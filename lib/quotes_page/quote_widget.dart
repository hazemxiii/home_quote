import 'package:flutter/material.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:home_quote/quotes_page/input_dialog.dart';
import 'package:home_quote/models/quote.dart';
import 'package:home_quote/quotes_notifier.dart';
import 'package:provider/provider.dart';

class QuoteWidget extends StatefulWidget {
  final Quote quote;
  final bool isDisplay;
  const QuoteWidget({super.key, required this.quote, this.isDisplay = false});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  QuotesNotifier get quotesNot => context.watch<QuotesNotifier>();
  QuotesNotifier get quotesNotX => context.read<QuotesNotifier>();

  Future<bool?> _confirmDelete() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Text("Delete \"${widget.quote.quote}\"",
                style:
                    TextStyle(color: context.watch<StyleNotifier>().appColor)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Delete",
                      style: TextStyle(
                          color: context.watch<StyleNotifier>().appColor)))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return Material(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            quotesNotX.selectQuote(widget.quote);
          },
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              // margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                // gradient: quotesNot.getVisible == widget.quote
                //     ? RadialGradient(
                //         colors: List.generate(
                //             (10),
                //             (i) => clrs.appColor
                //                 .withValues(alpha: (i + 1) * 0.04)),
                //         center: AlignmentGeometry.topRight)
                //     : null,
                boxShadow: [
                  BoxShadow(
                    color: clrs.appColor.withValues(alpha: 0.1),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(1, 3),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: quotesNot.getVisible == widget.quote
                    ? clrs.appColor.withValues(alpha: 0.2)
                    : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: !widget.isDisplay
                        ? [
                            Checkbox(
                                shape: const CircleBorder(),
                                checkColor: Colors.white,
                                activeColor: clrs.appColor,
                                value: widget.quote.selected,
                                onChanged: (v) {
                                  context
                                      .read<QuotesNotifier>()
                                      .selectQuote(widget.quote);
                                })
                          ]
                        : [Icon(Icons.shuffle_outlined, color: clrs.appColor)],
                  ),
                  Text(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    '"${widget.quote.quote}"',
                    style: TextStyle(
                        color: clrs.appColor,
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
                  ),
                  if ((widget.quote.author?.isNotEmpty) ?? false) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      '—${widget.quote.author!}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  ],
                  const SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.quote.tags.map(_tagWidget).toList(),
                    ),
                  ),
                  _options(),
                ],
              )),
        ),
      );
    });
  }

  Widget _tagWidget(String tag) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        color: context.watch<StyleNotifier>().appColor.withValues(alpha: 0.2),
      ),
      child: Text(tag,
          style: TextStyle(color: context.watch<StyleNotifier>().appColor)),
    );
  }

  Widget _options() {
    return Wrap(
      children: [
        IconButton(
            onPressed: () async {
              final Quote? q = await showDialog(
                  context: context,
                  builder: (context) {
                    return InputDialogWidget(quote: widget.quote);
                  });
              if (q != null && mounted) {
                Provider.of<QuotesNotifier>(context, listen: false)
                    .editQuote(widget.quote, q);
              }
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: context.watch<StyleNotifier>().appColor,
                ),
                Text(
                  "Edit",
                  style:
                      TextStyle(color: context.watch<StyleNotifier>().appColor),
                )
              ],
            )),
        IconButton(
            onPressed: () async {
              bool? confirm = await _confirmDelete();
              if (confirm == true && mounted) {
                Provider.of<QuotesNotifier>(context, listen: false)
                    .deleteQuote(widget.quote);
              }
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                Text(
                  "Delete",
                  style:
                      TextStyle(color: context.watch<StyleNotifier>().appColor),
                )
              ],
            ))
      ],
    );
  }
}
