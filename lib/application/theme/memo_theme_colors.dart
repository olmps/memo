import 'package:flutter/material.dart';

// Constant colors that represent the respective swatches, prefixed with the theme it should be associated with.
//
// I.e.: `buildClassic...` is the prefix signature of all swatches used by the `MemoTheme.classic` theme.

//
// MemoTheme.classic
//
MaterialColor buildClassicPrimarySwatch() {
  const _primary = Color(0xFF4DBB74);
  return MaterialColor(
    _primary.value,
    const {
      50: Color(0xFFF1FFF6),
      100: Color(0xFFCAFFDD),
      200: Color(0xFFA2FFC3),
      300: Color(0xFF75F5A3),
      400: Color(0xFF60D88B),
      500: _primary,
      600: Color(0xFF2C814A),
      700: Color(0xFF1F6337),
      800: Color(0xFF134625),
      900: Color(0xFF0D301A),
    },
  );
}

MaterialColor buildClassicSecondarySwatch() {
  const _primary = Color(0xFF846BCD);
  return MaterialColor(
    _primary.value,
    const {
      50: Color(0xFFF7F4FF),
      100: Color(0xFFDFD4FF),
      200: Color(0xFFC7B3FF),
      300: Color(0xFFAF93FF),
      400: Color(0xFF9C81EA),
      500: _primary,
      600: Color(0xFF6E57B0),
      700: Color(0xFF594593),
      800: Color(0xFF453475),
      900: Color(0xFF322558),
    },
  );
}

MaterialColor buildClassicNeutralSwatch() {
  const _primaryNeutral = Color(0xFF7A748E);
  return MaterialColor(
    _primaryNeutral.value,
    const {
      50: Color(0xFFF7F7F9),
      100: Color(0xFFEDEBF6),
      200: Color(0xFFC7C3DB),
      300: Color(0xFFADA7C1),
      400: Color(0xFF7A748E),
      500: _primaryNeutral,
      600: Color(0xFF615D75),
      700: Color(0xFF4A465B),
      800: Color(0xFF343142),
      900: Color(0xFF1F1D28),
    },
  );
}
