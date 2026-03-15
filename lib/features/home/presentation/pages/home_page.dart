import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../auction/presentation/pages/auction_live_page.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../data/models/portal_models.dart';
import '../bloc/home_cubit.dart';
import '../widgets/curated_carousel.dart';
import '../widgets/home_components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;
  late final WalletCubit _walletCubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
    _walletCubit = getIt<WalletCubit>()..loadBalance();
  }

  @override
  void dispose() {
    _cubit.close();
    _walletCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _walletCubit),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.isLoading && state.liveAuctions.isEmpty) {
              return const _HomeSkeleton();
            }

            if (state.error != null && state.liveAuctions.isEmpty) {
              return _ErrorView(
                message: state.error!,
                onRetry: () => _cubit.loadFeed(),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surfaceAlt,
              onRefresh: () async {
                await _cubit.loadFeed();
                await _walletCubit.loadBalance();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Hero Zone: header + search + wallet (unified bg) ───
                  SliverToBoxAdapter(
                    child: _HeroZone(
                      l10n: l10n,
                      onSearchTap: () => context.push('/search'),
                      onDeposit: () => context.push('/wallet/deposit'),
                      onWithdraw: () => context.push('/wallet/withdraw'),
                      onTransfer: () => context.push('/wallet/transfer'),
                    ),
                  ),

                  // ── Quick utilities ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                      child: QuickUtilitiesRow(
                        onTap: (id) => _onUtilityTap(context, id),
                      ),
                    ),
                  ),

                  // ── Promo carousel ─────────────────────────────────────
                  if (state.announcements.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: AnnouncementsCarousel(
                          items: state.announcements,
                          onTap: (ann) {
                            if (ann.deepLink != null) context.push(ann.deepLink!);
                          },
                        ),
                      ),
                    ),

                  // ── Sooq Bento Grid ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: HomeSection(
                      title: l10n.homeMarkets,
                      trailing: _SeeAllLink(
                        label: l10n.homeSeeAll,
                        onTap: () {},
                      ),
                      child: BentoGrid(
                        labels: {
                          'mazad': l10n.miniAppMazad,
                          'matajir': l10n.miniAppMatajir,
                          'mustamal': l10n.miniAppMustamal,
                          'balla': l10n.miniAppBalla,
                        },
                        taglines: {
                          'mazad': l10n.miniAppMazadTagline,
                          'matajir': l10n.miniAppMatajirTagline,
                          'mustamal': l10n.miniAppMustamalTagline,
                          'balla': l10n.miniAppBallaTagline,
                        },
                        liveAuctionCount: state.liveAuctions.length,
                        onTileTap: (id) => _onSooqTap(context, id),
                      ),
                    ),
                  ),

                  // ── Curated: Live Auctions ─────────────────────────────
                  if (state.liveAuctions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeSection(
                        title: l10n.homeSectionAuctions,
                        trailing: _SeeAllLink(
                          label: l10n.homeSeeAll,
                          onTap: () => context.push('/mazadat'),
                        ),
                        child: CuratedCarousel(
                          products: state.liveAuctions
                              .map((a) => ProductPreview(
                                    id: a.id ?? '',
                                    title: a.title,
                                    imageUrl: a.images.isNotEmpty
                                        ? a.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: (a.currentPrice ?? a.startPrice ?? 0)
                                        .toDouble(),
                                    contextType: 'mazad',
                                  ))
                              .toList(),
                          onProductTap: (p) => _onAuctionTap(context, p, state),
                        ),
                      ),
                    ),

                  // ── Curated: Matajir ───────────────────────────────────
                  if (state.featuredProducts.where((p) => !p.isBalla).isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeSection(
                        title: l10n.homeSectionMatajir,
                        trailing: _SeeAllLink(
                          label: l10n.shopAll,
                          onTap: () => context.go('/matajir'),
                        ),
                        child: CuratedCarousel(
                          products: state.featuredProducts
                              .where((p) => !p.isBalla)
                              .map((p) => ProductPreview(
                                    id: p.id,
                                    title: p.name,
                                    imageUrl: p.images.isNotEmpty
                                        ? p.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: p.price.toDouble(),
                                    contextType: 'matajir_product',
                                  ))
                              .toList(),
                          onProductTap: (p) => _onMatajirProductTap(context, p, state),
                        ),
                      ),
                    ),

                  // ── Curated: Mustamal ──────────────────────────────────
                  if (state.portal.mustamal.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeSection(
                        title: l10n.homeSectionMustamal,
                        trailing: _SeeAllLink(
                          label: l10n.homeSeeAll,
                          onTap: () => context.push('/mustamal'),
                        ),
                        child: CuratedCarousel(
                          products: state.portal.mustamal
                              .map((item) => ProductPreview(
                                    id: item.id,
                                    title: item.title,
                                    imageUrl: item.images.isNotEmpty
                                        ? item.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: item.price.toDouble(),
                                    contextType: 'mustamal_item',
                                  ))
                              .toList(),
                          onProductTap: (_) {},
                        ),
                      ),
                    ),

                  // ── Curated: Balla ─────────────────────────────────────
                  if (state.portal.balla.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HomeSection(
                        title: l10n.homeSectionBalla,
                        trailing: _SeeAllLink(
                          label: l10n.shopAll,
                          onTap: () => context.go('/balla'),
                        ),
                        child: CuratedCarousel(
                          products: state.portal.balla
                              .map((p) => ProductPreview(
                                    id: p.id,
                                    title: p.name,
                                    imageUrl: p.images.isNotEmpty
                                        ? p.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: p.price.toDouble(),
                                    contextType: 'balla_product',
                                  ))
                              .toList(),
                          onProductTap: (p) => _onBallaProductTap(context, p, state),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 110.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onUtilityTap(BuildContext context, String id) {
    HapticFeedback.selectionClick();
    switch (id) {
      case 'orders':
        context.push('/orders');
      case 'messages':
        context.push('/messages');
      case 'favorites':
        context.push('/favorites');
      case 'support':
        context.push('/support');
    }
  }

  void _onSooqTap(BuildContext context, String id) {
    HapticFeedback.selectionClick();
    switch (id) {
      case 'mazad':
        context.go('/mazadat');
      case 'matajir':
        context.go('/matajir');
      case 'balla':
        context.go('/balla');
      case 'mustamal':
        context.go('/mustamal');
    }
  }

  void _onAuctionTap(BuildContext context, ProductPreview p, HomeState state) {
    final original = state.liveAuctions.firstWhere(
      (a) => a.id == p.id,
      orElse: () => const AuctionModel(),
    );
    if (original.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuctionLivePage(
          auctionId: original.id!,
          title: original.title,
          currentPrice: '${original.currentPrice ?? 0}',
          currency: 'د.ع',
          imageUrl: original.images.isNotEmpty
              ? original.images.first
              : 'https://placehold.co/800x800/png',
        ),
      ),
    );
  }

  void _onMatajirProductTap(BuildContext context, ProductPreview p, HomeState state) {
    final original = state.featuredProducts.firstWhere(
      (prod) => prod.id == p.id,
      orElse: () => const ProductModel(id: '', name: '', price: 0, images: [], shopId: ''),
    );
    if (original.id.isNotEmpty) {
      context.push('/matajir/product/${original.id}', extra: original);
    }
  }

  void _onBallaProductTap(BuildContext context, ProductPreview p, HomeState state) {
    final original = state.portal.balla.firstWhere(
      (prod) => prod.id == p.id,
      orElse: () => const ProductModel(id: '', name: '', price: 0, images: [], shopId: ''),
    );
    if (original.id.isNotEmpty) {
      context.push('/balla/product/${original.id}', extra: original);
    }
  }
}

// ── Hero Zone: header + search + wallet on unified dark-green bg ───────────────

class _HeroZone extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onSearchTap;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;

  const _HeroZone({
    required this.l10n,
    required this.onSearchTap,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onTransfer,
  });

  static const _bgTop    = Color(0xFF0E4D30);
  static const _bgBottom = Color(0xFF062518);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_bgTop, _bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        // glass border on bottom edge
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _bgBottom.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // top specular sheen
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                16.w, topPadding + 12.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── App bar row ──────────────────────────
                Row(
                  children: [
                    Text(
                      'مضمون',
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4ADE80),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                // ── Search bar — dark glass variant ──────
                GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 46.h,
                    padding: EdgeInsetsDirectional.only(
                        start: 14.w, end: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.55),
                            size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            l10n.homeSearch,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        Icon(Icons.mic_outlined,
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 18.sp),
                        SizedBox(width: 10.w),
                        Container(
                            width: 1,
                            height: 18.h,
                            color: Colors.white.withValues(alpha: 0.20)),
                        SizedBox(width: 10.w),
                        Icon(Icons.photo_camera_outlined,
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 18.sp),
                        SizedBox(width: 4.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // ── Wallet card ──────────────────────────
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, walletState) {
                    return WalletCard(
                      balanceIqd: switch (walletState) {
                        WalletLoading() => null,
                        WalletLoaded(:final balanceIqd) => balanceIqd,
                        WalletError() => -1,
                      },
                      onDeposit: onDeposit,
                      onWithdraw: onWithdraw,
                      onTransfer: onTransfer,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── See All Link ──────────────────────────────────────────────────────────────

class _SeeAllLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SeeAllLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56.sp, color: AppTheme.inactive),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 80.w, height: 20.h, borderRadius: 8.r),
                SkeletonBox(width: 120.w, height: 32.h, borderRadius: 16.r),
              ],
            ),
            SizedBox(height: 16.h),
            // Search
            SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 24.r),
            SizedBox(height: 16.h),
            // Wallet card
            SkeletonBox(width: double.infinity, height: 140.h, borderRadius: 20.r),
            SizedBox(height: 20.h),
            // Quick utilities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (_) => Column(
                  children: [
                    SkeletonBox(width: 52.w, height: 52.w, borderRadius: 26.r),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 36.w, height: 10.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Carousel
            SkeletonBox(width: double.infinity, height: 140.h, borderRadius: 16.r),
            SizedBox(height: 20.h),
            // Bento grid
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 140.h, borderRadius: 16.r)),
                SizedBox(width: 12.w),
                Expanded(child: SkeletonBox(height: 140.h, borderRadius: 16.r)),
              ],
            ),
            SizedBox(height: 12.h),
            SkeletonBox(width: double.infinity, height: 100.h, borderRadius: 16.r),
            SizedBox(height: 12.h),
            SkeletonBox(width: double.infinity, height: 100.h, borderRadius: 16.r),
          ],
        ),
      ),
    );
  }
}

// Re-export HomePageSkeleton alias used by other files
typedef HomePageSkeleton = _HomeSkeleton;
