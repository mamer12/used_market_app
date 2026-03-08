import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';
import 'auction_live_page.dart';

class MazadatPage extends StatefulWidget {
  const MazadatPage({super.key});

  @override
  State<MazadatPage> createState() => _MazadatPageState();
}

class _MazadatPageState extends State<MazadatPage> {
  late final AuctionsCubit _cubit;
  late final CategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionsCubit>()..loadAuctions();
    _categoryCubit = getIt<CategoryCubit>(param1: 'mazadat')..fetchCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatIQD(num price) {
    final formatted = NumberFormat('#,###', 'en_US').format(price.toInt());
    return '$formatted دينار';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _categoryCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Dark theme
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MAZADAT',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'LIVE AUCTIONS',
                              style: GoogleFonts.inter(
                                color: Colors.redAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.redAccent,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Bar
              SizedBox(
                height: 44.h,
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return state.map(
                      initial: (_) => const SizedBox.shrink(),
                      loading: (_) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      ),
                      error: (e) => Center(
                        child: Text(
                          e.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      loaded: (loaded) {
                        final categories = loaded.categories;
                        final hasBack = loaded.parentIdStack.isNotEmpty;
                        final totalCount =
                            categories.length + (hasBack ? 1 : 0);

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          scrollDirection: Axis.horizontal,
                          itemCount: totalCount,
                          separatorBuilder: (_, _) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            if (hasBack && index == 0) {
                              return GestureDetector(
                                onTap: () => context
                                    .read<CategoryCubit>()
                                    .navigateBack(),
                                child: _buildCategoryChip(
                                  label: 'رجوع',
                                  isSelected: false,
                                  isBack: true,
                                ),
                              );
                            }

                            final catIndex = hasBack ? index - 1 : index;
                            final category = categories[catIndex];

                            return GestureDetector(
                              onTap: () => context
                                  .read<CategoryCubit>()
                                  .drillDown(category.id),
                              child: _buildCategoryChip(
                                label: category.nameAr,
                                isSelected: false,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // Body
              Expanded(
                child: BlocBuilder<AuctionsCubit, AuctionsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.auctions.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      );
                    }
                    if (state.auctions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gavel,
                              size: 80.sp,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مزادات نشطة حالياً',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                      itemCount: state.auctions.length,
                      separatorBuilder: (_, _) => SizedBox(height: 24.h),
                      itemBuilder: (context, index) {
                        return _AuctionMassiveCard(
                          auction: state.auctions[index],
                          formatIQD: _formatIQD,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    bool isBack = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.redAccent
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected
              ? Colors.redAccent
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBack) ...[
            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 14.sp),
            SizedBox(width: 6.w),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.cairo(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionMassiveCard extends StatelessWidget {
  final AuctionModel auction;
  final String Function(num) formatIQD;

  const _AuctionMassiveCard({required this.auction, required this.formatIQD});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuctionLivePage(
              auctionId: auction.id ?? '',
              title: auction.title,
              currentPrice: '${auction.currentPrice ?? 0}',
              currency: 'د.ع',
              imageUrl: auction.images.isNotEmpty
                  ? auction.images.first
                  : 'https://placehold.co/800x800/png',
            ),
          ),
        );
      },
      child: Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (auction.images.isNotEmpty)
              Image.network(
                auction.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: Colors.grey[900]),
              )
            else
              Container(color: Colors.grey[900]),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF121212),
                    const Color(0xFF121212).withValues(alpha: 0.8),
                    const Color(0xFF121212).withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 20.h,
              left: 20.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  color: Colors.black.withValues(alpha: 0.6),
                  child: _GlowingCountdown(
                    endTime: auction.endTime ?? DateTime.now(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24.h,
              left: 24.w,
              right: 24.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'HOT',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'LIVE AUCTION',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    auction.title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT BID',
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            formatIQD(
                              auction.currentPrice ?? auction.startPrice ?? 0,
                            ),
                            style: GoogleFonts.inter(
                              color: Colors.greenAccent,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.gavel_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'BID NOW',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
}

class _GlowingCountdown extends StatefulWidget {
  final DateTime endTime;
  const _GlowingCountdown({required this.endTime});

  @override
  State<_GlowingCountdown> createState() => _GlowingCountdownState();
}

class _GlowingCountdownState extends State<_GlowingCountdown> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      _timeLeft = widget.endTime.difference(DateTime.now());
      if (_timeLeft.isNegative) _timeLeft = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative || _timeLeft == Duration.zero) {
      return Text(
        'انتهى',
        style: GoogleFonts.cairo(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    final h = _timeLeft.inHours;
    final m = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, color: Colors.redAccent, size: 14.sp),
        SizedBox(width: 6.w),
        Text(
          '$h:$m:$s',
          style: GoogleFonts.cairo(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 14.sp,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
