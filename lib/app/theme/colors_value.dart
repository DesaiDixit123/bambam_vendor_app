// coverage:ignore-file
// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

/// A list of custom color used in the application.
///
/// Will be ignored for test since all are static values and would not change.
abstract class ColorsValue {
  static const Color appColor = Color(0xFFFF6600);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color appBg = Color(0xFFF6F6F6);
  static const Color redColor = Color(0xFFD80032);
  static const Color greenColor = Color(0xff18904E);
  static const Color orangeColor = Color(0xFFFF6600);

  // border colors
  static const Color borderColor = Color(0xffD8E2EF); // #D8E2EF
  static const Color fildColos = Color(0xffF9FAFD); // ##F9FAFD

  // Conatiner Colors
  static const Color yelloCB = Color(0xffFFDFAE); // ##F9FAFD
  static const Color redCB = Color(0xffFFE3E2); // ##F9FAFD
  static const Color greenCB = Color(0xffE8FAF2); // ##F9FAFD

  // Conatiner Colors
  static const Color l4 = Color(0xffF9FAFD); // ##F9FAFD
  static const Color l3 = Color(0xffEDF2F9); // ##F9FAFD
  static const Color l2 = Color(0xffD8E2EF); // ##F9FAFD
  static const Color l1 = Color(0xffD8E2EF); // ##F9FAFD

  //  textColors
  static const Color g1txtColor = Color(0xff0B1727); // #0B1727
  static const Color g5txtColor = Color(0xff5E6E82); // #0B1727
  static const Color g7txtColor = Color(0xff748194);
  static const Color g6txtColor = Color(0xff748194);
  static const Color textFieldBorder = Color(0xFFCBD5E1);
}
