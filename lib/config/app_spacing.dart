import 'package:flutter/material.dart';

class AppSpacing {
  static double widthFactor(BuildContext context, double factor) =>
      MediaQuery.of(context).size.width * factor;

  static double heightFactor(BuildContext context, double factor) =>
      MediaQuery.of(context).size.height * factor;

  static EdgeInsets horizontal(BuildContext context, {double factor = 0.05}) =>
      EdgeInsets.symmetric(horizontal: widthFactor(context, factor));

  static EdgeInsets vertical(BuildContext context, {double factor = 0.02}) =>
      EdgeInsets.symmetric(vertical: heightFactor(context, factor));

  static SizedBox small(BuildContext context) => SizedBox(height: heightFactor(context, 0.01));

  static SizedBox medium(BuildContext context) => SizedBox(height: heightFactor(context, 0.02));
}
