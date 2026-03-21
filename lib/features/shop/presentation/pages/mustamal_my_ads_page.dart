import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../features/home/data/models/portal_models.dart';

/// إعلاناتي — Mustamal My Ads dashboard (seller view).
///
/// Shows seller's active, sold, and pending ads in a tab view.
/// Design follows Stitch v2 Mustamal theme: warm #FFF8F0, orange #EA580C.
class MustamalMyAdsPage extends StatefulWidget {
  const MustamalMyAdsPage({super.key});

  @override
  State<MustamalMyAdsPage> createState() => _MustamalMyAdsPageState();
}

class _MustamalMyAdsPageState extends State<MustamalMyAdsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['نشطة', 'مباعة', 'معلقة', 'الكل'];

  // Mock ads data until API provides seller-specific endpoint
  static final _mockAds = [
    ItemModel(
      id: '1',
      title: 'آيفون 14 برو ماكس - بحالة ممتازة',
      category: 'هواتف وأجهزة',
      images: const [],
      price: 950000,
      condition: 'مستعمل',
      city: 'بغداد',
    ),
    ItemModel(
      id: '2',
      title: 'سامسونج جالاكسي S23 الترا',
      category: 'هواتف وأجهزة',
      images: const [],
      price: 780000,
      condition: 'مستعمل',
      city: 'أربيل',
    ),
    ItemModel(
      id: '3',
      title: 'لابتوب ديل XPS 15 - 2023',
      category: 'أجهزة كمبيوتر',
      images: const [],
      price: 1200000,
      condition: 'مستعمل',
      city: 'البصرة',
    ),
    ItemModel(
      id: '4',
      title: 'كاميرا كانون EOS R6',
      category: 'كاميرات',
      images: const [],
      price: 1500000,
      condition: 'مستعمل',
      city: 'بغداد',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAds = _mockAds.take(2).toList();
    final soldAds = _mockAds.skip(2).take(1).toList();
    final pendingAds = _mockAds.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.mustamalOrange,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'إعلاناتي',
          style: GoogleFonts.tajawal(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.mustamalOrange,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_rounded,
              color: AppTheme.mustamalOrange,
              size: 24.sp,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/mustamal/create');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEDE6DC)),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _StatsHeader(
              totalAds: _mockAds.length,
              activeAds: activeAds.length,
              soldAds: soldAds.length,
              pendingAds: pendingAds.length,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                labelColor: AppTheme.mustamalOrange,
                unselectedLabelColor: const Color(0xFFA89585),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AppTheme.mustamalOrange,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: const Color(0xFFEDE6DC),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AdsList(
              ads: activeAds,
              emptyLabel: 'لا توجد إعلانات نشطة',
              statusLabel: 'نشط',
              statusColor: const Color(0xFF059669),
            ),
            _AdsList(
              ads: soldAds,
              emptyLabel: 'لا توجد إعلانات مباعة',
              statusLabel: 'مُباع',
              statusColor: const Color(0xFF6B5E52),
            ),
            _AdsList(
              ads: pendingAds,
              emptyLabel: 'لا توجد إعلانات معلقة',
              statusLabel: 'معلق',
              statusColor: const Color(0xFFC9930A),
            ),
            _AdsList(
              ads: _mockAds,
              emptyLabel: 'لا توجد إعلانات',
              statusLabel: 'نشط',
              statusColor: const Color(0xFF059669),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/mustamal/create');
        },
        backgroundColor: AppTheme.mustamalOrange,
        icon: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20.sp),
        label: Text(
          'إضافة إعلان',
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 4,
      ),
    );
  }
}

// ── Stats Header ─────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final int totalAds;
  final int activeAds;
  final int soldAds;
  final int pendingAds;

  const _StatsHeader({
    required this.totalAds,
    required this.activeAds,
    required this.soldAds,
    required this.pendingAds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة إعلاناتي',
            style: GoogleFonts.tajawal(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1713),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'إجمالي الإعلانات',
                  value: '$totalAds',
                  icon: Icons.campaign_rounded,
                  color: AppTheme.mustamalOrange,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'إعلانات نشطة',
                  value: '$activeAds',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'إعلانات مباعة',
                  value: '$soldAds',
                  icon: Icons.handshake_rounded,
                  color: const Color(0xFF1B4FD8),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'قيد المراجعة',
                  value: '$pendingAds',
                  icon: Icons.pending_rounded,
                  color: const Color(0xFFC9930A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: const Color(0xFFEDE6DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1713),
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11.sp,
              color: const Color(0xFF6B5E52),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ads List ──────────────────────────────────────────────────────────────────

class _AdsList extends StatelessWidget {
  final List<ItemModel> ads;
  final String emptyLabel;
  final String statusLabel;
  final Color statusColor;

  const _AdsList({
    required this.ads,
    required this.emptyLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              color: const Color(0xFFA89585),
              size: 56.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyLabel,
              style: GoogleFonts.tajawal(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B5E52),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بإضافة إعلان جديد',
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                color: const Color(0xFFA89585),
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/mustamal/create');
              },
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.mustamalOrange,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'أضف إعلان',
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
      itemCount: ads.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _AdCard(
        ad: ads[index],
        statusLabel: statusLabel,
        statusColor: statusColor,
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final ItemModel ad;
  final String statusLabel;
  final Color statusColor;

  const _AdCard({
    required this.ad,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/mustamal/${ad.id}', extra: ad);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: const Color(0xFFEDE6DC)),
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
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: ad.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ad.images.first,
                      width: 76.w,
                      height: 76.w,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: const Color(0xFFF5F0E8)),
                      errorWidget: (_, _, _) => _PlaceholderThumb(),
                    )
                  : _PlaceholderThumb(),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ad.title,
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1713),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.tajawal(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 11.sp,
                        color: const Color(0xFFA89585),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        ad.city ?? 'غير محدد',
                        style: GoogleFonts.tajawal(
                          fontSize: 11.sp,
                          color: const Color(0xFFA89585),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        ad.category,
                        style: GoogleFonts.tajawal(
                          fontSize: 11.sp,
                          color: const Color(0xFFA89585),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        IqdFormatter.format(ad.price.toDouble()),
                        style: AppTheme.priceStyle(
                          fontSize: 15.sp,
                          color: AppTheme.mustamalOrange,
                        ),
                      ),
                      Row(
                        children: [
                          // Edit button
                          _ActionButton(
                            icon: Icons.edit_rounded,
                            color: const Color(0xFF1B4FD8),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              // TODO: navigate to edit ad page
                            },
                          ),
                          SizedBox(width: 8.w),
                          // Delete button
                          _ActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: const Color(0xFFDC2626),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _showDeleteConfirm(context, ad.title);
                            },
                          ),
                        ],
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

  void _showDeleteConfirm(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: Text(
          'حذف الإعلان',
          style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700, color: const Color(0xFF1C1713)),
        ),
        content: Text(
          'هل أنت متأكد من حذف "$title"؟',
          style: GoogleFonts.tajawal(color: const Color(0xFF6B5E52)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: const Color(0xFF6B5E52)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: dispatch delete action via cubit
            },
            child: Text(
              'حذف',
              style: GoogleFonts.tajawal(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 15.sp),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xFFF5F0E8),
      child: Icon(
        Icons.image_rounded,
        color: const Color(0xFFA89585),
        size: 28,
      ),
    );
  }
}

// ── Tab Bar Delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFFF8F0),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
