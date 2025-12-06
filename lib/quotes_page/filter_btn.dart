import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../style_notifier.dart';

class FilterBtn extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  const FilterBtn({super.key, required this.text, required this.onPressed});

  @override
  State<FilterBtn> createState() => _FilterBtnState();
}

class _FilterBtnState extends State<FilterBtn> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final textC =
        isHovered ? Colors.white : context.watch<StyleNotifier>().appColor;
    return InkWell(
      onTap: widget.onPressed,
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
          border: Border.all(
              color: context
                  .watch<StyleNotifier>()
                  .appColor
                  .withValues(alpha: 0.7)),
          color: isHovered
              ? context.watch<StyleNotifier>().appColor
              : Colors.white,
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
