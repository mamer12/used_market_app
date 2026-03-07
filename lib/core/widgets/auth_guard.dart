import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Wraps any widget to enforce authentication before executing an action.
///
/// **Mandatory Auth Pattern (post-lazy-auth removal):**
/// - If user is **authenticated** → executes [onAuthenticated] immediately.
/// - If user is **unauthenticated** → navigates to `/login`.
///   After successful login, the global router guard returns the user to their
///   intended destination automatically.
///
/// This widget uses [Listener] instead of [GestureDetector] / [InkWell]
/// to avoid adding Material render objects that corrupt the semantics tree
/// inside scrollable layouts like GridView and ListView.
///
/// ```dart
/// AuthGuard(
///   onAuthenticated: () {
///     context.read<AuctionBloc>().add(PlaceBidEvent(amount: 50000));
///   },
///   child: PrimaryButton(label: 'Place Bid (50,000 IQD)'),
/// )
/// ```
class AuthGuard extends StatelessWidget {
  /// The visual widget (button, card, etc.).
  final Widget child;

  /// Action to run when user is authenticated.
  final VoidCallback onAuthenticated;

  const AuthGuard({
    super.key,
    required this.child,
    required this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    // We intentionally do NOT wrap with InkWell, GestureDetector, or
    // AbsorbPointer. Instead, we use a Listener to intercept pointer-down
    // events at the hit-test level. This does NOT add any semantics or
    // material render objects to the tree, avoiding the parentDataDirty
    // assertion error in scrollable layouts.
    return Listener(
      onPointerUp: (_) => _handleTap(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void _handleTap(BuildContext context) {
    final state = context.read<AuthBloc>().state;

    if (state.isAuthenticated) {
      // ✅ Already logged in — run immediately
      onAuthenticated();
    } else {
      // 🔐 Not authenticated — redirect to login.
      // The router guard preserves context and returns user after auth.
      context.go('/login');
    }
  }
}
