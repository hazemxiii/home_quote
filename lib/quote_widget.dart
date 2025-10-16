import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:home_quote/models/quote.dart';
import 'package:provider/provider.dart';

class QuoteWidget extends StatefulWidget {
  final Quote quote;
  final bool isDisplay;
  const QuoteWidget({super.key, required this.quote, this.isDisplay = false});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  late TextEditingController editController;
  @override
  void initState() {
    editController = TextEditingController(text: widget.quote.quote);
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
              .selectQuote(widget.quote);
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
                              .editQuote(widget.quote, editController.text);
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
          key: Key(widget.quote.id),
          onDismissed: (direction) {
            Provider.of<QuotesNotifier>(context, listen: false)
                .deleteQuote(widget.quote);
          },
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              // margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
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
                                activeColor: Colors.black,
                                value: widget.quote.selected,
                                onChanged: (v) {
                                  context
                                      .read<QuotesNotifier>()
                                      .selectQuote(widget.quote);
                                })
                          ]
                        : [
                            const Icon(Icons.shuffle_outlined,
                                color: Colors.black)
                          ],
                  ),
                  Text(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    '"${widget.quote.quote}"',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
                  ),
                  if ((widget.quote.author?.isNotEmpty) ?? false) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      '—${widget.quote.author!}',
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        color: Colors.black,
      ),
      child: Text(tag, style: const TextStyle(color: Colors.white)),
    );
  }
}
