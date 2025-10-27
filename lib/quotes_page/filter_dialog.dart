import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String type;
  final List<String> items;
  final List<String> selected;
  final Function(String v) onPressed;
  final VoidCallback onCancel;
  const FilterDialog(
      {super.key,
      required this.type,
      required this.items,
      required this.selected,
      required this.onPressed,
      required this.onCancel});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter"),
          Text("Filter by ${widget.type}",
              style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
      content: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 5,
        runSpacing: 5,
        children: widget.items.map((e) {
          return InkWell(
            onTap: () {
              widget.onPressed(e);
            },
            child: Chip(
              backgroundColor:
                  widget.selected.contains(e) ? Colors.black : Colors.white,
              label: Text(e,
                  style: TextStyle(
                      color: widget.selected.contains(e)
                          ? Colors.white
                          : Colors.black)),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
