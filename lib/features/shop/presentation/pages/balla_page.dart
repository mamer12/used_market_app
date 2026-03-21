import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/center_fab_bottom_nav.dart';
import '../../../../core/widgets/promoted_carousel.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/balla_cart_cubit.dart';
import '../../../cart/presentation/pages/cart_conflict_sheet.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

class BallaPage extends StatefulWidget {
  const BallaPage({super.key});

  @override
  State<BallaPage> createState() => _BallaPageState();
}

class _BallaPageState extends State<BallaPage> {
  late final HomeCubit _cubit;
  late final CategoryCubit _categoryCubit;
  int _selectedUnit = 0; // 0=بالكيلو, 1=بالقطعة, 2=بالحزمة

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
    _categoryCubit = getIt<CategoryCubit>(param1: 'balla')..fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _categoryCubit),
      ],
      child: BlocListener<BallaCartCubit, CartState>(
        listenWhen: (prev, curr) =>
            curr.cartStatus == CartStatus.conflict &&
            prev.cartStatus != CartStatus.conflict,
        listener: (context, state) {
          CartConflictSheet.show(context, context.read<BallaCartCubit>());
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F0FF),
          bottomNavigationBar: BlocBuilder<BallaCartCubit, CartState>(
            builder: (context, cartState) {
              return CenterFabBottomNav(
                items: const [
                  NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
                  NavItem(icon: Icons.category_rounded, label: 'الأقسام'),
                  NavItem(icon: Icons.shopping_bag_rounded, label: 'السلة'),
                  NavItem(icon: Icons.person_rounded, label: 'حسابي'),
                ],
                currentIndex: 0,
                onTap: (_) {},
                fabIcon: Icons.add_rounded,
                fabColor: AppTheme.ballaPurple,
                fabLabel: 'أضف بالة',
                onFabTap: () => context.push('/balla/create'),
                darkMode: false,
                badgeIndexInItems: 2,
                badgeCount: cartState.cartItems.length,
              );
            },
          ),
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: PromotedCarousel(
                    primaryColor: AppTheme.ballaPurple,
                    items: const [
                      PromotedItem(
                        badge: 'عروض حصرية',
                        title: 'وفّر حتى ٤٠٪ على بالات الجملة',
                        price: 'تسوّق الآن',
                      ),
                      PromotedItem(
                        badge: 'جديد',
                        title: 'بالات ملابس مستوردة',
                        subtitle: 'جودة عالية بأسعار الجملة',
                      ),
                      PromotedItem(
                        badge: 'الأكثر مبيعاً',
                        title: 'بالات إلكترونيات',
                        subtitle: 'هواتف وأجهزة بكميات كبيرة',
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildUnitToggle()),
              SliverToBoxAdapter(child: _buildCategoriesGrid()),
              SliverToBoxAdapter(child: _buildSectionHeader('أكثر الصفقات رواجاً', 'عرض الكل')),
              SliverToBoxAdapter(child: _buildTrendingDeals()),
              SliverToBoxAdapter(child: _buildSectionHeader('عروض البالة', 'عرض الكل')),
              _buildProductsList(),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF5F0FF),
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            // Back to home
            _AppBarBtn(
              icon: Icons.home_rounded,
              onTap: () => context.go('/'),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'سوق البالة',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            _AppBarBtn(
              icon: Icons.filter_list_rounded,
              onTap: () {},
            ),
            SizedBox(width: 8.w),
            BlocBuilder<BallaCartCubit, CartState>(
              builder: (ctx, cartState) => Stack(
                clipBehavior: Clip.none,
                children: [
                  _AppBarBtn(
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => context.push('/balla/cart'),
                  ),
                  if (cartState.cartCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: const BoxDecoration(
                          color: AppTheme.ballaPurple,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${cartState.cartCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ballaPurple.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'البحث عن بالات، شحنات، أو مخازن...',
            hintStyle: GoogleFonts.cairo(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.ballaPurple,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    final units = ['بالكيلو', 'بالقطعة', 'بالحزمة'];
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: List.generate(units.length, (i) {
            final selected = _selectedUnit == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedUnit = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.ballaPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    units[i],
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأقسام',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ballaPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              return state.map(
                initial: (_) => const CategoryChipsSkeleton(),
                loading: (_) => const CategoryChipsSkeleton(),
                error: (e) => Center(child: Text(e.message)),
                loaded: (loaded) {
                  final cats = loaded.categories.take(6).toList();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      return GestureDetector(
                        onTap: () => context.read<CategoryCubit>().drillDown(cat.id),
                        child: _CategoryCell(
                          label: cat.nameAr,
                          count: 0,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            action,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.ballaPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingDeals() {
    final deals = [
      _TrendingDeal(label: 'ملابس شتوية', subtitle: 'نخب أول', price: 45000),
      _TrendingDeal(label: 'أحذية جلدية', subtitle: 'استيراد أوروبي', price: 62000),
      _TrendingDeal(label: 'ملابس أطفال', subtitle: 'مختلطة', price: 28000),
    ];

    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        separatorBuilder: (ctx, i) => SizedBox(width: 12.w),
        itemBuilder: (context, index) => _TrendingCard(deal: deals[index]),
      ),
    );
  }

  Widget _buildProductsList() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading && state.portal.balla.isEmpty) {
          return const BallaListSkeleton();
        }

        final items = state.portal.balla;
        if (items.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'لا يوجد عروض حصرية حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: AppTheme.inactive,
                  ),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return _BulkItemCard(item: items[index]);
            },
          ),
        );
      },
    );
  }
}

// ── App Bar Button ─────────────────────────────────────────────────
class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.15)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.textPrimary, size: 20.sp),
      ),
    );
  }
}

