import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import 'matajir_categories_page.dart';
import 'matajir_page.dart' show MatajirPage;

/// Matajir Mini-App Shell — owns a 3-tab bottom nav:
///   0 = Home (الرئيسية)
///   1 = Categories (المتاجر)
///   2 = Cart (السلة)
///
/// The [MatajirCartCubit] is scoped at the router [ShellRoute] level
/// (see app_router.dart), so it is accessible from all three tabs here.
class MatajirShellPage extends StatefulWidget {
  const MatajirShellPage({super.key});

  @override
  State<MatajirShellPage> createState() => _MatajirShellPageState();
}

class _MatajirShellPageState extends State<MatajirShellPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const MatajirPage(),
    const MatajirCategoriesPage(),
    const _MatajirCartTab(),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BlocBuilder<MatajirCartCubit, CartState>(
        builder: (context, cartState) {
          final cartCount = cartState.cartItems.length;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.divider,
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60.h,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: l10n.matajirNavHome,
                      isSelected: _selectedIndex == 0,
                      onTap: () => _onNavTap(0),
                    ),
                    _NavItem(
                      icon: Icons.storefront_rounded,
                      label: l10n.matajirNavStores,
                      isSelected: _selectedIndex == 1,
                      onTap: () => _onNavTap(1),
                    ),
                    _NavItem(
                      icon: Icons.shopping_cart_rounded,
                      label: l10n.matajirNavCart,
                      isSelected: _selectedIndex == 2,
                      badgeCount: cartCount,
                      onTap: () => _onNavTap(2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppTheme.matajirBlue : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.matajirBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 22.sp),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: GoogleFonts.cairo(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
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
