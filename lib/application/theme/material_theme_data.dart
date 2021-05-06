import 'package:flutter/material.dart';

/// Creates a new `ThemeData` with customized sub-themes
///
/// All arguments are used for a couple of definitions, some are more broadly used in different sub-themes (like
/// [neutralSwatch]), while others (like [iconSize]) are used for only a specific theme.
ThemeData buildThemeData({
  required MaterialColor primarySwatch,
  required MaterialColor secondarySwatch,
  required MaterialColor neutralSwatch,
  required String textThemeFontFamily,
  required Color iconColor,
  required Color textColor,
  required Color bottomNavSelectedItemColor,
  required BorderRadius roundedRectElementsRadius,
  required double minButtonHeight,
  required double iconSize,
  required EdgeInsets tabBarLabelPadding,
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
      primary: primarySwatch,
      onPrimary: textColor,
    ),
  );

  final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(primary: secondarySwatch.shade400),
  );

  final iconTheme = IconThemeData(color: iconColor, size: iconSize);

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
    unselectedItemColor: neutralSwatch.shade500,
    selectedItemColor: bottomNavSelectedItemColor,
  );

  final tabBarTheme = TabBarTheme(
    labelPadding: tabBarLabelPadding,
    labelColor: secondarySwatch.shade400,
    unselectedLabelColor: neutralSwatch.shade300,
    labelStyle: textTheme.subtitle2,
    unselectedLabelStyle: textTheme.subtitle2,
  );

  final snackBarTheme = SnackBarThemeData(
    backgroundColor: neutralSwatch.shade800,
    contentTextStyle: textTheme.bodyText2,
    actionTextColor: secondarySwatch.shade400,
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
    textButtonTheme: textButtonTheme,
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    bottomNavigationBarTheme: bottomNavTheme,
    iconTheme: iconTheme,
    snackBarTheme: snackBarTheme,
  );
}

//
// Typography
//
TextTheme _buildTextTheme(String fontFamily, {required Color textColor}) {
  return TextTheme(
    headline1: TextStyle(
      fontFamily: fontFamily,
      fontSize: 96,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline2: TextStyle(
      fontFamily: fontFamily,
      fontSize: 60,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headline3: TextStyle(
      fontFamily: fontFamily,
      fontSize: 48,
      height: 1,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    headline4: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 1.19,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline5: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 1.17,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headline6: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    subtitle1: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    subtitle2: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyText1: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w300,
      color: textColor,
    ),
    bodyText2: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 1.57,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    button: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    caption: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 1.33,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    overline: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      height: 1,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
  );
}
