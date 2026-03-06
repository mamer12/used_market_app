import 'dart:io';

void main() {
  final file = File('lib/features/home/presentation/pages/home_page.dart');
  var content = file.readAsStringSync();

  // 1. Add DiscoveryItem class at the very beginning
  final itemClass = '''
import 'dart:async';

class DiscoveryItem {
  final String id;
  final String title;
  final num price;
  final String imageUrl;
  final String type;
  final dynamic originalItem;

  DiscoveryItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.type,
    required this.originalItem,
  });
}
''';
  content = content.replaceFirst("import 'dart:async';", itemClass);

  // 2. Wrap slivers array with l10n
  content = content.replaceFirst(
    "                  slivers: [",
    "                  slivers: [\n                    Builder(builder: (context) { final l10n = AppLocalizations.of(context); return SliverToBoxAdapter(child: const SizedBox.shrink()); }),",
  );

  // 3. Replace _buildSuperAppModes block with _buildSooqGrid block
  final sooqGrid = '''
  Widget _buildSooqGrid(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBentoCard(
                  title: l10n.homeSooqShops,
                  subtitle: l10n.homeSooqShopsSub,
                  icon: Icons.storefront,
                  bgColor: AppTheme.surface,
                  textColor: AppTheme.textPrimary,
                  iconColor: AppTheme.textPrimary,
                  subtitleColor: AppTheme.textSecondary,
                  badge: Icon(Icons.verified, color: AppTheme.primary, size: 16.sp),
                  onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ShopsPage())),
                  borderColor: AppTheme.inactive.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildBentoCard(
                  title: l10n.homeSooqAuctions,
                  subtitle: l10n.homeSooqAuctionsSub,
                  icon: Icons.gavel,
                  bgColor: AppTheme.primary.withValues(alpha: 0.1),
                  textColor: AppTheme.primary,
                  iconColor: AppTheme.primary,
                  subtitleColor: AppTheme.primary.withValues(alpha: 0.8),
                  hasGlow: true,
                  badge: _PulsingDot(),
                  onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AuctionsPage())),
                  borderColor: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildBentoCard(
                  title: l10n.homeSooqBalla,
                  subtitle: l10n.homeSooqBallaSub,
                  icon: Icons.inventory_2,
                  bgColor: AppTheme.surface,
                  textColor: AppTheme.textPrimary,
                  iconColor: AppTheme.textSecondary,
                  subtitleColor: AppTheme.textSecondary,
                  onTap: () {},
                  borderColor: AppTheme.inactive.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildBentoCard(
                  title: l10n.homeSooqUsed,
                  subtitle: l10n.homeSooqUsedSub,
                  icon: Icons.handshake,
                  bgColor: AppTheme.secondary.withValues(alpha: 0.1),
                  textColor: AppTheme.secondary,
                  iconColor: AppTheme.secondary,
                  subtitleColor: AppTheme.secondary,
                  onTap: () {},
                  borderColor: AppTheme.secondary.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required Color subtitleColor,
    required VoidCallback onTap,
    Color? borderColor,
    Widget? badge,
    bool hasGlow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: hasGlow ? [
            BoxShadow(color: bgColor.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                badge ?? SizedBox(width: 16.w),
                Icon(icon, color: iconColor, size: 28.sp),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                Row(
                  children: [
                    if (hasGlow) ...[
                      badge ?? const SizedBox(),
                      SizedBox(width: 4.w),
                    ],
                    Expanded(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
''';

  final buildSuperAppModesStart = content.indexOf(
    '  // ── Super App Mode Strip',
  );
  final buildSuperAppModesEnd = content.indexOf('  // ── Live Auctions Strip');
  content = content.replaceRange(
    buildSuperAppModesStart,
    buildSuperAppModesEnd,
    sooqGrid,
  );

  // Update the call
  content = content.replaceFirst(
    'SliverToBoxAdapter(child: _buildSuperAppModes()),',
    'SliverToBoxAdapter(child: Builder(builder: (c) => _buildSooqGrid(AppLocalizations.of(c)))),',
  );

  // 4. Replace Shop and Used Market block with Discovery Feed block
  final discoveryGrid = '''
  // ── Discovery Feed ──────────────────────────────────────────
  Widget _buildDiscoveryFeedHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'اكتشف كنوز اليوم',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryFeed(HomeState state) {
    // Collect all products into a unified list
    final items = <DiscoveryItem>[];
    
    // Process Balla
    for (var b in state.portal.balla) {
      items.add(DiscoveryItem(
        id: 'balla_\${b.id}', title: b.name, price: b.price,
        imageUrl: b.images.isNotEmpty ? b.images.first : '', type: 'balla', originalItem: b,
      ));
    }
    // Process Mustamal
    for (var m in state.portal.mustamal) {
      items.add(DiscoveryItem(
        id: 'mustamal_\${m.id}', title: m.title, price: m.price,
        imageUrl: m.images.isNotEmpty ? m.images.first : '', type: 'used', originalItem: m,
      ));
    }
    // Process Featured Shops
    for (var p in state.featuredProducts.where((p) => !p.isBalla)) {
      items.add(DiscoveryItem(
        id: 'prod_\${p.id}', title: p.name, price: p.price,
        imageUrl: p.images.isNotEmpty ? p.images.first : '', type: 'new', originalItem: p,
      ));
    }
    // Order them consistently
    items.sort((a, b) => a.id.hashCode.compareTo(b.id.hashCode));

    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildDiscoveryCard(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard(DiscoveryItem item) {
    final l10n = AppLocalizations.of(context);
    Color badgeColor;
    Color badgeTextColor = Colors.white;
    String badgeText;
    if (item.type == 'new') {
      badgeColor = AppTheme.primary.withValues(alpha: 0.1);
      badgeTextColor = AppTheme.primary;
      badgeText = l10n.modeLocalShops;
    } else if (item.type == 'used') {
      badgeColor = AppTheme.secondary.withValues(alpha: 0.1);
      badgeTextColor = AppTheme.secondary;
      badgeText = l10n.homeSooqUsed;
    } else {
      badgeColor = AppTheme.surface;
      badgeTextColor = AppTheme.textSecondary;
      badgeText = l10n.homeSooqBalla;
    }

    return GestureDetector(
      onTap: () {
        if (item.originalItem is ProductModel) {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ProductDetailPage(product: item.originalItem)));
        } else if (item.originalItem is ItemModel) {
          // Navigate to mustamal detail page if applicable
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.2)),
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
                  if (item.imageUrl.isNotEmpty)
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppTheme.inactive.withValues(alpha: 0.2)),
                    )
                  else
                    Container(color: AppTheme.inactive.withValues(alpha: 0.2)),
                    
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatIQD(item.price),
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
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
''';

  final buildShopsStart = content.indexOf(
    '  // ── Shops Header ────────────────────────────────────────',
  );
  final classEnd = content.lastIndexOf('class _PulsingDot');
  content = content.replaceRange(
    buildShopsStart,
    classEnd,
    "$discoveryGrid\\n\\n",
  );

  // Replace the caller block within the slivers list
  final shopsIfStart = content.indexOf(
    '                    // ── Shops with products ───────────────────',
  );
  final bottomSpacingStart = content.indexOf(
    '                    // Bottom spacing (clear floating nav bar)',
  );

  final replacementCaller = '''
                    // ── Discovery Feed ────────────────
                    if (state.portal.balla.isNotEmpty || state.portal.mustamal.isNotEmpty || state.featuredProducts.isNotEmpty) ...[
                      SliverToBoxAdapter(child: _buildDiscoveryFeedHeader()),
                      _buildDiscoveryFeed(state),
                    ],

''';
  content = content.replaceRange(
    shopsIfStart,
    bottomSpacingStart,
    replacementCaller,
  );

  // 5. Remove unused _AppModeInfo
  final appModeInfoStart = content.indexOf('class _AppModeInfo');
  if (appModeInfoStart != -1) {
    final appModeInfoEnd = content.indexOf('}', appModeInfoStart) + 1;
    content = content.replaceRange(appModeInfoStart, appModeInfoEnd, '');
  }

  // 6. Fix withOpacity warning
  content = content.replaceAll('withOpacity(', 'withValues(alpha: ');

  file.writeAsStringSync(content);
}
