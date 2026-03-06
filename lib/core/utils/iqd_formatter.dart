import 'package:intl/intl.dart';

/// Iraqi Dinar formatter — constitution VII mandates using this utility
/// for ALL monetary displays. Raw integer/string rendering of prices is PROHIBITED.
///
/// Usage:
/// ```dart
/// IqdFormatter.format(150000) // → '150,000 د.ع'
/// IqdFormatter.format(1500)   // → '1,500 د.ع'
/// ```
class IqdFormatter {
  IqdFormatter._();

  static final _fmt = NumberFormat('#,###');

  /// Formats [price] as an IQD string with the Arabic currency symbol.
  ///
  /// Example: `IqdFormatter.format(150000)` → `'150,000 د.ع'`
  static String format(num price) {
    if (price <= 0) return '0 د.ع';
    return '${_fmt.format(price.toInt())} د.ع';
  }

  /// Formats [price] as a compact IQD string for tight UI spaces.
  ///
  /// Example: `IqdFormatter.compact(1500000)` → `'1.5M د.ع'`
  static String compact(num price) {
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m.toStringAsFixed(m % 1 == 0 ? 0 : 1)}M د.ع';
    }
    if (price >= 1000) {
      final k = price / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}K د.ع';
    }
    return format(price);
  }
}
