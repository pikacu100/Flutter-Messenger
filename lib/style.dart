import 'package:flutter/material.dart';

class FontStyles {
  
  TextStyle appBarStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.grey.shade900,
    );
  }
}
