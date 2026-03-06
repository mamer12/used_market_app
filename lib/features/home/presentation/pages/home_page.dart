import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/portal_models.dart';
import '../bloc/home_cubit.dart';
import '../widgets/curated_carousel.dart';
import '../widgets/home_components.dart';

// ── Portal Home Screen ─────────────────────────────────────────────────────
/// The generic Super App Portal — entry point for all 4 Mini-Apps.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading && state.liveAuctions.isEmpty) {
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
                    // 1. SliverAppBar — Escrow Wallet + Omnibox
                    _HomeAppBar(l10n: l10n),

                    // 2. Announcements Carousel
                    if (state.announcements.isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSection(
                          padding:
                              EdgeInsets.zero, // no extra padding for carousel
                          child: AnnouncementsCarousel(
                            items: state.announcements,
                            onTap: (ann) {
                              // Handle tap based on link
                            },
                          ),
                        ),
                      ),

                    // 3. Bento Grid — 4 Mini-Apps
                    SliverToBoxAdapter(
                      child: HomeSection(
                        title: l10n.homeMarkets,
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
                          onTileTap: (id) {
                            switch (id) {
                              case 'matajir':
                                context.go('/matajir');
                                break;
                              case 'balla':
                                context.go('/balla');
                                break;
                              case 'mazad':
                                context.go('/mazadat');
                                break;
                              case 'mustamal':
                                context.go('/mustamal');
                                break;
                            }
                          },
                        ),
                      ),
                    ),

                    // 4a. Trending Auctions
                    if (state.liveAuctions.isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSection(
                          title: l10n.homeSectionAuctions,
                          trailing: _buildSeeAll(l10n.homeSeeAll, () {
                            context.push('/mazadat');
                          }),
                          child: CuratedCarousel(
                            products: state.liveAuctions
                                .map(
                                  (a) => ProductPreview(
                                    id: a.id ?? '',
                                    title: a.title,
                                    imageUrl: a.images.isNotEmpty
                                        ? a.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: (a.currentPrice ?? a.startPrice ?? 0)
                                        .toDouble(),
                                    contextType: 'mazad',
                                  ),
                                )
                                .toList(),
                            onProductTap: (product) {
                              // Tap auction
                            },
                          ),
                        ),
                      ),

                    // 4b. New in Retail (Matajir)
                    if (state.featuredProducts
                        .where((p) => !p.isBalla)
                        .isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSection(
                          title: l10n.homeSectionMatajir,
                          trailing: _buildSeeAll(l10n.shopAll, () {
                            context.go('/matajir');
                          }),
                          child: CuratedCarousel(
                            products: state.featuredProducts
                                .where((p) => !p.isBalla)
                                .map(
                                  (p) => ProductPreview(
                                    id: p.id,
                                    title: p.name,
                                    imageUrl: p.images.isNotEmpty
                                        ? p.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: p.price.toDouble(),
                                    contextType: 'matajir_product',
                                  ),
                                )
                                .toList(),
                            onProductTap: (product) {
                              // Navigate to product detail
                            },
                          ),
                        ),
                      ),

                    // 4c. Mustamal Steals
                    if (state.portal.mustamal.isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSection(
                          title: l10n.homeSectionMustamal,
                          trailing: _buildSeeAll(l10n.homeSeeAll, () {}),
                          child: CuratedCarousel(
                            products: state.portal.mustamal
                                .map(
                                  (item) => ProductPreview(
                                    id: item.id,
                                    title: item.title,
                                    imageUrl: item.images.isNotEmpty
                                        ? item.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: item.price.toDouble(),
                                    contextType: 'mustamal_item',
                                  ),
                                )
                                .toList(),
                            onProductTap: (product) {
                              // Navigate to item detail
                            },
                          ),
                        ),
                      ),

                    // 4d. Balla Steals
                    if (state.portal.balla.isNotEmpty)
                      SliverToBoxAdapter(
                        child: HomeSection(
                          title: l10n.homeSectionBalla,
                          trailing: _buildSeeAll(l10n.shopAll, () {
                            context.go('/balla');
                          }),
                          child: CuratedCarousel(
                            products: state.portal.balla
                                .map(
                                  (p) => ProductPreview(
                                    id: p.id,
                                    title: p.name,
                                    imageUrl: p.images.isNotEmpty
                                        ? p.images.first
                                        : 'https://placehold.co/400x400/png',
                                    price: p.price.toDouble(),
                                    contextType: 'balla_product',
                                  ),
                                )
                                .toList(),
                            onProductTap: (product) {
                              // Navigate to balla product detail
                            },
                          ),
                        ),
                      ),

                    // Bottom spacing — clear the floating bottom nav bar
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

  Widget _buildSeeAll(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

// ── Home AppBar — Extract (T016) ─────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final AppLocalizations l10n;

  const _HomeAppBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      pinned: true,
      toolbarHeight: 120.h,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.w,
          ), // Let child margins handle padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Top Row — Brand + Escrow Wallet pill
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'لكطة',
                        style: GoogleFonts.cairo(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // Escrow Wallet pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 15.sp,
                            color: const Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'الرصيد: -- د.ع', // Placeholder: logic to follow in T014
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Omnibox Search Bar
              OmniboxWidget(
                hintText: l10n.omniboxHint,
                onTap: () => context.push('/search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
