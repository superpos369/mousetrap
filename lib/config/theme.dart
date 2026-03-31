import 'package:flutter/material.dart';
import '../core/constants.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.black,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.chedddarYellow,
    surface: AppColors.black,
  ),
  useMaterial3: true,
);
