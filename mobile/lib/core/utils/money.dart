import 'package:intl/intl.dart';

import '../constants/strings.dart';

/// Formats integer cents as KES with thousands separators. 1 KES = 100 cents.
String formatKes(int amountMinor) {
  final negative = amountMinor.isNegative;
  final absolute = amountMinor.abs();
  final shillings = absolute ~/ 100;
  final cents = (absolute % 100).toString().padLeft(2, '0');
  final grouped = NumberFormat('#,##0', 'en_US').format(shillings);
  final sign = negative ? '-' : '';
  return '$sign${AppStrings.currencyCode} $grouped.$cents';
}

String formatPercent(double progress) {
  final value = (progress.clamp(0, 1) * 100).round();
  return '$value${AppStrings.percentSuffix}';
}
