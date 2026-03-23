// test/unit/core/iqd_formatter_test.dart
//
// Unit tests for IqdFormatter — the mandated currency formatter.
// Every monetary display in Luqta MUST use this utility.
// These tests guard against regressions in the format contract.
import 'package:flutter_test/flutter_test.dart';

import 'package:luqta/core/utils/iqd_formatter.dart';

void main() {
  group('IqdFormatter.format', () {
    test('formats a typical Iraqi price correctly', () {
      expect(IqdFormatter.format(150_000), '150,000 د.ع');
    });

    test('formats a small price below 1000', () {
      expect(IqdFormatter.format(500), '500 د.ع');
    });

    test('formats exactly 1000', () {
      expect(IqdFormatter.format(1_000), '1,000 د.ع');
    });

    test('formats a million-Dinar price', () {
      expect(IqdFormatter.format(1_000_000), '1,000,000 د.ع');
    });

    test('returns "0 د.ع" for zero input', () {
      expect(IqdFormatter.format(0), '0 د.ع');
    });

    test('returns "0 د.ع" for negative input', () {
      expect(IqdFormatter.format(-5000), '0 د.ع');
    });

    test('accepts double values (truncates fractional part)', () {
      // IQD has no sub-unit denominations, so .5 is truncated
      expect(IqdFormatter.format(10_000.9), '10,000 د.ع');
    });

    test('includes the Arabic currency suffix د.ع', () {
      final result = IqdFormatter.format(75_000);
      expect(result, contains('د.ع'));
    });

    test('includes comma thousands separators', () {
      final result = IqdFormatter.format(1_250_000);
      expect(result, contains(','));
    });
  });

  group('IqdFormatter.compact', () {
    test('returns M suffix for values >= 1,000,000', () {
      expect(IqdFormatter.compact(1_500_000), '1.5M د.ع');
    });

    test('returns M suffix with no decimal when whole number millions', () {
      expect(IqdFormatter.compact(2_000_000), '2M د.ع');
    });

    test('returns K suffix for values >= 1,000 and < 1,000,000', () {
      expect(IqdFormatter.compact(250_000), '250K د.ع');
    });

    test('returns K with no decimal when whole number thousands', () {
      expect(IqdFormatter.compact(50_000), '50K د.ع');
    });

    test('returns K with decimal for non-round thousands', () {
      expect(IqdFormatter.compact(1_500), '1.5K د.ع');
    });

    test('delegates to format() for values < 1000', () {
      expect(IqdFormatter.compact(750), IqdFormatter.format(750));
    });

    test('returns "0 د.ع" for zero input', () {
      expect(IqdFormatter.compact(0), '0 د.ع');
    });
  });
}
