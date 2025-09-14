import 'package:flutter/material.dart';

class Inputfield extends StatefulWidget {
  final String inputHintText;
  final String inputTitle;
  final bool textObscure;
  final bool isreadOnly;
  final Widget? icon;
  final Widget? prefixIcon;
  final TextEditingController textController;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool hasCheckbox;
  final Function(bool)? onCheckboxChanged;

  Inputfield({
    super.key,
    required this.inputHintText,
    required this.inputTitle,
    required this.textObscure,
    required this.textController,
    this.icon,
    this.prefixIcon,
    required this.isreadOnly,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.hasCheckbox = false,
    this.onCheckboxChanged,
  });

  @override
  State<Inputfield> createState() => _InputfieldState();
}

class _InputfieldState extends State<Inputfield> {
  bool isCheckboxTicked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              widget.hasCheckbox
                  ? Container(
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.only(right: 8),
                      child: Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        value: isCheckboxTicked,
                        onChanged: (value) {
                          setState(() {
                            isCheckboxTicked = value!;
                            if (widget.onCheckboxChanged != null) {
                              widget.onCheckboxChanged!(value);
                            }
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  : SizedBox.shrink(),
              Text(
                widget.inputTitle,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              )
            ],
          ),
          !isCheckboxTicked && widget.hasCheckbox
              ? SizedBox.shrink()
              : TextFormField(
                  cursorColor: Colors.blue,
                  readOnly: widget.isreadOnly,
                  obscureText: widget.textObscure,
                  controller: widget.textController,
                  validator: widget.validator,
                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        widget.isreadOnly ? Colors.white : Colors.grey[200],
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.icon,
                    hintText: widget.inputHintText,
                    errorMaxLines: 2,
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
                ),
        ],
      ),
    );
  }
}
