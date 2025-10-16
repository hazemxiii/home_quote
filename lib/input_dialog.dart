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
      TextStyle btnStyle = const TextStyle(color: Colors.black);

      return AlertDialog(
        title: Text("${widget.quote == null ? "Add" : "Edit"} Quote"),
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
                      icon: const Icon(Icons.add, color: Colors.black))),
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
    return Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(900),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        onDeleted: () {
          setState(() {
            quote.tags.remove(tag);
          });
        },
        label: Text(tag));
  }

  Widget _input(
      String title, String hint, TextEditingController controller, int? lines,
      {Widget? suffix}) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                minLines: lines,
                maxLines: lines != null ? null : 1,
                cursorColor: Colors.black,
                controller: controller,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    hintText: hint,
                    hintStyle:
                        TextStyle(color: Colors.black.withValues(alpha: 0.5))),
              ),
            ),
            if (suffix != null) suffix
          ],
        )
      ],
    );
  }
}
