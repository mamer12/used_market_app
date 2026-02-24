import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_guard.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/presentation/pages/auction_live_page.dart';
import '../../../auction/presentation/pages/auctions_page.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/presentation/pages/product_detail_page.dart';
import '../../../shop/presentation/pages/shop_products_page.dart';
import '../../../shop/presentation/pages/shops_page.dart';
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
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                onRefresh: () => _cubit.loadFeed(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Header ─────────────────────────────────
                    SliverToBoxAdapter(child: _buildHeader()),

                    // ── Search Bar ─────────────────────────────
                    SliverToBoxAdapter(child: _buildSearchBar()),

                    // ── Hero Banner ────────────────────────────
                    SliverToBoxAdapter(child: _buildHeroBanner()),

                    // ── Super App Mode Strip ────────────────────
                    SliverToBoxAdapter(child: _buildSuperAppModes()),

                    // ── Live Auctions ───────────────────────────
                    if (state.liveAuctions.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildLiveNowSection(state.liveAuctions),
                      ),

                    // ── Shops with products ───────────────────
                    if (state.shopCatalogs.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildShopsHeader(state.shopCatalogs.length),
                      ),
                      ...state.shopCatalogs.map(
                        (entry) =>
                            SliverToBoxAdapter(child: _buildShopSection(entry)),
                      ),
                    ],

                    // ── Used & Pre-loved market ────────────────
                    if (state.featuredProducts.isNotEmpty) ...[
                      SliverToBoxAdapter(child: _buildUsedMarketHeader()),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                        sliver: _buildListingsGrid(state.featuredProducts),
                      ),
                    ],

                    // Bottom spacing (clear floating nav bar)
                    SliverToBoxAdapter(child: SizedBox(height: 110.h)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Currency Formatter ──────────────────────────────────
  static String _formatIQD(num price) {
    final formatted = NumberFormat('#,###', 'en_US').format(price.toInt());
    return '$formatted د.ع';
  }

  // ── Header ──────────────────────────────────────────────
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand mark
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 20.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 10.w),
          // Brand name + greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'لكطة',
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  l10n.homeGreetingSub,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.inactive.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 20.sp,
                color: AppTheme.textPrimary,
              ),
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
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SearchPage())),
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
  Widget _buildSuperAppModes() {
    final l10n = AppLocalizations.of(context);
    final modes = [
      _AppModeInfo(
        icon: Icons.gavel_rounded,
        label: l10n.modeAuctions,
        tagline: l10n.modeAuctionTag,
        color: const Color(0xFF1A1A1A),
        iconColor: AppTheme.primary,
        textColor: Colors.white,
      ),
      _AppModeInfo(
        icon: Icons.storefront_rounded,
        label: l10n.modeLocalShops,
        tagline: l10n.modeLocalTag,
        color: const Color(0xFFF0FFF4),
        iconColor: const Color(0xFF2E7D32),
        textColor: const Color(0xFF1B5E20),
      ),
      _AppModeInfo(
        icon: Icons.shopping_bag_rounded,
        label: l10n.modeOfficialStores,
        tagline: l10n.modeOfficialTag,
        color: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF1565C0),
        textColor: const Color(0xFF0D47A1),
      ),
      _AppModeInfo(
        icon: Icons.autorenew_rounded,
        label: l10n.modeUsed,
        tagline: l10n.modeUsedTag,
        color: const Color(0xFFFFF8E1),
        iconColor: AppTheme.secondary,
        textColor: const Color(0xFFE65100),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
          child: Text(
            l10n.homeWhatLooking,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 96.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: modes.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final mode = modes[index];
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.homeBrowseAuctions,
                          style: GoogleFonts.cairo(),
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (index == 1 || index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShopsPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.homeBrowseUsed,
                          style: GoogleFonts.cairo(),
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 120.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: mode.color,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: mode.iconColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: mode.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          mode.icon,
                          size: 18.sp,
                          color: mode.iconColor,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.label,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: mode.textColor,
                            ),
                          ),
                          Text(
                            mode.tagline,
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: mode.textColor.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveNowSection(List<AuctionModel> auctions) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
          child: Row(
            children: [
              ExcludeSemantics(child: _PulsingDot()),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeLiveNow,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      l10n.homeLiveSubtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AuctionsPage())),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeSeeAll,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11.sp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 305.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                      _AuctionCountdownTimer(endTime: item.endTime),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  // Social proof — watchers + bids
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 11.sp,
                        color: Colors.white54,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        l10n.auctionWatching(
                          ((item.id?.hashCode ?? 0).abs() % 80) + 10,
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 11.sp,
                        color: AppTheme.secondary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        l10n.auctionBidding(
                          ((item.id?.hashCode ?? 0).abs() % 20) + 2,
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
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
                                    text: _formatIQD(item.currentPrice ?? 0),
                                    style: GoogleFonts.cairo(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gavel_rounded,
                              size: 14.sp,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'زايد',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
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

  // ── Shops Header ────────────────────────────────────────
  Widget _buildShopsHeader(int count) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 4.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 18.sp,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shopsSection,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 11.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.shopsTrustedSub,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const ShopsPage())),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.homeSeeAll,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11.sp,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single Shop Section ──────────────────────────────────
  Widget _buildShopSection(ShopCatalogEntry entry) {
    final l10n = AppLocalizations.of(context);
    final shop = entry.shop;
    final products = entry.products;
    // Deterministic accent colour from shop id
    final accentColors = [
      AppTheme.primary,
      AppTheme.secondary,
      const Color(0xFF00BCD4),
      const Color(0xFF7C4DFF),
      const Color(0xFF00C853),
      const Color(0xFFFF6D00),
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
                    shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S',
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shop.name,
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 15.sp,
                          color: const Color(0xFF1565C0),
                        ),
                      ],
                    ),
                    if (shop.description != null &&
                        shop.description!.isNotEmpty)
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    l10n.visitShop,
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
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: item)),
        );
      },
      child: Container(
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
                          errorBuilder: (_, _, _) =>
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
                            _formatIQD(item.price),
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
                          Builder(
                            builder: (ctx) => Text(
                              AppLocalizations.of(ctx).homeOutOfStock,
                              style: GoogleFonts.cairo(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
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
      ),
    );
  }

  Widget _productImagePlaceholder(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.08),
      child: Icon(
        Icons.image_outlined,
        color: accent.withValues(alpha: 0.4),
        size: 32.sp,
      ),
    );
  }

  // ── Freshly Listed Header ───────────────────────────────
  Widget _buildUsedMarketHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.autorenew_rounded,
              size: 22.sp,
              color: AppTheme.secondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.usedMarketTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
                Text(
                  l10n.usedMarketSub,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE65100).withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14.sp, color: AppTheme.secondary),
        ],
      ),
    );
  }

  Widget _buildListingsGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200.h,
          child: Center(
            child: Builder(
              builder: (context) => Text(
                AppLocalizations.of(context).homeNoProducts,
                style: const TextStyle(color: Colors.white54),
              ),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: item)),
        );
      },
      child: Container(
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
                            l10n.defaultCity,
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
                            _formatIQD(item.price),
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            final condList = [
                              l10n.condExcellent,
                              l10n.condVeryGood,
                              l10n.condGood,
                              l10n.condFair,
                            ];
                            final cond =
                                condList[item.id.hashCode.abs() %
                                    condList.length];
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                cond,
                                style: GoogleFonts.cairo(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondary,
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
            ),
          ],
        ),
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

  const _HomeAddToCartButton({required this.product, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocSelector<CartCubit, CartState, bool>(
      selector: (s) => s.cartItems.any((i) => i.product.id == product.id),
      builder: (ctx, inCart) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ctx.read<CartCubit>().addToCart(product);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(l10n.addedToCart, style: GoogleFonts.cairo()),
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
class _AppModeInfo {
  final IconData icon;
  final String label;
  final String tagline;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const _AppModeInfo({
    required this.icon,
    required this.label,
    required this.tagline,
    required this.color,
    required this.iconColor,
    required this.textColor,
  });
}

// ── Auction Countdown Timer ───────────────────────────────
class _AuctionCountdownTimer extends StatefulWidget {
  final DateTime? endTime;
  const _AuctionCountdownTimer({this.endTime});

  @override
  State<_AuctionCountdownTimer> createState() => _AuctionCountdownTimerState();
}

class _AuctionCountdownTimerState extends State<_AuctionCountdownTimer> {
  Timer? _tick;
  Duration _remaining = Duration.zero;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _compute();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _compute());
  }

  void _compute() {
    final end = widget.endTime;
    if (end == null) {
      if (mounted) setState(() => _ended = true);
      return;
    }
    final diff = end.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _ended = diff.isNegative;
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_ended) {
      return Text(
        AppLocalizations.of(context).auctionEndedLabel,
        style: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.inactive,
        ),
      );
    }
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 11.sp, color: AppTheme.primary),
        SizedBox(width: 3.w),
        Text(
          '${_fmt(h)}:${_fmt(m)}:${_fmt(s)}',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
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
