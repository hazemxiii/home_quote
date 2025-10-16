import 'package:flutter/material.dart';
import 'package:home_quote/global.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as color_p;
import 'package:home_quote/settings/color_palette.dart';
import 'package:provider/provider.dart';

class ColorPicker extends StatefulWidget {
  final PickerModes mode;
  final String text;
  const ColorPicker({super.key, required this.mode, required this.text});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: clrs.getColorC,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("cancel",
                          style: TextStyle(color: clrs.getTextC)),
                    )
                  ],
                  content: widget.mode == PickerModes.main
                      ? ColorPalette(mode: widget.mode)
                      : color_p.ColorPicker(
                          pickersEnabled: const {
                            color_p.ColorPickerType.wheel: true,
                            color_p.ColorPickerType.accent: false,
                            color_p.ColorPickerType.primary: false
                          },
                          colorCodeHasColor: true,
                          showColorCode: true,
                          color: clrs.getTextC,
                          onColorChanged: (color) {
                            Provider.of<StyleNotifier>(context, listen: false)
                                .setTextColor(color);
                          },
                        ),
                );
              });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: clrs.getColorC!),
              color: widget.mode == PickerModes.text
                  ? clrs.getTextC
                  : clrs.getColorC),
          child: Center(
            child: Text(widget.text,
                style: TextStyle(
                    color: widget.mode == PickerModes.text
                        ? clrs.getColorC
                        : clrs.getTextC)),
          ),
        ),
      );
    });
  }
}
