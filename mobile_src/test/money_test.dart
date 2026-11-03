import 'package:flutter_test/flutter_test.dart';
import 'package:hifadhi/core/constants/demo_config.dart';
import 'package:hifadhi/core/utils/money.dart';

void main() {
  test('formats cents as KES with thousands separators', () {
    expect(formatKes(125000), 'KES 1,250.00');
    expect(formatKes(50), 'KES 0.50');
    expect(formatKes(0), 'KES 0.00');
    expect(formatKes(-100), '-KES 1.00');
  });

  test('percent labels stay between 0 and 100', () {
    expect(formatPercent(0.64), '64%');
    expect(formatPercent(1.4), '100%');
    expect(formatPercent(-1), '0%');
  });

  test('demo mode defaults to the 72 hour withdrawal delay', () {
    expect(DemoConfig.enabled, isFalse);
    expect(DemoConfig.withdrawalDelay, const Duration(hours: 72));
  });
}
