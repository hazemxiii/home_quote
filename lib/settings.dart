import "dart:convert";
import "dart:io";
import "dart:typed_data";
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:flutter/material.dart";
import "package:home_quote/global.dart";
import "package:provider/provider.dart";
import 'package:flex_color_picker/flex_color_picker.dart' as color_p;
import 'package:file_picker/file_picker.dart';

// defines which color is being edited
enum PickerModes { main, text }

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StyleNotifier>(builder: (context, clrs, child) {
      return Scaffold(
          backgroundColor: clrs.getTextC,
          appBar: AppBar(
            foregroundColor: clrs.getColorC,
            backgroundColor: clrs.getTextC,
            title: const Text("Settings"),
            centerTitle: true,
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SwitchListTile(
                  value: clrs.isTransparent,
                  onChanged: (v) {
                    Provider.of<StyleNotifier>(context, listen: false)
                        .toggleTransparent();
                  },
                  title: Text(
                    "Transparent Background",
                    style: TextStyle(color: clrs.getColorC),
                  ),
                  tileColor: clrs.getTextC,
                  activeColor: clrs.getColorC,
                  inactiveThumbColor:
                      Color.lerp(clrs.getTextC, clrs.getColorC, .8),
                  inactiveTrackColor:
                      Color.lerp(clrs.getTextC, clrs.getColorC, .2),
                ),
                const ColorPicker(mode: PickerModes.main, text: "Widget Color"),
                const ColorPicker(mode: PickerModes.text, text: "Text Color"),
                const SizedBox(
                  height: 10,
                ),
                Consumer<QuotesNotifier>(builder: (context, qts, child) {
                  return InkWell(
                    onTap: () async {
                      await grantFilesPermession();
                      String? outputFile = await FilePicker.platform.saveFile(
                          dialogTitle:
                              'Select where you want to put your file:',
                          fileName: 'quotes.qts',
                          bytes: Uint8List(1));

                      if (outputFile == null) return;

                      File(outputFile).writeAsString(
                        "${jsonEncode(qts.getQuotes)}\n${qts.getSelected.join(",")}",
                      );
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        decoration: BoxDecoration(
                            color:
                                Color.lerp(clrs.getTextC, clrs.getColorC, .2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Icon(
                          Icons.upload,
                          color: clrs.getColorC,
                        )),
                  );
                }),
                const SizedBox(height: 5),
                InkWell(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result == null) return;

                    File file = File(result.files.single.path!);

                    if (context.mounted) {
                      Provider.of<QuotesNotifier>(context, listen: false)
                          .setDataFromFile(file);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                        color: Color.lerp(clrs.getTextC, clrs.getColorC, .2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Icon(
                      Icons.download,
                      color: clrs.getColorC,
                    ),
                  ),
                )
              ],
            ),
          ));
    });
  }
}

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
