import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String hint;
  const SearchWidget(
      {super.key,
      required this.controller,
      required this.onClear,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StyleNotifier>().appColor.withValues(alpha: 0.4);
    return TextField(
      cursorColor: context.watch<StyleNotifier>().appColor,
      controller: controller,
      style: TextStyle(color: context.watch<StyleNotifier>().appColor),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: c),
        prefixIcon: Icon(
          Icons.search,
          color: c,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.clear, color: c),
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: c),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: context.watch<StyleNotifier>().appColor, width: 2),
            borderRadius: BorderRadius.circular(10)),
        hintText: hint,
      ),
    );
  }
}
