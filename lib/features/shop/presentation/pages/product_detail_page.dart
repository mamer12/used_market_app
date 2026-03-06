import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_context.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/pages/cart_conflict_sheet.dart';
import '../../data/models/shop_models.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  /// When true (Mustamal used listing), hide "Add to Cart" and show
  /// a "تواصل مع البائع" WhatsApp/phone button instead.
  final bool isUsedListing;

  /// Seller contact phone for the WhatsApp button (international format).
  final String? sellerPhone;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.isUsedListing = false,
    this.sellerPhone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listenWhen: (prev, curr) =>
          curr.cartStatus == CartStatus.conflict &&
          prev.cartStatus != CartStatus.conflict,
      listener: (context, state) {
        CartConflictSheet.show(
          context,
          context.read<CartCubit>() as ScopedCartCubit,
        );
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(child: _buildProductInfo(context)),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surface,
      expandedHeight: 400.h,
      pinned: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            product.images.isNotEmpty
                ? Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderImage(),
                  )
                : _placeholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.surface,
                    AppTheme.surface.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
            // Balla pill badge
            if (product.isBalla)
              Positioned(
                top: 60.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'بالة — ${_unitLabel(product.salesUnit)}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 60.sp,
          color: AppTheme.inactive,
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              if (!isUsedListing) _buildSaveButton(context),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _formatPrice(product.price, product.salesUnit, product.isBalla),
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 24.h),

          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          SizedBox(height: 24.h),

          // Status badges
          Wrap(
            spacing: 8.w,
            children: [
              if (!isUsedListing)
                _buildInfoBadge(
                  icon: Icons.inventory_2_outlined,
                  label: product.inStock > 0
                      ? '${product.inStock} متوفر'
                      : 'غير متوفر',
                  color: product.inStock > 0
                      ? AppTheme.liveBadge
                      : AppTheme.inactive,
                ),
              if (product.isBalla)
                _buildInfoBadge(
                  icon: Icons.inventory_2_rounded,
                  label: 'يُباع بالـ${_unitLabel(product.salesUnit)}',
                  color: const Color(0xFF7C4DFF),
                ),
              if (isUsedListing) ...[
                _buildInfoBadge(
                  icon: Icons.autorenew_rounded,
                  label: 'مستعمل',
                  color: AppTheme.secondary,
                ),
                _buildInfoBadge(
                  icon: Icons.chat_bubble_outline,
                  label: 'تواصل للشراء',
                  color: const Color(0xFF25D366),
                ),
              ],
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            'الوصف',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            product.description ?? 'لا يوجد وصف.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isSaved = state.savedItems.any(
          (item) => item.product.id == product.id,
        );
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<CartCubit>().toggleSaved(product);
          },
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSaved
                    ? AppTheme.liveBadge
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              size: 20.sp,
              color: isSaved ? AppTheme.liveBadge : AppTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // ── Mustamal used listing: WhatsApp/Chat button ──────────────────────
    if (isUsedListing) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          16.h,
          20.w,
          MediaQuery.of(context).padding.bottom + 16.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            final phone = sellerPhone ?? '';
            final msg = Uri.encodeComponent(
              'مرحبا، رأيت إعلانك عن "${product.name}" وأريد الاستفسار.',
            );
            final waUrl = Uri.parse('https://wa.me/$phone?text=$msg');
            if (await canLaunchUrl(waUrl)) {
              await launchUrl(waUrl, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_rounded, size: 22.sp, color: Colors.white),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.whatsappChat,
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
      );
    }

    // ── Matajir / Balla: standard Add to Cart ────────────────────────────
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final inCart = state.cartItems.any(
            (item) => item.product.id == product.id,
          );

          return GestureDetector(
            onTap: () {
              if (inCart) {
                Navigator.pop(context);
                return;
              }
              HapticFeedback.mediumImpact();
              context.read<CartCubit>().addToCart(product);

              // We only show snackbar if there was no conflict.
              // Conflict is handled by BlocListener above.
              if (context.read<CartCubit>().state.cartStatus !=
                  CartStatus.conflict) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تمت الإضافة للسلة',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56.h,
              decoration: BoxDecoration(
                color: inCart ? AppTheme.background : AppTheme.primary,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: inCart ? AppTheme.primary : Colors.transparent,
                ),
                boxShadow: inCart
                    ? []
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      inCart
                          ? Icons.check_rounded
                          : Icons.shopping_cart_outlined,
                      color: inCart ? AppTheme.primary : AppTheme.textPrimary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      inCart ? 'تمت الإضافة' : 'أضف إلى السلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: inCart ? AppTheme.primary : AppTheme.textPrimary,
                      ),
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

  /// Formats IQD price with Balla unit context.
  String _formatPrice(double price, String salesUnit, bool isBalla) {
    final iqd = price.toInt();
    if (isBalla) {
      return '${_formatIqd(iqd)} / ${_unitLabel(salesUnit)}';
    }
    return _formatIqd(iqd);
  }

  String _formatIqd(int iqd) {
    if (iqd >= 1000000) {
      final m = iqd / 1000000;
      final display = m == m.truncateToDouble()
          ? m.toInt().toString()
          : m.toStringAsFixed(1);
      return '$display مليون دينار';
    }
    if (iqd >= 1000) {
      return '${(iqd ~/ 1000)} ألف دينار';
    }
    return '$iqd دينار';
  }

  String _unitLabel(String unit) {
    const labels = {'piece': 'قطعة', 'kg': 'كيلو', 'bundle': 'بندل'};
    return labels[unit] ?? unit;
  }
}
