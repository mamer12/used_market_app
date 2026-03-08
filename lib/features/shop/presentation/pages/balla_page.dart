import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
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
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchBar(),
                      _buildFilters(),
                      _buildInventoryBanner(),
                      _buildSectionTitle('عروض البالة الحصرية', 'عرض الكل'),
                    ],
                  ),
                ),
                _buildProductsList(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'مواقع التوفر والشحن',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildWholesaleFeed(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.background.withValues(alpha: 0.8),
      elevation: 0,
      pinned: true,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.ballaPurple.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.textPrimary,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'سوق البالة',
              style: GoogleFonts.cairo(
                color: AppTheme.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<BallaCartCubit, CartState>(
          builder: (ctx, cartState) {
            return Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => context.push('/balla/cart'),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: AppTheme.textPrimary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  if (cartState.cartCount > 0)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: AppTheme.ballaPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.background,
                            width: 1.5,
                          ),
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
            );
          },
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
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
              color: AppTheme.textSecondary,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 72.h,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (e) => Center(child: Text(e.message)),
            loaded: (loaded) {
              final categories = loaded.categories;
              final hasBack = loaded.parentIdStack.isNotEmpty;
              final totalCount = categories.length + (hasBack ? 1 : 0);

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                scrollDirection: Axis.horizontal,
                itemCount: totalCount,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  if (hasBack && index == 0) {
                    return GestureDetector(
                      onTap: () => context.read<CategoryCubit>().navigateBack(),
                      child: _buildFilterItem(
                        icon: Icons.arrow_back_rounded,
                        label: 'رجوع',
                        isSelected: false,
                      ),
                    );
                  }

                  final catIndex = hasBack ? index - 1 : index;
                  final category = categories[catIndex];
                  final isSelected =
                      false; // logic for selection could be added if filtering products

                  return GestureDetector(
                    onTap: () =>
                        context.read<CategoryCubit>().drillDown(category.id),
                    child: _buildFilterItem(
                      icon: Icons.category_rounded,
                      label: category.nameAr,
                      isSelected: isSelected,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.ballaPurple : Colors.white,
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(
          color: isSelected
              ? AppTheme.ballaPurple
              : AppTheme.inactive.withValues(alpha: 0.2),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.ballaPurple.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        height: 176.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF0F172A),
          image: const DecorationImage(
            image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBoREI2YQiAurwcReERxz5LNaM0t7V2P2wE-CIMCf06PGGgBIqi2DAESfuuhth0zJV_AaZgRqwHkn1Vzb2DXaYvWCaGYMIhK-iQTiNq43_AtQ1bpwZwajGx3c-XYDXFkAhieRS__Rj6Zy6bbWIyCGP19riXKVX6OTy1SunvFsNjLO2i2e2eByxv2wjUEMEOZ0Tjh29oL6KZQFzUN8lgsRBN9lGqPQ4XynzKUVrzBTl-PRjyuSFprJIhbjU9KbPSzkrZBUf5H0cElik',
            ),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [Colors.black87, Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.ballaPurple.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  'تحديث المخزون',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'الوصول التالي للجملة:\nالاثنين 9 صباحاً',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'أكثر من 500 طن من الملابس الأوروبية الفاخرة',
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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

  Widget _buildProductsList() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading && state.portal.balla.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.ballaPurple),
            ),
          );
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

  Widget _buildWholesaleFeed() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _LocationItem(
            name: 'مخازن البصرة المركزية',
            status: 'متاح الآن',
            statusColor: Colors.green,
            statusBgColor: Colors.green.shade50,
            moq: 'أقل كمية (MOQ): 10 بالات',
            eta: 'شحن خلال 24 ساعة',
          ),
          SizedBox(height: 12.h),
          _LocationItem(
            name: 'مجمع مخازن أربيل',
            status: 'مخزون منخفض',
            statusColor: Colors.orange.shade700,
            statusBgColor: Colors.orange.shade50,
            moq: 'أقل كمية (MOQ): 2 بالة',
            eta: 'شحن خلال 48 ساعة',
          ),
        ],
      ),
    );
  }
}

class _BulkItemCard extends StatelessWidget {
  final dynamic item;

  const _BulkItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          SizedBox(
            height: 192.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: item.images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.inactive.withValues(alpha: 0.1),
                    ),
                  )
                else
                  Container(color: AppTheme.inactive.withValues(alpha: 0.1)),
                // Badges overlay
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageBadge(
                        '🇪🇺 استيراد أوروبي',
                        Colors.white.withValues(alpha: 0.9),
                        AppTheme.textPrimary,
                      ),
                      SizedBox(height: 8.h),
                      _buildImageBadge(
                        'نخب أول Grade A',
                        Colors.green.shade500.withValues(alpha: 0.9),
                        Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'ID: #${item.id.toString().length > 6 ? item.id.toString().substring(0, 6).toUpperCase() : item.id}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Data grids
                Row(
                  children: [
                    Expanded(
                      child: _buildDataGrid(
                        'سعر الكيلو',
                        IqdFormatter.format(item.price),
                        isPrice: true,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildDataGrid(
                        'الوزن الإجمالي',
                        '50 كغم',
                        isPrice: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<BallaCartCubit, CartState>(
                        builder: (ctx, cartState) {
                          final inCart = cartState.isInCart(item.id);
                          return InkWell(
                            onTap: () =>
                                ctx.read<BallaCartCubit>().addToCart(item),
                            borderRadius: BorderRadius.circular(12.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: inCart
                                    ? AppTheme.ballaPurpleSurface
                                    : AppTheme.ballaPurple,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: inCart
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: AppTheme.ballaPurple
                                              .withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                inCart
                                    ? 'موجود في السلة'
                                    : 'إضافة إلى سلة الجملة',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: inCart
                                      ? AppTheme.ballaPurple
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.inactive.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDataGrid(String label, String value, {bool isPrice = false}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: isPrice
                ? GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ballaPurple,
                  )
                : GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String moq;
  final String eta;

  const _LocationItem({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.moq,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppTheme.ballaPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.warehouse_rounded,
              color: AppTheme.ballaPurple,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  moq,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppTheme.inactive,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      eta,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.inactive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.inactive,
              size: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
