import 'package:flutter/material.dart';

/// Creates a new `ThemeData` with customized flutter themes.
ThemeData buildThemeData({
  required MaterialColor primarySwatch,
  required MaterialColor secondarySwatch,
  required MaterialColor neutralSwatch,
  required MaterialColor destructiveSwatch,
  required String textThemeFontFamily,
  required Color iconColor,
  required Color textColor,
  required Color bottomNavSelectedItemColor,
  required BorderRadius roundedRectElementsRadius,
  required double minButtonHeight,
  required double iconSize,
  required EdgeInsets tabBarLabelPadding,
  required EdgeInsets textFieldPadding,
}) {
  final roundedCornersShape = RoundedRectangleBorder(borderRadius: roundedRectElementsRadius);

  final textTheme = _buildTextTheme(textThemeFontFamily, textColor: textColor);
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
      backgroundColor: primarySwatch,
      foregroundColor: textColor,
    ),
  );

  final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: secondarySwatch.shade400),
  );

  final iconTheme = IconThemeData(color: iconColor, size: iconSize);

  final appBarTheme = AppBarTheme(
    elevation: 0,
    iconTheme: iconTheme,
    backgroundColor: Colors.transparent,
    titleTextStyle: textTheme.titleMedium,
    foregroundColor: Colors.white,
  );

  final bottomNavTheme = BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: neutralSwatch.shade800,
    unselectedItemColor: neutralSwatch.shade500,
    selectedItemColor: bottomNavSelectedItemColor,
  );

  final tabBarTheme = TabBarTheme(
    labelPadding: tabBarLabelPadding,
    labelColor: secondarySwatch.shade400,
    unselectedLabelColor: neutralSwatch.shade300,
    labelStyle: textTheme.titleSmall,
    unselectedLabelStyle: textTheme.titleSmall,
  );

  final snackBarTheme = SnackBarThemeData(
    backgroundColor: neutralSwatch.shade800,
    contentTextStyle: textTheme.bodyMedium,
    actionTextColor: secondarySwatch.shade400,
  );

  final bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: neutralSwatch.shade900,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: roundedRectElementsRadius),
  );

  final inputTheme = InputDecorationTheme(
    fillColor: neutralSwatch.shade800,
    filled: true,
    contentPadding: textFieldPadding,
    border: UnderlineInputBorder(
      borderRadius: roundedRectElementsRadius,
      borderSide: BorderSide.none,
    ),
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: neutralSwatch.shade900,
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    textButtonTheme: textButtonTheme,
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    bottomNavigationBarTheme: bottomNavTheme,
    iconTheme: iconTheme,
    snackBarTheme: snackBarTheme,
    bottomSheetTheme: bottomSheetTheme,
    inputDecorationTheme: inputTheme,
  );
}

//
// Typography
//
TextTheme _buildTextTheme(String fontFamily, {required Color textColor}) {
  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 96,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 60,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 48,
      height: 1,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 1.19,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w300,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.57,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      height: 1,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
  );
}
