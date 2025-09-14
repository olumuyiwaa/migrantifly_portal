import 'package:flutter/material.dart';

class InputDropDown extends StatefulWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const InputDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<InputDropDown> createState() => _InputDropDownState();
}

class _InputDropDownState extends State<InputDropDown> {
  bool isCheckboxTicked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 100),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
