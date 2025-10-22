import 'package:flutter/material.dart';

class FilterBtn extends StatefulWidget {
  final String text;
  const FilterBtn({super.key, required this.text});

  @override
  State<FilterBtn> createState() => _FilterBtnState();
}

class _FilterBtnState extends State<FilterBtn> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final textC = isHovered ? Colors.white : Colors.black;
    return InkWell(
      onTap: () {},
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isHovered ? Colors.black : Colors.white,
        ),
        child: Row(
          spacing: 5,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              color: textC,
            ),
            Text(
              widget.text,
              style: TextStyle(color: textC),
            ),
          ],
        ),
      ),
    );
  }
}
