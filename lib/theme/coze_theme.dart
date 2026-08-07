import 'package:flutter/material.dart';
import 'coze_colors.dart';

/// Coze Design System – spacing, radii, typography tokens
class CozeSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 24;
}

class CozeRadius {
  static const Radius sm   = Radius.circular(4);
  static const Radius md   = Radius.circular(6);
  static const Radius lg   = Radius.circular(9);
  static const Radius xl   = Radius.circular(12);
  static const Radius xxl  = Radius.circular(16);
  static const Radius pill = Radius.circular(28);
  static const Radius full = Radius.circular(1000);

  static const BorderRadius xlBorder  = BorderRadius.all(xl);
  static const BorderRadius xxlBorder = BorderRadius.all(xxl);
  static const BorderRadius pillBorder = BorderRadius.all(pill);
  static const BorderRadius fullBorder = BorderRadius.all(full);
}

class CozeFontSize {
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
}

class CozeShadow {
  static const List<BoxShadow> small = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 6),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 12),
  ];
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 12),
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 8), blurRadius: 24),
  ];
}