// ── Category Cell ──────────────────────────────────────────────────
class _CategoryCell extends StatelessWidget {
  final String label;
  final int count;

  const _CategoryCell({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppTheme.ballaPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_rounded,
              color: AppTheme.ballaPurple,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (count > 0)
            Text(
              '$count منتج',
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Trending Deal model & card ─────────────────────────────────────
class _TrendingDeal {
  final String label;
  final String subtitle;
  final int price;
  _TrendingDeal({required this.label, required this.subtitle, required this.price});
}

class _TrendingCard extends StatelessWidget {
  final _TrendingDeal deal;
  const _TrendingCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ballaPurple.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100.h,
            color: AppTheme.ballaPurple.withValues(alpha: 0.08),
            child: Center(
              child: Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.ballaPurple,
                size: 40.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  deal.subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format(deal.price),
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ballaPurple,
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

// ── Bulk Item Card ─────────────────────────────────────────────────
class _BulkItemCard extends StatelessWidget {
  final dynamic item;
  const _BulkItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/balla/product', extra: item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            SizedBox(
              height: 180.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppTheme.ballaPurple.withValues(alpha: 0.06),
                      ),
                    )
                  else
                    Container(color: AppTheme.ballaPurple.withValues(alpha: 0.06)),
                  // Grade badge
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Text(
                        'نخب أول',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Text(
                        '🇪🇺 استيراد',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12.sp, color: AppTheme.textSecondary),
                      SizedBox(width: 2.w),
                      Text(
                        'البصرة، العراق',
                        style: GoogleFonts.cairo(fontSize: 11.sp, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سعر الكيلو',
                            style: GoogleFonts.cairo(fontSize: 11.sp, color: AppTheme.textSecondary),
                          ),
                          Text(
                            IqdFormatter.format(item.price),
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ballaPurple,
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<BallaCartCubit, CartState>(
                        builder: (ctx, cartState) {
                          final inCart = cartState.isInCart(item.id);
                          return GestureDetector(
                            onTap: () => ctx.read<BallaCartCubit>().addToCart(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: inCart ? AppTheme.ballaPurpleSurface : AppTheme.ballaPurple,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                inCart ? 'في السلة ✓' : 'أضف للسلة',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: inCart ? AppTheme.ballaPurple : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
