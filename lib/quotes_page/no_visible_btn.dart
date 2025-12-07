import 'package:flutter/material.dart';
import 'package:home_quote/style_notifier.dart';
import 'package:provider/provider.dart';

class NoVisibleBtn extends StatelessWidget {
  final VoidCallback onTap;
  const NoVisibleBtn({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final styleNot = context.watch<StyleNotifier>();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: styleNot.appColor)),
        child: Column(
          children: [
            Icon(
              Icons.shuffle,
              color: styleNot.appColor,
            ),
            Text(
              "Pick a random quote from your selected list",
              style: TextStyle(
                  color: Color.lerp(styleNot.appColor, Colors.white, 0.3)),
            )
          ],
        ),
      ),
    );
  }
}
