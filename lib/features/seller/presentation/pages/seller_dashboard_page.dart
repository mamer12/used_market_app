import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';

/// Seller dashboard page — accessible from Profile when user has a shop.
/// Shows today's stats, pending negotiations, active group buys, and story analytics.
class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late final Dio _dio = getIt<Dio>();

  bool _loading = true;
  String? _error;

  // Stats
  int _todayOrders = 0;
  int _todayRevenue = 0;
  int _storyViews = 0;
  int _followers = 0;

  // Pending items
  List<Map<String, dynamic>> _pendingNegotiations = [];
  final List<Map<String, dynamic>> _activeGroupBuys = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatPrice(int amount) =>
      '${NumberFormat('#,###', 'ar_IQ').format(amount)} د.ع';

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _dio.get<Map<String, dynamic>>('negotiations/seller').catchError((_) => Response<Map<String, dynamic>>(requestOptions: RequestOptions(), statusCode: 0)),
        _dio.get<Map<String, dynamic>>('orders/me').catchError((_) => Response<Map<String, dynamic>>(requestOptions: RequestOptions(), statusCode: 0)),
        _dio.get<Map<String, dynamic>>('shops/followers/count').catchError((_) => Response<Map<String, dynamic>>(requestOptions: RequestOptions(), statusCode: 0)),
        _dio.get<Map<String, dynamic>>('stories/stats').catchError((_) => Response<Map<String, dynamic>>(requestOptions: RequestOptions(), statusCode: 0)),
      ]);

      final negRes = results[0];
      final ordersRes = results[1];
      final followersRes = results[2];
      final storiesRes = results[3];

      if (negRes.statusCode == 200) {
        final data = negRes.data?['data'] as List? ?? [];
        _pendingNegotiations = data.cast<Map<String, dynamic>>();
      }

      if (ordersRes.statusCode == 200) {
        final ordersData = ordersRes.data?['data'] as List? ?? [];
        final today = DateTime.now();
        final todayOrders = ordersData.where((o) {
          final raw = o['created_at'] as String?;
          if (raw == null) return false;
          final d = DateTime.tryParse(raw);
          return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
        }).toList();
        _todayOrders = todayOrders.length;
        _todayRevenue = todayOrders.fold<int>(0, (sum, o) => sum + ((o['total'] as num?)?.toInt() ?? 0));
      }

      if (followersRes.statusCode == 200) {
        _followers = (followersRes.data?['data']?['count'] as num?)?.toInt() ?? 0;
      }

      if (storiesRes.statusCode == 200) {
        _storyViews = (storiesRes.data?['data']?['total_views'] as num?)?.toInt() ?? 0;
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F8),
        appBar: AppBar(
          title: Text(
            'لوحة البائع',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48.sp, color: AppTheme.textSecondary),
          SizedBox(height: 12.h),
          Text('فشل تحميل البيانات',
              style: GoogleFonts.cairo(
                  fontSize: 14.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      children: [
        // ── Stats Cards ────────────────────────────────────────────────
        Text(
          'إحصائيات اليوم',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.shopping_bag_rounded,
                label: 'الطلبات',
                value: '$_todayOrders',
                color: AppTheme.matajirBlue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money_rounded,
                label: 'الإيرادات',
                value: _formatPrice(_todayRevenue),
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.visibility_rounded,
                label: 'مشاهدات الستوري',
                value: '$_storyViews',
                color: const Color(0xFFEA580C),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatCard(
                icon: Icons.people_rounded,
                label: 'المتابعون',
                value: '$_followers',
                color: const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── Quick Actions ──────────────────────────────────────────────
        Text(
          'إجراءات سريعة',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.camera_alt_rounded,
                label: 'نشر ستوري',
                color: const Color(0xFFEA580C),
                onTap: () {
                  // TODO: Navigate to CreateStoryPage when available
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ستتوفر قريباً',
                          style: GoogleFonts.cairo()),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _QuickAction(
                icon: Icons.local_fire_department_rounded,
                label: 'حار ومكسب',
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ستتوفر قريباً',
                          style: GoogleFonts.cairo()),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _QuickAction(
                icon: Icons.add_shopping_cart_rounded,
                label: 'أضف منتج',
                color: AppTheme.matajirBlue,
                onTap: () => context.push('/matajir'),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // ── Pending Negotiations ───────────────────────────────────────
        _SectionHeader(title: 'عروض عملة بانتظار ردك', count: _pendingNegotiations.length),
        SizedBox(height: 8.h),
        if (_pendingNegotiations.isEmpty)
          _buildEmptyCard('لا توجد عروض جديدة')
        else
          ..._pendingNegotiations.take(5).map(
                (neg) => _NegotiationCard(
                  productTitle: neg['product_title'] ?? '',
                  offeredPrice: neg['offered_price'] ?? 0,
                  round: neg['round'] ?? 1,
                  onTap: () => context.push('/negotiations/${neg['id']}'),
                ),
              ),
        SizedBox(height: 24.h),

        // ── Active Group Buys ──────────────────────────────────────────
        _SectionHeader(title: 'شلّات نشطة', count: _activeGroupBuys.length),
        SizedBox(height: 8.h),
        if (_activeGroupBuys.isEmpty) _buildEmptyCard('لا توجد شلّات نشطة'),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action ─────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        if (count > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEA580C),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Negotiation Card ─────────────────────────────────────────────────────────

class _NegotiationCard extends StatelessWidget {
  final String productTitle;
  final int offeredPrice;
  final int round;
  final VoidCallback onTap;

  const _NegotiationCard({
    required this.productTitle,
    required this.offeredPrice,
    required this.round,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice =
        '${NumberFormat('#,###', 'ar_IQ').format(offeredPrice)} د.ع';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.handshake_outlined,
                  size: 20.sp, color: const Color(0xFFEA580C)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productTitle.isNotEmpty ? productTitle : 'عرض عملة',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'العرض: $formattedPrice · الجولة $round',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14.sp, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
