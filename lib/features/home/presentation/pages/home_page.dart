import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_guard.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Super App Home — High-utility dashboard with Industrial Pop design.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────
            SliverToBoxAdapter(child: _buildAppBar()),

            // ── Search Bar (plain sliver — SliverPersistentHeader
            //    triggers parentDataDirty in Flutter 3.41) ─────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Hero Banner Carousel ────────────────────
            SliverToBoxAdapter(child: _buildBannerCarousel()),

            // ── Categories Grid ─────────────────────────
            SliverToBoxAdapter(child: _buildCategoriesSection()),

            // ── Live Now Section ────────────────────────
            SliverToBoxAdapter(child: _buildLiveNowSection()),

            // Bottom spacing
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────
  Widget _buildAppBar() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: l10n.appTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Notification Bell
          AuthGuard(
            onAuthenticated: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Notifications...')),
              );
            },
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 28.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────
  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: AppTheme.background,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 48.h,
          child: Row(
            children: [
              Icon(Icons.search, color: AppTheme.textSecondary, size: 22.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.homeSearch,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.inactive,
                  ),
                ),
              ),
              Icon(
                Icons.tune_outlined,
                color: AppTheme.textSecondary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner Carousel ─────────────────────────────────────
  Widget _buildBannerCarousel() {
    final l10n = AppLocalizations.of(context);

    final banners = [
      _BannerData(l10n.bannerTitle1, l10n.bannerSub1),
      _BannerData(l10n.bannerTitle2, l10n.bannerSub2),
      _BannerData(l10n.bannerTitle3, l10n.bannerSub3),
    ];

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: SizedBox(
        height: 160.h,
        child: PageView.builder(
          controller: _bannerController,
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner.title,
                      style: GoogleFonts.cairo(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        banner.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.buttonText,
                        ),
                      ),
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

  // ── Categories Grid ─────────────────────────────────────
  Widget _buildCategoriesSection() {
    final l10n = AppLocalizations.of(context);

    final categories = [
      _CategoryData(Icons.phone_android_outlined, l10n.categoryMobile),
      _CategoryData(Icons.directions_car_outlined, l10n.categoryCars),
      _CategoryData(Icons.chair_outlined, l10n.categoryFurniture),
      _CategoryData(Icons.work_outline, l10n.categoryJobs),
      _CategoryData(Icons.home_outlined, l10n.categoryRealEstate),
      _CategoryData(Icons.devices_other_outlined, l10n.categoryElectronics),
      _CategoryData(Icons.checkroom_outlined, l10n.categoryFashion),
      _CategoryData(Icons.more_horiz, l10n.categoryMore),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeCategories,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return AuthGuard(
                onAuthenticated: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${cat.label}...')),
                  );
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      child: Icon(
                        cat.icon,
                        size: 24.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      cat.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Live Now Section ────────────────────────────────────
  Widget _buildLiveNowSection() {
    final l10n = AppLocalizations.of(context);

    final liveItems = [
      const _LiveData('iPhone 15 Pro Max', '750,000 IQD', 12),
      const _LiveData('Toyota Camry 2022', '42,000,000 IQD', 8),
      const _LiveData('MacBook Pro M3', '1,200,000 IQD', 5),
      const _LiveData('Samsung S24 Ultra', '650,000 IQD', 15),
    ];

    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.homeLiveNow} 🔴',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.homeSeeAll,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 180.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: liveItems.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final item = liveItems[index];
                return AuthGuard(
                  onAuthenticated: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Placing bid on ${item.title}...'),
                      ),
                    );
                  },
                  child: _LiveCard(data: item, l10n: l10n),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// _SearchBarDelegate removed — SliverPersistentHeader triggers
// parentDataDirty assertion in Flutter 3.41's semantics system.

// ── Live Auction Card ─────────────────────────────────────
class _LiveCard extends StatelessWidget {
  final _LiveData data;
  final AppLocalizations l10n;

  const _LiveCard({required this.data, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Badge
          Row(
            children: [
              const _PulsingDot(),
              SizedBox(width: 6.w),
              Text(
                l10n.homeLive,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.liveBadge,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.title,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.buttonText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            data.price,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.bidders(data.bidderCount),
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.inactive,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing Red Dot (Live indicator) ──────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exclude from semantics — this decorative animation has no meaning
    // and its constant updates were dirtying the semantics tree.
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl),
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(
            color: AppTheme.liveBadge,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Data Classes ──────────────────────────────────────────
class _BannerData {
  final String title;
  final String subtitle;
  const _BannerData(this.title, this.subtitle);
}

class _CategoryData {
  final IconData icon;
  final String label;
  const _CategoryData(this.icon, this.label);
}

class _LiveData {
  final String title;
  final String price;
  final int bidderCount;
  const _LiveData(this.title, this.price, this.bidderCount);
}
