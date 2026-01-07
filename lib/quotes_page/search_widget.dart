import 'package:flutter/material.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String hint;
  final bool canBeHidden;
  const SearchWidget(
      {super.key,
      required this.controller,
      required this.onClear,
      required this.hint,
      this.canBeHidden = false});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StyleNotifier>().appColor.withValues(alpha: 0.4);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
        // color: context.watch<StyleNotifier>().appColor.withValues(alpha: 0.2)
      ),
      child: TextField(
        cursorColor: context.watch<StyleNotifier>().appColor,
        controller: widget.controller,
        style: TextStyle(color: context.watch<StyleNotifier>().appColor),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: c),
          prefixIcon: Icon(
            Icons.search,
            color: c,
          ),
          suffixIcon: (widget.controller.text.isEmpty)
              ? null
              : IconButton(
                  icon: Icon(Icons.clear, color: c),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                  },
                ),
          // border: canBeHidden ? InputBorder.none : null,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: widget.canBeHidden ? Colors.transparent : c),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: widget.canBeHidden
                      ? Colors.transparent
                      : context.watch<StyleNotifier>().appColor,
                  width: 2),
              borderRadius: BorderRadius.circular(10)),
          hintText: widget.hint,
        ),
      ),
    );
  }
}
