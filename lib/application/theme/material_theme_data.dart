import 'package:flutter/material.dart';
import 'package:layoutr/common_layout.dart';

/// Creates a new `ThemeData` with customized sub-themes
///
/// All arguments are used for a couple of definitions, some are more broadly used in different sub-themes (like
/// [neutralSwatch]), while others (like [iconSize]) are used for only a specific theme.
///
/// More specifically about the `context` argument: this is particularly needed because there are some properties that
/// depend on responsive values like [Spacing].
ThemeData buildThemeData(
  BuildContext context, {
  required MaterialColor primarySwatch,
  required MaterialColor secondarySwatch,
  required MaterialColor neutralSwatch,
  required Color iconColor,
  required Color textColor,
  required Color bottomNavSelectedItemColor,
  required double roundedRectElementsRadius,
  required double minButtonHeight,
  required double iconSize,
}) {
  final roundedBorderRadius = BorderRadius.all(Radius.circular(roundedRectElementsRadius));
  final roundedCornersShape = RoundedRectangleBorder(borderRadius: roundedBorderRadius);

  final textTheme = _buildTextTheme(textColor: textColor);
  const brightness = Brightness.dark;

  final colorScheme = ColorScheme.fromSwatch(
    brightness: brightness,
    primarySwatch: primarySwatch,
    accentColor: secondarySwatch,
  );

  // Themes
  final cardTheme = CardTheme(
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: roundedCornersShape,
  );

  final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size.fromHeight(minButtonHeight),
      shape: roundedCornersShape,
      primary: primarySwatch,
      onPrimary: textColor,
    ),
  );

  final iconTheme = IconThemeData(color: neutralSwatch, size: iconSize);

  final appBarTheme = AppBarTheme(
    elevation: 0,
    iconTheme: iconTheme,
    backgroundColor: Colors.transparent,
    titleTextStyle: textTheme.headline6,
    foregroundColor: Colors.white,
  );

  final bottomNavTheme = BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: neutralSwatch.shade800,
    selectedItemColor: bottomNavSelectedItemColor,
    unselectedItemColor: neutralSwatch.shade700,
  );

  final tabBarTheme = TabBarTheme(
    labelPadding: context.symmetricInsets(vertical: Spacing.small),
    labelColor: secondarySwatch,
    unselectedLabelColor: neutralSwatch.shade400,
    labelStyle: textTheme.subtitle2,
    unselectedLabelStyle: textTheme.subtitle2,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    accentTextTheme: textTheme,
    scaffoldBackgroundColor: neutralSwatch.shade900,
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    bottomNavigationBarTheme: bottomNavTheme,
    iconTheme: iconTheme,
  );
}

//
// Typography
//
const _primaryFontFamily = 'RobotoMono';
TextTheme _buildTextTheme({required Color textColor}) {
  return TextTheme(
    headline1: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 96,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline2: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 60,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headline3: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 48,
      height: 1,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headline4: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 32,
      height: 1.19,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline5: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 24,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline6: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    subtitle1: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    subtitle2: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 14,
      height: 1.14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyText1: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w300,
      color: textColor,
    ),
    bodyText2: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 14,
      height: 1.57,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    button: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    caption: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    overline: TextStyle(
      fontFamily: _primaryFontFamily,
      fontSize: 10,
      height: 1,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
  );
}
