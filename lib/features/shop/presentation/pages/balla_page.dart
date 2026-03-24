import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/center_fab_bottom_nav.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/balla_cart_cubit.dart';
import '../../../cart/presentation/widgets/cart_conflict_sheet.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

// ── Constants ──────────────────────────────────────────────────────
const _kBg           = Color(0xFFF5F0FF);
const _kPurple       = AppTheme.ballaPurple;       // 0xFF7C3AED
const _kPurpleSurf   = AppTheme.ballaPurpleSurface; // 0xFFEDE7F6
const _kBorder       = Color(0xFFD2BBFF);
const _kGold         = Color(0xFFFFB800);
const _kText         = Color(0xFF201B16);

// ── Mock balla data ────────────────────────────────────────────────
class _BallaItem {
  final String id;
  final String name;
  final String shop;
  final double stars;
  final int weightKg;
  final int totalPrice;
  final String category;
  final bool isFeatured;

  const _BallaItem({
    required this.id,
    required this.name,
    required this.shop,
    required this.stars,
    required this.weightKg,
    required this.totalPrice,
    required this.category,
    this.isFeatured = false,
  });

  int get pricePerKg    => (totalPrice / weightKg).round();
  int get pricePerPiece => (totalPrice / (weightKg * 4)).round();
  int get pricePerBundle => (totalPrice / (weightKg ~/ 5)).round();
}

const _kMockItems = [
  _BallaItem(
    id: 'b1',
    name: 'بالة ملابس نسائية',
    shop: 'متجر الأمانة',
    stars: 4.8,
    weightKg: 25,
    totalPrice: 120000,
    category: 'ملابس',
    isFeatured: true,
  ),
  _BallaItem(
    id: 'b2',
    name: 'بالة أحذية مستوردة',
    shop: 'بيت البالة',
    stars: 4.5,
    weightKg: 30,
    totalPrice: 185000,
    category: 'أحذية',
  ),
  _BallaItem(
    id: 'b3',
    name: 'بالة ملابس أطفال',
    shop: 'الصفا للجملة',
    stars: 4.7,
    weightKg: 20,
    totalPrice: 95000,
    category: 'ملابس',
  ),
  _BallaItem(
    id: 'b4',
    name: 'بالة حقائب نسائية',
    shop: 'جملة الرشيد',
    stars: 4.3,
    weightKg: 15,
    totalPrice: 145000,
    category: 'حقائب',
  ),
  _BallaItem(
    id: 'b5',
    name: 'بالة إكسسوارات مشكلة',
    shop: 'متجر النجمة',
    stars: 4.6,
    weightKg: 10,
    totalPrice: 68000,
    category: 'إكسسوارات',
  ),
  _BallaItem(
    id: 'b6',
    name: 'بالة أقمشة تركية',
    shop: 'دار الأقمشة',
    stars: 4.9,
    weightKg: 40,
    totalPrice: 210000,
    category: 'أقمشة',
  ),
];

const _kCategories = ['الكل', 'ملابس', 'أحذية', 'حقائب', 'إكسسوارات', 'أقمشة'];

// ── Page ──────────────────────────────────────────────────────────
class BallaPage extends StatefulWidget {
  const BallaPage({super.key});

  @override
  State<BallaPage> createState() => _BallaPageState();
}

