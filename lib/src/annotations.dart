import 'package:flutter/material.dart';

class ThemePalette {
  const ThemePalette({
    required this.brightness,
    this.fromSeed
  });
  
  final Brightness brightness;
  final Color? fromSeed;
}
