import "package:flutter/material.dart";
import "package:home_quote/global.dart";
import "package:provider/provider.dart";

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
                  content: ColorPalette(mode: widget.mode),
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
