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
import '../../../home/presentation/bloc/home_cubit.dart';

class BallaPage extends StatefulWidget {
  const BallaPage({super.key});

  @override
  State<BallaPage> createState() => _BallaPageState();
}

class _BallaPageState extends State<BallaPage> {
  late final HomeCubit _cubit;
  final List<String> _filters = ['بالقطعة', 'بالكيلو', 'بالبالة'];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _cubit)],
      child: BlocListener<BallaCartCubit, CartState>(
        listenWhen: (prev, curr) =>
            curr.cartStatus == CartStatus.conflict &&
            prev.cartStatus != CartStatus.conflict,
        listener: (context, state) {
          CartConflictSheet.show(context, context.read<BallaCartCubit>());
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F6FF),
          body: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: AppTheme.background,
                  elevation: 0,
                  pinned: true,
                  centerTitle: false,
                  iconTheme: const IconThemeData(color: AppTheme.textPrimary),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALA MARKET',
                        style: GoogleFonts.cairo(
                          color: AppTheme.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Bulk & Logistics Hub',
                        style: GoogleFonts.cairo(
                          color: AppTheme.ballaPurple,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    BlocBuilder<BallaCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.ballaPurple.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.local_shipping_rounded,
                                  color: AppTheme.ballaPurple,
                                  size: 20.sp,
                                ),
                              ),
                              onPressed: () => context.push('/balla/cart'),
                            ),
                            if (cartState.cartCount > 0)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartState.cartCount}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.inactive.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      height: 44.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, _) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedFilter == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.ballaPurple
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.ballaPurple
                                      : AppTheme.inactive.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _filters[index],
                                style: GoogleFonts.cairo(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Grid
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.isLoading && state.portal.balla.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.ballaPurple,
                          ),
                        ),
                      );
                    }

                    final items = state.portal.balla;
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'لا يوجد بضاعة بالة حالياً',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.62,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _BallaCard(
                            item: items[index],
                            selectedFilter: _selectedFilter,
                          );
                        }, childCount: items.length),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BallaCard extends StatelessWidget {
  final dynamic item;
  final int selectedFilter;

  const _BallaCard({required this.item, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    String dynamicUnit = '١ للكيلو';
    if (selectedFilter == 0) dynamicUnit = 'للقطعة';
    if (selectedFilter == 2) dynamicUnit = 'للبالة ٥٠كغ';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ballaPurple.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: item.images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.ballaPurpleSurface,
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  )
                else
                  Container(color: AppTheme.ballaPurpleSurface),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'LOGISTICS READY',
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            IqdFormatter.format(item.price),
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ballaPurple,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.ballaPurpleSurface,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              dynamicUnit,
                              style: GoogleFonts.cairo(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ballaPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  BlocBuilder<BallaCartCubit, CartState>(
                    builder: (ctx, cartState) {
                      final inCart = cartState.isInCart(item.id);
                      return GestureDetector(
                        onTap: () => ctx.read<BallaCartCubit>().addToCart(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: inCart
                                ? AppTheme.ballaPurpleSurface
                                : AppTheme.ballaPurple,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                inCart
                                    ? Icons.inventory_rounded
                                    : Icons.add_box_rounded,
                                color: inCart
                                    ? AppTheme.ballaPurple
                                    : Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                inCart ? 'IN HUB' : 'ADD TO BATCH',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: inCart
                                      ? AppTheme.ballaPurple
                                      : Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
