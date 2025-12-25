import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:home_quote/quotes_page/search_widget.dart';
import 'package:provider/provider.dart';

class FilterDialog extends StatefulWidget {
  final String type;
  final List<String> items;
  final List<String> selected;
  final Function(String v) onPressed;
  final VoidCallback onCancel;
  const FilterDialog(
      {super.key,
      required this.type,
      required this.items,
      required this.selected,
      required this.onPressed,
      required this.onCancel});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController controller = TextEditingController();
  Timer? timer;
  @override
  void initState() {
    super.initState();
    controller.addListener(onSearchQueryChange);
  }

  void onSearchQueryChange() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Filter",
              style: TextStyle(
                  color: context.watch<StyleNotifier>().appColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text("Filter by ${widget.type}",
              style: TextStyle(
                  color: context.watch<StyleNotifier>().appColor,
                  fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            SearchWidget(
                controller: controller,
                onClear: () {},
                hint: "Search ${widget.type}"),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: widget.items.map((e) {
                if (controller.text.isNotEmpty &&
                    partialRatio(controller.text, e) < 60) {
                  return const SizedBox.shrink();
                }
                return InkWell(
                  onTap: () {
                    widget.onPressed(e);
                  },
                  child: Chip(
                    backgroundColor: widget.selected.contains(e)
                        ? context.watch<StyleNotifier>().appColor
                        : Colors.white,
                    label: Text(e,
                        style: TextStyle(
                            color: widget.selected.contains(e)
                                ? Colors.white
                                : context.watch<StyleNotifier>().appColor)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: Text("Cancel",
              style: TextStyle(color: context.watch<StyleNotifier>().appColor)),
        ),
      ],
    );
  }
}
