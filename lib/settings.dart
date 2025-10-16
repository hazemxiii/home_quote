import "dart:convert";
import "dart:io";
import "dart:typed_data";
// import 'package:path_provider/path_provider.dart';
import "package:home_quote/settings/color_palette.dart";
import "package:home_quote/settings/color_picker.dart";
import "package:flutter/material.dart";
import "package:home_quote/global.dart";
import "package:provider/provider.dart";
import 'package:file_picker/file_picker.dart';

// defines which color is being edited

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
                  activeThumbColor: clrs.getColorC,
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
                        jsonEncode(qts.getQuotes),
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
