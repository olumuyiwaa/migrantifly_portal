import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFFFFFFFF);
const bgColor = Color.fromARGB(255, 243, 243, 243);


const defaultPadding = 16.0;

extension StringCasingExtension on String {
  String capitalizeWords() {
    return split("_")
        .map((word) =>
    word.isNotEmpty ? "${word[0].toUpperCase()}${word.substring(1)}" : "")
        .join(" ");
  }
}