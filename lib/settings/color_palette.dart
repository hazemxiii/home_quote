import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:home_quote/global.dart';

enum PickerModes { main, text }

class ColorPalette extends StatefulWidget {
  final PickerModes mode;
  const ColorPalette({super.key, required this.mode});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  // the colors supported by the app
  List colors = [
    [0, 0, 0],
    [255, 255, 255],
    [200, 200, 200],
    [50, 50, 50],
    [200, 0, 0],
    [0, 200, 0],
    [0, 0, 200],
    [200, 200, 0],
    [0, 200, 200],
    [200, 0, 200],
    [100, 100, 100],
    [150, 150, 150],
    [100, 0, 0],
    [100, 100, 0],
    [0, 100, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width - 50,
      child: GridView.builder(
          itemCount: colors.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 50),
          itemBuilder: (context, i) {
            List c = colors[i];
            Color color = Color.fromRGBO(c[0], c[1], c[2], 1);
            return Consumer<StyleNotifier>(builder: (context, clrs, child) {
              Color? active;
              if (widget.mode == PickerModes.text) {
                active = clrs.getTextC;
              } else {
                active = clrs.getColorC;
              }
              return InkWell(
                onTap: () {
                  if (widget.mode == PickerModes.text) {
                    Provider.of<StyleNotifier>(context, listen: false)
                        .setTextColor(color);
                  } else {
                    Provider.of<StyleNotifier>(context, listen: false)
                        .setColor(color);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(999)),
                      border: Border.all(color: clrs.getTextC),
                      color: color),
                  child: active == color
                      ? Icon(
                          Icons.check,
                          color: Color.lerp(Colors.black, color, 0.5),
                        )
                      : null,
                ),
              );
            });
          }),
    );
  }
}

Future<bool> grantFilesPermession() async {
  var manage = Permission.storage;
  await manage.request();

  return Future.value(true);
}
