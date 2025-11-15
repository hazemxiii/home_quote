import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:home_quote/models/quote.dart';
import 'package:provider/provider.dart';

class InputDialogWidget extends StatefulWidget {
  final Quote? quote;
  const InputDialogWidget({super.key, this.quote});

  @override
  State<InputDialogWidget> createState() => _InputDialogWidgetState();
}

class _InputDialogWidgetState extends State<InputDialogWidget> {
  late TextEditingController _nameCont;
  late TextEditingController _authorCont;
  late TextEditingController _tagCont;
  late final Quote quote;
  @override
  void initState() {
    _nameCont = TextEditingController(text: widget.quote?.quote);
    _authorCont = TextEditingController(text: widget.quote?.author);
    _tagCont = TextEditingController();
    quote = widget.quote != null
        ? Quote.fromJson(widget.quote!.toJson())
        : Quote(
            id: DateTime.now().toString(),
            quote: '',
            selected: false,
            tags: []);
    super.initState();
  }

  @override
  void dispose() {
    _nameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      TextStyle btnStyle = TextStyle(color: clrs.appColor);

      return AlertDialog(
        title: Text("${widget.quote == null ? "Add" : "Edit"} Quote",
            style: TextStyle(color: clrs.appColor)),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        // content: TextField(
        //     cursorColor: clrs.getTextC,
        //     controller: textEditingController,
        //     style: TextStyle(color: clrs.getTextC),
        //     decoration: InputDecoration(focusedBorder: border, border: border)),
        content: SizedBox(
          width: min(MediaQuery.of(context).size.width - 50, 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              _input("Quote", "Enter quote", _nameCont, 3),
              _input("Author", "Who said it?", _authorCont, null),
              _input("Tags", "Add tags", _tagCont, null,
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          quote.tags.add(_tagCont.text);
                          _tagCont.clear();
                        });
                      },
                      icon: Icon(Icons.add, color: clrs.appColor))),
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: quote.tags.map(_tagWidget).toList(),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel", style: btnStyle)),
          TextButton(
              onPressed: () {
                // Provider.of<QuotesNotifier>(context, listen: false)
                //     .addQuote(_nameCont.text);
                quote.quote = _nameCont.text;
                quote.author = _authorCont.text;
                Navigator.of(context).pop(quote);
              },
              child: Text(
                "save",
                style: btnStyle,
              ))
        ],
      );
    });
  }

  Widget _tagWidget(String tag) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(900),
          color: context.watch<StyleNotifier>().appColor.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(color: context.watch<StyleNotifier>().appColor),
            ),
            IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    quote.tags.remove(tag);
                  });
                },
                icon: Icon(Icons.close,
                    color: context.watch<StyleNotifier>().appColor)),
          ],
        ));
  }

  Widget _input(
      String title, String hint, TextEditingController controller, int? lines,
      {Widget? suffix}) {
    final c = context.watch<StyleNotifier>().appColor;
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: context.watch<StyleNotifier>().appColor,
              fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                minLines: lines,
                maxLines: lines != null ? null : 1,
                cursorColor: c,
                controller: controller,
                style: TextStyle(color: c),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: c.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: c, width: 2),
                    ),
                    hintText: hint,
                    hintStyle: TextStyle(color: c.withValues(alpha: 0.5))),
              ),
            ),
            if (suffix != null) suffix
          ],
        )
      ],
    );
  }
}
