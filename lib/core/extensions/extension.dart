import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension HexColor on Color {
  static Color fromHex(String hexColorsString) {
    hexColorsString = hexColorsString.replaceAll('#', '');
    if (hexColorsString.length == 6) {
      hexColorsString = "FF$hexColorsString";
    }
    return Color(int.parse(hexColorsString, radix: 16));
  }
}


extension StringExtension on String {
  String capitalize() {
    if (this == "") {
      return this;
    } else {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
  }

  String maskNumber(int length) {
    if (this == "") {
      return this;
    } else {
      return "+${substring(0, 3)} ${substring(3, length).replaceAll(RegExp(r'.(?=.{4})'), '*')}";
    }
  }

  String emiratesNumber(int length) {
    if (this == "") {
      return this;
    } else {
      return "${substring(0, 3)}-${substring(3, 7)}-${substring(7, 14)}-${substring(14, length)}";
    }
  }



  String amountFormat(num amount) {
    final NumberFormat amountFormatter = NumberFormat('###,###,##0.00');

    if (this == "") {
      return this;
    } else {
      return amountFormatter.format(double.parse(amount.toString()));
    }
  }
}

extension DateExtension on DateTime {
  String dateFormat(DateTime date){
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(date);
  }
}
