import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:provider/provider.dart';

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
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      TextStyle btnStyle = const TextStyle(color: Colors.black);

      return AlertDialog(
        title: const Text("Add Quote"),
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
            spacing: 15,
            children: [
              _input("Quote", "Enter quote", textEditingController, 3),
              _input("Author", "Who said it?", textEditingController, null),
              _input("Tags", "Add tags", textEditingController, null),
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
                Provider.of<QuotesNotifier>(context, listen: false)
                    .addQuote(textEditingController.text);

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

  Widget _input(
      String title, String hint, TextEditingController controller, int? lines) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        TextField(
          minLines: lines,
          maxLines: lines != null ? null : 1,
          cursorColor: Colors.black,
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide:
                    BorderSide(color: Colors.black.withValues(alpha: 0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5))),
        )
      ],
    );
  }
}
