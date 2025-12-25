import 'package:flutter/material.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:provider/provider.dart';

class ExpandFilterBtn extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  const ExpandFilterBtn(
      {super.key, required this.isExpanded, required this.onTap});

  @override
  State<ExpandFilterBtn> createState() => _ExpandFilterBtnState();
}

class _ExpandFilterBtnState extends State<ExpandFilterBtn> {
  StyleNotifier get styleNot => context.watch<StyleNotifier>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: 0.6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                color: styleNot.appColor,
              ),
              Text(
                "Filters",
                style: TextStyle(color: styleNot.appColor),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 2,
                  ),
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: styleNot.appColor,
                      size: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
