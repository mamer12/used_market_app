import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_guard.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/presentation/pages/checkout_page.dart';
import '../bloc/cart_cubit.dart';

// IQD formatter
String _iqd(num v) => '${NumberFormat("#,###", "en_US").format(v.toInt())} د.ع';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(state),
                _buildPillTabs(state),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _CartTab(items: state.cartItems, total: state.cartTotal),
                      _SavedTab(items: state.savedProducts),
                      const _BidsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(CartState state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activityTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  l10n.activitySummary(state.cartCount, state.savedCount),
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (state.cartItems.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CartCubit>().clearCart();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  l10n.cartClear,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Pill Tab Bar ──────────────────────────────────────────────────────────
  Widget _buildPillTabs(CartState state) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _PillTab(
              label: l10n.activityOrders,
              count: state.cartCount,
              isActive: _tabs.index == 0,
              onTap: () {
                HapticFeedback.selectionClick();
                _tabs.animateTo(0);
              },
            ),
            _PillTab(
              label: l10n.activitySaved,
              count: state.savedCount,
              isActive: _tabs.index == 1,
              onTap: () {
                HapticFeedback.selectionClick();
                _tabs.animateTo(1);
              },
            ),
            _PillTab(
              label: l10n.activityBids,
              count: 0,
              activeColor: const Color(0xFF1A1A1A),
              activeLabelColor: AppTheme.primary,
              isActive: _tabs.index == 2,
              onTap: () {
                HapticFeedback.selectionClick();
                _tabs.animateTo(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pill Tab Item ─────────────────────────────────────────────────────────
class _PillTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;
  final Color? activeLabelColor;

  const _PillTab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.activeColor,
    this.activeLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? AppTheme.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? (activeLabelColor ?? AppTheme.textPrimary)
                      : AppTheme.textSecondary,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (activeLabelColor?.withValues(alpha: 0.18) ??
                              AppTheme.textPrimary.withValues(alpha: 0.12))
                        : AppTheme.inactive.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? (activeLabelColor ?? AppTheme.textPrimary)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CART TAB
// ═══════════════════════════════════════════════════════════════
class _CartTab extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const _CartTab({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCart();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _CartItemCard(item: items[index]),
          ),
        ),
        _CheckoutBar(total: total, items: items),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        cubit.removeFromCart(item.product.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.error, size: 26.sp),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Product image ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: SizedBox(
                width: 86.w,
                height: 86.h,
                child: item.product.images.isNotEmpty
                    ? Image.network(
                        item.product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _imagePlaceholder(AppTheme.surface),
                      )
                    : _imagePlaceholder(AppTheme.surface),
              ),
            ),
            SizedBox(width: 12.w),
            // ── Info ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _iqd(item.product.price * item.quantity),
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (item.quantity > 1)
                      Text(
                        '${_iqd(item.product.price)} للقطعة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // ── Quantity stepper ───────────────────────
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: _QuantityStepper(
                quantity: item.quantity,
                onDecrease: () {
                  HapticFeedback.selectionClick();
                  cubit.updateQuantity(item.product.id, item.quantity - 1);
                },
                onIncrease: () {
                  HapticFeedback.selectionClick();
                  cubit.updateQuantity(item.product.id, item.quantity + 1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: quantity <= 1 ? Icons.delete_outline : Icons.remove,
            color: quantity <= 1 ? AppTheme.error : AppTheme.textPrimary,
            onTap: onDecrease,
          ),
          SizedBox(
            width: 28.w,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    this.color = AppTheme.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(icon, size: 16.sp, color: color),
      ),
    );
  }
}

// Checkout sticky bar
class _CheckoutBar extends StatelessWidget {
  final double total;
  final List<CartItem> items;

  const _CheckoutBar({required this.total, required this.items});

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        14.h,
        20.w,
        (safeBottom + 90).h, // enough space above glass nav bar
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).totalLabel,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                _iqd(total),
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AuthGuard(
            onAuthenticated: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    products: items.map((e) => e.product).toList(),
                  ),
                ),
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 20.sp,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        AppLocalizations.of(context).checkoutBtn,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SAVED TAB
// ═══════════════════════════════════════════════════════════════
class _SavedTab extends StatelessWidget {
  final List<ProductModel> items;

  const _SavedTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptySaved();

    final safeBottom = MediaQuery.of(context).padding.bottom;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, (safeBottom + 96).h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _SavedProductCard(product: items[index]),
    );
  }
}

class _SavedProductCard extends StatelessWidget {
  final ProductModel product;

  const _SavedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _imagePlaceholder(AppTheme.surface),
                      )
                    : _imagePlaceholder(AppTheme.surface),
                // Unsave button
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cubit.toggleSaved(product);
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 16.sp,
                        color: AppTheme.liveBadge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(9.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _iqd(product.price),
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          cubit.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).addedToCart,
                                style: GoogleFonts.cairo(),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 16.sp,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATES
// ═══════════════════════════════════════════════════════════════
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _EmptyState(
      icon: Icons.shopping_bag_outlined,
      title: l10n.cartEmpty,
      subtitle: l10n.cartEmptySub,
      iconColor: AppTheme.primary,
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _EmptyState(
      icon: Icons.favorite_border,
      title: l10n.savedEmpty,
      subtitle: l10n.savedEmptySub,
      iconColor: AppTheme.liveBadge,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36.sp, color: iconColor),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BIDS TAB
// ═══════════════════════════════════════════════════════════════
class _BidsTab extends StatelessWidget {
  const _BidsTab();

  @override
  Widget build(BuildContext context) {
    // Placeholder until AuctionCubit exposes active user bids
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      child: Column(
        children: [
          // Info banner
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 22.sp,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).bidsTrackTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).bidsTrackSub,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Icon(Icons.inbox_rounded, size: 56.sp, color: AppTheme.inactive),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).bidsEmpty,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            AppLocalizations.of(context).bidsEmptySub,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 28.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gavel_rounded,
                  size: 18.sp,
                  color: AppTheme.textPrimary,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).browseBids,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _imagePlaceholder(Color bg) {
  return Container(
    color: bg,
    child: const Icon(Icons.image_outlined, color: AppTheme.inactive, size: 28),
  );
}
