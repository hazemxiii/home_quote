import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  const SearchWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = Colors.black.withValues(alpha: 0.4);
    return TextField(
      cursorColor: Colors.black,
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: c),
        prefixIcon: Icon(
          Icons.search,
          color: c,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: c),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10)),
        hintText: "Search by quote",
      ),
    );
  }
}
