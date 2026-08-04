import 'package:flutter/material.dart';

/// Design-token colors. Feature UIs should reference these rather than
/// hardcoding `Color(0x...)` values, so a rebrand is a one-file change.
abstract class AppColors {
  static const seed = Color(0xFF3D5AFE);

  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);
  static const error = Color(0xFFC62828);
}
