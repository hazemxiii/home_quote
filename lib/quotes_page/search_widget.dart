import 'dart:math';

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
  final _node = FocusNode();
  bool isExpanded = false;

  @override
  void initState() {
    _node.addListener(() {
      if (_node.hasFocus) {
        setState(() {
          isExpanded = true;
        });
      } else {
        setState(() {
          isExpanded = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StyleNotifier>().appColor.withValues(alpha: 0.4);
    return AnimatedContainer(
      height: 50,
      duration: const Duration(milliseconds: 200),
      constraints: widget.canBeHidden
          ? BoxConstraints(
              maxHeight: 50,
              maxWidth: isExpanded
                  ? min(500, MediaQuery.of(context).size.width - 50)
                  : 50)
          : null,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
        // color: context.watch<StyleNotifier>().appColor.withValues(alpha: 0.2)
      ),
      // TODO fix search widget responsivness
      child: TextField(
        focusNode: _node,
        cursorColor: context.watch<StyleNotifier>().appColor,
        controller: widget.controller,
        style: TextStyle(color: context.watch<StyleNotifier>().appColor),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: c),
          prefixIcon: Icon(
            Icons.search,
            color: c,
          ),
          suffixIcon: (widget.controller.text.isEmpty || !isExpanded)
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