class _BallaPageState extends State<BallaPage> {
  late final HomeCubit _cubit;
  late final CategoryCubit _categoryCubit;
  int _selectedUnit = 0;      // 0=بالكيلو, 1=بالقطعة, 2=بالحزمة
  int _selectedCategory = 0;  // index in _kCategories
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
    _categoryCubit = getIt<CategoryCubit>(param1: 'balla')..fetchCategories();
  }

  List<_BallaItem> get _filteredItems {
    if (_selectedCategory == 0) return _kMockItems;
    final cat = _kCategories[_selectedCategory];
    return _kMockItems.where((i) => i.category == cat).toList();
  }

  String _pricePerUnitLabel(_BallaItem item) {
    switch (_selectedUnit) {
      case 1:  return '${IqdFormatter.format(item.pricePerPiece)}/قطعة';
      case 2:  return '${IqdFormatter.format(item.pricePerBundle)}/حزمة';
      default: return '${IqdFormatter.format(item.pricePerKg)}/كغم';
    }
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
          CartConflictSheet.show(context);
        },
        child: Scaffold(
          backgroundColor: _kBg,
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
                fabColor: _kPurple,
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
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildHeroCard()),
              SliverToBoxAdapter(child: _buildUnitToggle()),
              SliverToBoxAdapter(child: _buildCategoryChips()),
              SliverToBoxAdapter(child: _buildFilterRow()),
              SliverToBoxAdapter(child: _buildBallaGrid()),
              SliverToBoxAdapter(child: _buildFeaturedSection()),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kBg,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            // Left: inventory icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _kPurpleSurf,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.inventory_2_rounded, color: _kPurple, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'بالة',
                style: GoogleFonts.cairo(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: _kPurple,
                ),
              ),
            ),
            // Notifications icon
            BlocBuilder<BallaCartCubit, CartState>(
              builder: (ctx, cartState) => Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/balla/cart'),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _kBorder.withValues(alpha: 0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.notifications_outlined, color: _kPurple, size: 20.sp),
                    ),
                  ),
                  if (cartState.cartCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: const BoxDecoration(
                          color: _kPurple,
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

  // ── Search Bar ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: _kBorder),
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'ابحث عن بالة...',
            hintStyle: GoogleFonts.cairo(
              color: const Color(0xFFA89585),
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: _kPurple, size: 20.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }

  // ── Hero Promoted Card ────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF1E0A3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'جديدة',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '٢٥ كغم',
                    style: GoogleFonts.cairo(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'بالة ملابس نسائية — نخب أول',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '١٢٠,٠٠٠ د.ع',
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: _kGold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/balla/b1'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'تسوق',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: _kPurple,
                            ),
                          ),
                        ),
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

  // ── Unit Toggle ───────────────────────────────────────────────────
  Widget _buildUnitToggle() {
    final units = ['بالكيلو', 'بالقطعة', 'بالحزمة'];
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _kBorder),
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
                    color: selected ? _kPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: selected
                        ? null
                        : Border.all(color: _kPurple.withValues(alpha: 0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    units[i],
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : _kPurple,
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

  // ── Category Chips ────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: SizedBox(
        height: 38.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          scrollDirection: Axis.horizontal,
          itemCount: _kCategories.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (context, i) {
            final selected = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: selected ? _kPurple : Colors.white,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: selected ? _kPurple : _kBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _kCategories[i],
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _kPurple,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Filter / View Row ─────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          // Filter dropdown
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, color: _kPurple, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'فلترة',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _kPurple,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_down_rounded, color: _kPurple, size: 16.sp),
              ],
            ),
          ),
          const Spacer(),
          // Grid / list toggle
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _isGridView ? _kPurple : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _kBorder),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.grid_view_rounded,
                color: _isGridView ? Colors.white : _kPurple,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: !_isGridView ? _kPurple : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _kBorder),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.view_list_rounded,
                color: !_isGridView ? Colors.white : _kPurple,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Balla Grid ────────────────────────────────────────────────────
  Widget _buildBallaGrid() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'لا توجد بالات في هذا القسم',
            style: GoogleFonts.cairo(fontSize: 15.sp, color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: _isGridView
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.62,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _BallaCard(
                item: items[index],
                pricePerUnit: _pricePerUnitLabel(items[index]),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => _BallaListCard(
                item: items[index],
                pricePerUnit: _pricePerUnitLabel(items[index]),
              ),
            ),
    );
  }

  // ── "بالات مميزة" section ─────────────────────────────────────────
  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بالات مميزة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _kText,
                ),
              ),
              Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _kPurple,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: _kMockItems.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) => _FeaturedCard(
              item: _kMockItems[index],
              pricePerUnit: _pricePerUnitLabel(_kMockItems[index]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Balla Grid Card ────────────────────────────────────────────────
class _BallaCard extends StatelessWidget {
  final _BallaItem item;
  final String pricePerUnit;

  const _BallaCard({required this.item, required this.pricePerUnit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/balla/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD2BBFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 130.h,
                  width: double.infinity,
                  color: const Color(0xFFEDE7F6),
                  child: const Center(
                    child: Icon(Icons.inventory_2_rounded,
                        color: Color(0xFF7C3AED), size: 40),
                  ),
                ),
                // Weight badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      '${item.weightKg} كغم',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Verified badge
                Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0xFFD2BBFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: const Color(0xFF7C3AED), size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            'موثق',
                            style: GoogleFonts.cairo(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: _kText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      IqdFormatter.format(item.totalPrice),
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: _kGold,
                      ),
                    ),
                    Text(
                      pricePerUnit,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.shop,
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.star_rounded, color: _kGold, size: 12.sp),
                        SizedBox(width: 2.w),
                        Text(
                          item.stars.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: _kText,
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
      ),
    );
  }
}

// ── Balla List Card ────────────────────────────────────────────────
class _BallaListCard extends StatelessWidget {
  final _BallaItem item;
  final String pricePerUnit;

  const _BallaListCard({required this.item, required this.pricePerUnit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/balla/${item.id}'),
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD2BBFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image
            Container(
              width: 110.w,
              color: const Color(0xFFEDE7F6),
              child: const Center(
                child: Icon(Icons.inventory_2_rounded,
                    color: Color(0xFF7C3AED), size: 36),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: _kText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.verified_rounded,
                            color: const Color(0xFF7C3AED), size: 14.sp),
                      ],
                    ),
                    Text(
                      '${item.weightKg} كغم — ${item.category}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              IqdFormatter.format(item.totalPrice),
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: _kGold,
                              ),
                            ),
                            Text(
                              pricePerUnit,
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: _kGold, size: 12.sp),
                            SizedBox(width: 2.w),
                            Text(
                              item.stars.toString(),
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: _kText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured Horizontal Card ───────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final _BallaItem item;
  final String pricePerUnit;

  const _FeaturedCard({required this.item, required this.pricePerUnit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/balla/${item.id}'),
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD2BBFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120.h,
                  width: double.infinity,
                  color: const Color(0xFFEDE7F6),
                  child: const Center(
                    child: Icon(Icons.inventory_2_rounded,
                        color: Color(0xFF7C3AED), size: 44),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      '${item.weightKg} كغم',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: _kText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      IqdFormatter.format(item.totalPrice),
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: _kGold,
                      ),
                    ),
                    Text(
                      pricePerUnit,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
