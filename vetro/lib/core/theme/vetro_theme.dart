import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class VetroTheme {
  VetroTheme._();

  static ThemeData light(ColorScheme seedScheme) {
    return FlexThemeData.light(
      scheme: FlexScheme.custom,
      colorScheme: seedScheme,
      subThemesData: const FlexSubThemesData(
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        chipRadius: 20.0,
        cardRadius: 12.0,
        dialogRadius: 16.0,
        fabRadius: 16.0,
        navigationBarIndicatorRadius: 12.0,
        navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        bottomNavigationBarElevation: 2.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
    );
  }

  static ThemeData dark(ColorScheme seedScheme) {
    return FlexThemeData.dark(
      scheme: FlexScheme.custom,
      colorScheme: seedScheme,
      subThemesData: const FlexSubThemesData(
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        chipRadius: 20.0,
        cardRadius: 12.0,
        dialogRadius: 16.0,
        fabRadius: 16.0,
        navigationBarIndicatorRadius: 12.0,
        navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        bottomNavigationBarElevation: 2.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
    );
  }

  static ColorScheme generateColorScheme(Color seedColor, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }
}
