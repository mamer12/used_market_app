import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../data/models/shop_models.dart';
import '../bloc/shops_cubit.dart';
import 'shop_products_page.dart';

// ── Matajir brand constants ───────────────────────────────────────────────────
const _matajirPrimary = Color(0xFF1B4FD8);
const _matajirGreen = Color(0xFF00B37E);
const _matajirSurface = Color(0xFFFAFAFA);
const _matajirBlueSurface = Color(0xFFEBF0FE);

// ── Category data ─────────────────────────────────────────────────────────────
class _Category {
  const _Category({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
}

const _categories = <_Category>[
  _Category(label: 'إلكترونيات', icon: Icons.devices_rounded, color: Color(0xFF1B4FD8)),
  _Category(label: 'ملابس', icon: Icons.checkroom_rounded, color: Color(0xFF7C3AED)),
  _Category(label: 'منزل وديكور', icon: Icons.chair_rounded, color: Color(0xFFEA580C)),
  _Category(label: 'رياضة', icon: Icons.sports_soccer_rounded, color: Color(0xFF00B37E)),
  _Category(label: 'كتب', icon: Icons.menu_book_rounded, color: Color(0xFFE11D48)),
  _Category(label: 'ألعاب', icon: Icons.sports_esports_rounded, color: Color(0xFF0891B2)),
  _Category(label: 'مجوهرات', icon: Icons.diamond_rounded, color: Color(0xFFD97706)),
  _Category(label: 'الكل', icon: Icons.apps_rounded, color: Color(0xFF6B7280)),
];

class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  late final ShopsCubit _cubit;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 7; // "الكل" default

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ShopsCubit>()..loadShops();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: _matajirSurface,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildTrustBar()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildCategoryGrid()),
              SliverToBoxAdapter(child: _buildSectionTitle('المتاجر الموثقة')),
              _buildShopList(),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: _matajirPrimary,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سوق المتاجر',
                  style: GoogleFonts.tajawal(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'تسوق من أفضل المتاجر الموثقة في العراق',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: AppTheme.dinarGold, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'موثق',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dinarGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Trust Bar ─────────────────────────────────────────────────────────────
  Widget _buildTrustBar() {
    return Container(
      color: _matajirBlueSurface,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const _TrustPill(icon: Icons.lock_rounded, label: 'دفع آمن', color: _matajirPrimary),
          _VerticalDivider(),
          const _TrustPill(icon: Icons.verified_user_rounded, label: 'متاجر موثقة', color: _matajirGreen),
          _VerticalDivider(),
          const _TrustPill(icon: Icons.shield_rounded, label: 'أمانة لكطة', color: AppTheme.emeraldGreen),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.tajawal(fontSize: 14.sp, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'ابحث عن متجر أو منتج...',
          hintStyle: GoogleFonts.tajawal(fontSize: 14.sp, color: AppTheme.textTertiary),
          prefixIcon: Icon(Icons.search_rounded, color: _matajirPrimary, size: 22.sp),
          suffixIcon: Icon(Icons.tune_rounded, color: AppTheme.textSecondary, size: 20.sp),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            borderSide: const BorderSide(color: _matajirPrimary, width: 2),
          ),
        ),
      ),
    );
  }

  // ── Category Grid ─────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: isSelected ? cat.color : AppTheme.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    cat.label,
                    style: GoogleFonts.tajawal(
                      fontSize: 10.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? cat.color : AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: _matajirPrimary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shop List ─────────────────────────────────────────────────────────────
  Widget _buildShopList() {
    return BlocBuilder<ShopsCubit, ShopsState>(
      builder: (context, state) {
        if (state.isLoading && state.shops.isEmpty) {
          return const SliverToBoxAdapter(child: ShopsPageSkeleton());
        }
        if (state.error != null && state.shops.isEmpty) {
          return SliverToBoxAdapter(child: _buildError(state.error!));
        }
        if (state.shops.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmpty());
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.shops.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const Center(
                      child: CircularProgressIndicator(color: _matajirPrimary),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildShopCard(state.shops[index]),
                );
              },
              childCount: state.shops.length + (state.isLoading ? 1 : 0),
            ),
          ),
        );
      },
    );
  }

  // ── Shop Card ─────────────────────────────────────────────────────────────
  Widget _buildShopCard(ShopModel shop) {
    final isVerified = shop.verificationStatus == 'verified';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ShopProductsPage(shopSlug: shop.slug, shopName: shop.name),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
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
            // ── Banner / Cover ──────────────────────────────────────
            _ShopBanner(shop: shop),

            // ── Info row ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 52.w,
                    height: 52.w,
                    margin: EdgeInsetsDirectional.only(end: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isVerified ? _matajirGreen : AppTheme.divider,
                        width: isVerified ? 2 : 1,
                      ),
                      color: _matajirBlueSurface,
                    ),
                    child: shop.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: CachedNetworkImage(
                              imageUrl: shop.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, err) => _ShopInitial(shop: shop),
                            ),
                          )
                        : _ShopInitial(shop: shop),
                  ),
                  // Name + badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shop.name,
                                style: GoogleFonts.tajawal(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              SizedBox(width: 6.w),
                              Icon(Icons.verified_rounded,
                                  color: AppTheme.dinarGold, size: 18.sp),
                            ],
                          ],
                        ),
                        SizedBox(height: 4.h),
                        if (shop.description != null && shop.description!.isNotEmpty)
                          Text(
                            shop.description!,
                            style: GoogleFonts.tajawal(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            if (isVerified)
                              const _TagChip(label: 'متجر موثق ✓', color: _matajirGreen),
                            if (shop.locationCity != null)
                              _TagChip(
                                label: '📍 ${shop.locationCity}',
                                color: AppTheme.textSecondary,
                              ),
                            if (shop.shopType == 'digital')
                              const _TagChip(label: 'متجر رقمي', color: _matajirPrimary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 8.w, top: 4.h),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty / Error ─────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                color: _matajirBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_outlined, size: 32.sp, color: _matajirPrimary),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد متاجر حالياً',
              style: GoogleFonts.tajawal(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'تحقق لاحقاً للاطلاع على المتاجر الجديدة',
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48.sp, color: AppTheme.error),
            SizedBox(height: 12.h),
            Text(
              message,
              style: GoogleFonts.tajawal(fontSize: 14.sp, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: () => _cubit.loadShops(refresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: _matajirPrimary,
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shop Banner ──────────────────────────────────────────────────────────────
class _ShopBanner extends StatelessWidget {
  const _ShopBanner({required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    final bannerUrl = shop.storefrontUrl ?? shop.imageUrl;
    return Container(
      height: 90.h,
      color: _matajirBlueSurface,
      child: bannerUrl != null
          ? CachedNetworkImage(
              imageUrl: bannerUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, err) => _FallbackBanner(shop: shop),
            )
          : _FallbackBanner(shop: shop),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1B4FD8), Color(0xFF3B6FEF)],
        ),
      ),
      child: Center(
        child: Text(
          shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'م',
          style: GoogleFonts.tajawal(
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.30),
          ),
        ),
      ),
    );
  }
}

// ── Shop Initial (avatar fallback) ────────────────────────────────────────────
class _ShopInitial extends StatelessWidget {
  const _ShopInitial({required this.shop});
  final ShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'م',
        style: GoogleFonts.tajawal(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: _matajirPrimary,
        ),
      ),
    );
  }
}

// ── Trust Pill ────────────────────────────────────────────────────────────────
class _TrustPill extends StatelessWidget {
  const _TrustPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 5.w),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 16.h, color: AppTheme.divider);
  }
}

// ── Tag Chip ─────────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
