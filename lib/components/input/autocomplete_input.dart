import 'package:flutter/material.dart';

class AutocompleteInput extends StatefulWidget {
  final List<String> suggestions;
  final String hintText;
  final Function(String) onSelected;
  final TextEditingController? controller;
  final bool showIcon;

  const AutocompleteInput({
    Key? key,
    required this.suggestions,
    this.hintText = 'Search',
    required this.onSelected,
    this.controller,
    this.showIcon = true,
  }) : super(key: key);

  @override
  State<AutocompleteInput> createState() => _AutocompleteInputState();
}

class _AutocompleteInputState extends State<AutocompleteInput> {
  late TextEditingController _textEditingController;
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  List<String> _filteredSuggestions = [];
  String _selectedItem = '';

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.controller ?? TextEditingController();
    _filteredSuggestions = widget.suggestions;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textEditingController.dispose();
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showDropdown = _focusNode.hasFocus;
    });
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = widget.suggestions;
      } else {
        _filteredSuggestions = widget.suggestions
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _showDropdown = true;
    });
  }

  void _selectItem(String item) {
    setState(() {
      _selectedItem = item;
      _textEditingController.text =
          ''; // Clear text immediately after selection
      _showDropdown = false;
    });
    widget.onSelected(item);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 12,
        ),
        Text(
          widget.hintText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 8,
        ),
        TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey, // Change color as needed
                width: 2, // Border width
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.blue, // Change color when focused
                width: 2,
              ),
            ),
          ),
          onChanged: _filterSuggestions,
          onTap: () {
            setState(() {
              _showDropdown = true;
            });
          },
        ),
        if (_showDropdown && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final item = _filteredSuggestions[index];
                  return ListTile(
                    title: Text(item),
                    tileColor: item == _selectedItem
                        ? Colors.yellow.withOpacity(0.2)
                        : null,
                    onTap: () => _selectItem(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
