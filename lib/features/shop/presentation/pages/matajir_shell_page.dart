import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/center_fab_bottom_nav.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../widgets/following_products_tab.dart';
import 'matajir_page.dart' show MatajirPage;
import 'order_history_page.dart';

/// Matajir Mini-App Shell — 6-slot bottom nav with center FAB:
///   0 = الرئيسية  (MatajirPage — marketplace home)
///   1 = المتابَعين (FollowingProductsTab — products from followed shops)
///   [FAB] = أضف منتج (add product)
///   3 = السلة    (CartPage — cart with badge)
///   4 = حسابي    (OrderHistoryPage — account/orders)
class MatajirShellPage extends StatefulWidget {
  const MatajirShellPage({super.key});

  @override
  State<MatajirShellPage> createState() => _MatajirShellPageState();
}

class _MatajirShellPageState extends State<MatajirShellPage> {
  int _selectedIndex = 0;

  late final Map<int, Widget> _pageMap = {
    0: const MatajirPage(),
    1: const FollowingProductsTab(),
    3: const _MatajirCartTab(),
    4: const OrderHistoryPage(),
  };

  void _onNavTap(int index) {
    if (index == 2) return; // FAB
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pageMap[_selectedIndex] ?? _pageMap[0]!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: currentPage,
      bottomNavigationBar: BlocBuilder<MatajirCartCubit, CartState>(
        builder: (context, cartState) {
          final cartCount = cartState.cartItems.length;
          return CenterFabBottomNav(
            items: const [
              NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
              NavItem(icon: Icons.favorite_rounded, label: 'المتابَعين'),
              NavItem(icon: Icons.shopping_cart_rounded, label: 'السلة'),
              NavItem(icon: Icons.person_rounded, label: 'حسابي'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            fabIcon: Icons.add_rounded,
            fabColor: AppTheme.matajirBlue,
            fabLabel: 'أضف منتج',
            onFabTap: () => context.push('/matajir/add-product'),
            darkMode: false,
            badgeIndexInItems: 2,
            badgeCount: cartCount,
          );
        },
      ),
    );
  }
}

/// Cart tab — delegates directly to the shared CartPage using
/// the MatajirCartCubit scoped at the ShellRoute level.
class _MatajirCartTab extends StatelessWidget {
  const _MatajirCartTab();

  @override
  Widget build(BuildContext context) {
    return CartPage(cartCubit: context.read<MatajirCartCubit>());
  }
}
