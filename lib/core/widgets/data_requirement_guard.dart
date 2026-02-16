import 'package:flutter/material.dart';

/// Generic guard that checks if the user has the required data
/// before proceeding with an action.
///
/// **Progressive Profiling Pattern:**
/// Instead of collecting all info at signup, we ask for data
/// Just-In-Time when the user actually needs it.
///
/// ```dart
/// DataRequirementGuard(
///   hasRequiredData: () => user.address != null,
///   onDataMissing: (context, proceed) {
///     AddAddressSheet.show(context, onSaved: proceed);
///   },
///   onProceed: () {
///     context.read<OrderBloc>().add(ConfirmOrder());
///   },
///   child: PrimaryButton(label: 'Confirm Order'),
/// )
/// ```
class DataRequirementGuard extends StatelessWidget {
  /// The visual widget.
  final Widget child;

  /// Check if the required data already exists.
  final bool Function() hasRequiredData;

  /// Called when data is missing. The [proceed] callback should be
  /// invoked once the user provides the data (e.g., after saving
  /// their address in a modal).
  final void Function(BuildContext context, VoidCallback proceed) onDataMissing;

  /// The action to execute when all data is available.
  final VoidCallback onProceed;

  const DataRequirementGuard({
    super.key,
    required this.child,
    required this.hasRequiredData,
    required this.onDataMissing,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _handleTap(context),
      child: AbsorbPointer(child: child),
    );
  }

  void _handleTap(BuildContext context) {
    if (hasRequiredData()) {
      // ✅ All data present — proceed
      onProceed();
    } else {
      // 📝 Data missing — show collection modal with retry
      onDataMissing(context, onProceed);
    }
  }
}

/// Chains multiple requirements together.
///
/// Checks each requirement in order. If any is missing, shows the
/// corresponding modal. Only calls [onAllSatisfied] when every
/// requirement is met.
///
/// ```dart
/// ChainedRequirementGuard(
///   requirements: [
///     Requirement(
///       check: () => user.nickname != null,
///       resolve: (ctx, next) => NicknameSheet.show(ctx, onSaved: next),
///     ),
///     Requirement(
///       check: () => user.address != null,
///       resolve: (ctx, next) => AddressSheet.show(ctx, onSaved: next),
///     ),
///   ],
///   onAllSatisfied: () => placeOrder(),
///   child: PrimaryButton(label: 'Place Order'),
/// )
/// ```
class ChainedRequirementGuard extends StatelessWidget {
  final Widget child;
  final List<Requirement> requirements;
  final VoidCallback onAllSatisfied;

  const ChainedRequirementGuard({
    super.key,
    required this.child,
    required this.requirements,
    required this.onAllSatisfied,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _resolve(context, 0),
      child: AbsorbPointer(child: child),
    );
  }

  void _resolve(BuildContext context, int index) {
    if (index >= requirements.length) {
      onAllSatisfied();
      return;
    }

    final req = requirements[index];
    if (req.check()) {
      // This requirement satisfied — check next
      _resolve(context, index + 1);
    } else {
      // Missing — resolve, then continue chain
      req.resolve(context, () => _resolve(context, index + 1));
    }
  }
}

/// A single data requirement with a check and resolve strategy.
class Requirement {
  /// Returns `true` if this requirement is already satisfied.
  final bool Function() check;

  /// Called to collect the missing data. Must call [proceed]
  /// when the data has been collected.
  final void Function(BuildContext context, VoidCallback proceed) resolve;

  const Requirement({required this.check, required this.resolve});
}
