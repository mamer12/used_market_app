import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_guard.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/presentation/pages/auction_live_page.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/presentation/pages/shop_products_page.dart';
import '../../../shop/presentation/pages/shops_page.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../bloc/home_cubit.dart';

/// Discovery Home — Mustamal marketplace feed.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Banner Slider ────────────────────────────────────
  final _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
    // Auto-scroll banner every 4 seconds
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % 3;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ── Banner slide image URLs ─────────────────────────
  static const _bannerImageUrls = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCLfmoagBqBgI5e6Q0gBxM1WKy595yQPkOrmlzH5eVPkcEDk-zljRMBQwOfSwO7LuZLt61nRlqrBJn63QZgLQb51Asf1Xldtpzuucej79XNKYNUBe2To4Gsv-c_BW5hmYhSC_w_F3MMVdL7AUW1t6CO0cSD2NkYR_neEsphWgXshKGcnJv3mqrfcc1rsVXZaJxtnyP40jgESx_3GRlx3BZglzI8-6vP1L3uNDM2tVcI3COLIKJ3xDvCTNceMnPsQGtjwO4vIJmCkrCO',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoSNxnmsCSOw7687WkBI7IlBj18cmnT9hNFNlOXdbVAyke8wfwvTeZG5m7Eci_EaIeGSzbvHzkgx-7NTWPOJSCgdtwRMpU3yvMHgV-7Se8a4Izy_ACOkRyMMVuboDI-UKaSBTcHz_J04yVKJy5ZFuoXMGcIHN-El5ouqTvhSLrkzXEE6I02OT61v3wWpFJ3yjTSfujOW_iLM9ulIlA2fDetn3_rkwX80RdyznS1nRqwxJ7_jv6yPj7k11tz6IhNfPgz9ugq5ZReYf',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUd0_dgNYpiCh0dVXkrPJYWw5rI_srEdS2YAMXFw8TSyT-tfuExR6HeQ4WCyet1XdjGBa8b0GKuCCaos-ZiqAMy6K6jCfExFX9lKV4LQrWiLHNKFRfdwcBue8Ivd4ZtW-EuPYqnuiKi_FVrix3xHzo-Smebfd3Jc-RFT_EiTlVw8IaIN1yThQnM1NMyEpYSPzjhjZxKdUhgaKgWaJ6AgyisLyX61TeIInS1r1rlirYmkPjVgSFweJDi-6KCn9enrPmIcpYJ-25LogN',
  ];

  // ── Removed mock data parameters ────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              return CustomScrollView(
                slivers: [
                  // ── Header ─────────────────────────────────
                  SliverToBoxAdapter(child: _buildHeader()),

                  // ── Search Bar ─────────────────────────────
                  SliverToBoxAdapter(child: _buildSearchBar()),

                  // ── Hero Banner ────────────────────────────
                  SliverToBoxAdapter(child: _buildHeroBanner()),

                  // ── Categories ─────────────────────────────
                  SliverToBoxAdapter(child: _buildCategories()),

                  // ── Live Now ───────────────────────────────
                  if (state.liveAuctions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildLiveNowSection(state.liveAuctions),
                    ),

                  // ── Shops with products ───────────────────
                  if (state.shopCatalogs.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _buildShopsHeader(state.shopCatalogs.length)),
                    ...state.shopCatalogs.map(
                      (entry) => SliverToBoxAdapter(
                        child: _buildShopSection(entry),
                      ),
                    ),
                  ] else if (state.featuredProducts.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _buildFreshlyListedHeader()),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: _buildListingsGrid(state.featuredProducts),
                    ),
                  ],

                  // Bottom spacing
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header (Greeting only) ─────────────────────────────
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeGreetingSub,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.homeGreeting,
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────
  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Container(
        height: 52.h,
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
            SizedBox(width: 16.w),
            Icon(Icons.search, size: 24.sp, color: AppTheme.inactive),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.homeSearch,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.inactive,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24.h,
              color: AppTheme.inactive.withValues(alpha: 0.3),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.tune, size: 22.sp, color: AppTheme.textSecondary),
            SizedBox(width: 14.w),
          ],
        ),
      ),
    );
  }

  // ── Hero Banner Carousel ────────────────────────────────
  Widget _buildHeroBanner() {
    final l10n = AppLocalizations.of(context);

    final bannerSlides = [
      _BannerSlide(
        badge: l10n.bannerBadge1,
        title: l10n.bannerTitle1,
        subtitle: l10n.bannerSub1,
        cta: l10n.bannerCta1,
        imageUrl: _bannerImageUrls[0],
      ),
      _BannerSlide(
        badge: l10n.bannerBadge2,
        title: l10n.bannerTitle2,
        subtitle: l10n.bannerSub2,
        cta: l10n.bannerCta2,
        imageUrl: _bannerImageUrls[1],
      ),
      _BannerSlide(
        badge: l10n.bannerBadge3,
        title: l10n.bannerTitle3,
        subtitle: l10n.bannerSub3,
        cta: l10n.bannerCta3,
        imageUrl: _bannerImageUrls[2],
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: 160.h,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: bannerSlides.length,
                onPageChanged: (index) {
                  setState(() => _currentBanner = index);
                },
                itemBuilder: (context, index) {
                  return _buildBannerSlide(bannerSlides[index]);
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(bannerSlides.length, (index) {
              final isActive = index == _currentBanner;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isActive ? 20.w : 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary
                      : AppTheme.inactive.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide(_BannerSlide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          slide.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.textPrimary,
                  AppTheme.textPrimary.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerEnd,
              end: AlignmentDirectional.centerStart,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  slide.badge,
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Flexible(
                child: Text(
                  slide.title,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                slide.subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.cta,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, size: 12.sp, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Categories (Horizontal Scroll) ──────────────────────
  Widget _buildCategories() {
    final l10n = AppLocalizations.of(context);

    final categories = [
      _CategoryItem(Icons.gavel, l10n.categoryAuctions, isHighlighted: true),
      _CategoryItem(Icons.directions_car, l10n.categoryCars),
      _CategoryItem(Icons.smartphone, l10n.categoryMobile),
      _CategoryItem(Icons.chair, l10n.categoryFurniture),
      _CategoryItem(Icons.handyman, l10n.categoryServices),
    ];

    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: SizedBox(
        height: 100.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: categories.length,
          separatorBuilder: (_, _) => SizedBox(width: 20.w),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return AuthGuard(
              onAuthenticated: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${cat.label}...')),
                );
              },
              child: SizedBox(
                width: 72.w,
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cat.isHighlighted
                            ? AppTheme.primary
                            : AppTheme.background,
                        border: cat.isHighlighted
                            ? null
                            : Border.all(
                                color: AppTheme.inactive.withValues(alpha: 0.3),
                              ),
                        boxShadow: cat.isHighlighted
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        cat.icon,
                        size: 28.sp,
                        color: cat.isHighlighted
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      cat.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: cat.isHighlighted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: cat.isHighlighted
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Live Now Section ────────────────────────────────────
  Widget _buildLiveNowSection(List<AuctionModel> auctions) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ExcludeSemantics(child: _PulsingDot()),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.homeLiveNow,
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.homeLiveSubtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.homeSeeAll,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.sp,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal Live Cards
        SizedBox(height: 8.h),
        SizedBox(
          height: 260.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: auctions.length,
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) =>
                _buildLiveCard(auctions[index], l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCard(AuctionModel item, AppLocalizations l10n) {
    const darkCard = Color(0xFF1A1A1A);

    return AuthGuard(
      onAuthenticated: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AuctionLivePage(
              auctionId: item.id ?? '',
              title: item.title,
              currentPrice: '${item.currentPrice ?? 0}',
              currency: l10n.currency, // Assuming local currency for now
              imageUrl: item.images.isNotEmpty
                  ? item.images.first
                  : 'https://placehold.co/400x400/png',
            ),
          ),
        );
      },
      child: Container(
        width: 260.w,
        decoration: BoxDecoration(
          color: darkCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 140.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.images.isNotEmpty
                        ? item.images.first
                        : 'https://placehold.co/600x400',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.85),
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[600],
                        size: 40.sp,
                      ),
                    ),
                  ),
                  // LIVE badge
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.liveBadge,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sensors, size: 10.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            l10n.homeLive,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [darkCard, darkCard.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          // Simple mock logic for timer display
                          (item.endTime
                                      ?.difference(DateTime.now())
                                      .isNegative ??
                                  true)
                              ? 'Ended'
                              : 'Live',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Price + Bid button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeHighestBid,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${item.currentPrice ?? 0}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${l10n.currency}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.gavel,
                          size: 22.sp,
                          color: AppTheme.textPrimary,
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

  // ── Shops Header ────────────────────────────────────────
  Widget _buildShopsHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 4.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Shops',
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ShopsPage()),
            ),
            child: Row(
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Single Shop Section ──────────────────────────────────
  Widget _buildShopSection(ShopCatalogEntry entry) {
    final shop = entry.shop;
    final products = entry.products;
    // Deterministic accent colour from shop id
    final accentColors = [
      AppTheme.primary, AppTheme.secondary, const Color(0xFF00BCD4),
      const Color(0xFF7C4DFF), const Color(0xFF00C853), const Color(0xFFFF6D00),
    ];
    final accent = accentColors[shop.id.hashCode.abs() % accentColors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Shop header row ────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    shop.name.isNotEmpty
                        ? shop.name[0].toUpperCase()
                        : 'S',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shop.description != null && shop.description!.isNotEmpty)
                      Text(
                        shop.description!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ShopProductsPage(
                      shopSlug: shop.slug,
                      shopName: shop.name,
                    ),
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Visit',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Horizontal product scroll ───────────────────
        SizedBox(
          height: 200.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) =>
                _buildShopProductCard(products[index], accent),
          ),
        ),

        SizedBox(height: 6.h),
        // ── Thin divider ──────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.inactive.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  Widget _buildShopProductCard(ProductModel item, Color accent) {
    return Container(
      width: 148.w,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with heart button overlay
          SizedBox(
            height: 110.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                item.images.isNotEmpty
                    ? Image.network(
                        item.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _productImagePlaceholder(accent),
                      )
                    : _productImagePlaceholder(accent),
                // Heart
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _HomeHeartButton(
                    product: item,
                    size: 28.w,
                    iconSize: 14.sp,
                    bgColor: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
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
                          '${item.price.toInt()} IQD',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.inStock <= 0)
                        Text(
                          'Out',
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        )
                      else
                        _HomeAddToCartButton(product: item, accent: accent),
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

  Widget _productImagePlaceholder(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.08),
      child: Icon(Icons.image_outlined, color: accent.withValues(alpha: 0.4), size: 32.sp),
    );
  }

  // ── Freshly Listed Header ───────────────────────────────
  Widget _buildFreshlyListedHeader() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.homeFreshlyListed,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              _buildViewToggle(Icons.grid_view, true),
              SizedBox(width: 6.w),
              _buildViewToggle(Icons.view_list, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isActive) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: isActive ? AppTheme.textPrimary : AppTheme.inactive,
      ),
    );
  }

  // ── Listings Grid ───────────────────────────────────────
  Widget _buildListingsGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200.h,
          child: const Center(
            child: Text(
              'No products found.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildListingCard(products[index]),
        childCount: products.length,
      ),
    );
  }

  Widget _buildListingCard(ProductModel item) {
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
                Image.network(
                  item.images.isNotEmpty
                      ? item.images.first
                      : 'https://placehold.co/400x600/png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppTheme.surface,
                    child: Icon(
                      Icons.image,
                      color: AppTheme.inactive,
                      size: 32.sp,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: _HomeHeartButton(product: item),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 10.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Baghdad', // Replace with real location when available
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.price.toInt()} IQD', // Simple mock currency
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'New',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.inactive,
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

// ── Heart (Save) Button ───────────────────────────────────
class _HomeHeartButton extends StatelessWidget {
  final ProductModel product;
  final double? size;
  final double? iconSize;
  final Color? bgColor;

  const _HomeHeartButton({
    required this.product,
    this.size,
    this.iconSize,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, bool>(
      selector: (s) => s.savedItems.any((s) => s.product.id == product.id),
      builder: (ctx, isSaved) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ctx.read<CartCubit>().toggleSaved(product);
          },
          child: Container(
            width: size ?? 32.w,
            height: size ?? 32.w,
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white.withValues(alpha: 0.88),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isSaved),
                size: iconSize ?? 16.sp,
                color: isSaved ? AppTheme.liveBadge : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Add to Cart Button ────────────────────────────────────
class _HomeAddToCartButton extends StatelessWidget {
  final ProductModel product;
  final Color accent;

  const _HomeAddToCartButton({
    required this.product,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, bool>(
      selector: (s) => s.cartItems.any((i) => i.product.id == product.id),
      builder: (ctx, inCart) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ctx.read<CartCubit>().addToCart(product);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('Added to cart', style: GoogleFonts.cairo()),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: inCart ? AppTheme.textPrimary : accent,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(
              inCart ? Icons.check : Icons.add,
              size: 14.sp,
              color: inCart ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

// ── Pulsing Dot ───────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _fade = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12.w,
      height: 12.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.liveBadge.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.liveBadge,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────
class _CategoryItem {
  final IconData icon;
  final String label;
  final bool isHighlighted;

  const _CategoryItem(this.icon, this.label, {this.isHighlighted = false});
}

class _BannerSlide {
  final String badge;
  final String title;
  final String subtitle;
  final String cta;
  final String imageUrl;

  const _BannerSlide({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.imageUrl,
  });
}
