import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/group_buy_model.dart';

/// Lists all active group buys with progress bars.
///
/// Each card shows: product image, original price, group price,
/// slots remaining, time left, and a "Join" button.
class GroupBuyListPage extends StatefulWidget {
  const GroupBuyListPage({super.key});

  @override
  State<GroupBuyListPage> createState() => _GroupBuyListPageState();
}

class _GroupBuyListPageState extends State<GroupBuyListPage> {
  late final Dio _dio;
  bool _loading = true;
  String? _error;
  List<GroupBuyModel> _groupBuys = [];

  // Countdown timers
  Timer? _countdownTimer;
  final Map<String, Duration> _remaining = {};

  static const _purple = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _dio = getIt<Dio>();
    _fetchGroupBuys();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGroupBuys() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/api/v1/group-buys');
      final raw = (res.data['data'] as List?) ?? [];
      final buys = raw
          .map((e) => GroupBuyModel.fromJson(e as Map<String, dynamic>))
          .where((b) => b.status == 'open')
          .toList();

      setState(() {
        _groupBuys = buys;
        _loading = false;
      });

      // Initialize remaining durations
      for (final gb in buys) {
        _remaining[gb.id] = gb.expiresAt.difference(DateTime.now());
      }
      _startCountdown();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        for (final gb in _groupBuys) {
          final diff = gb.expiresAt.difference(DateTime.now());
          _remaining[gb.id] = diff.isNegative ? Duration.zero : diff;
        }
      });
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _joinGroupBuy(String id) async {
    try {
      await _dio.post('/api/v1/group-buys/$id/join');
      if (!mounted) return;
      // Navigate to group buy detail
      context.push('/group/$id');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الانضمام إلى الشلة',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0FF),
        appBar: AppBar(
          title: Text(
            l10n?.groupBuyListTitle ?? 'الشلّة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () => context.push('/group-buys/create'),
              icon: const Icon(Icons.add_rounded),
              tooltip: l10n?.groupBuyCreateTitle ?? 'إنشاء شلّة',
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _purple),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
            SizedBox(height: 12.h),
            Text(_error!,
                style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.black54)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchGroupBuys,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: Text(l10n?.retryBtn ?? 'إعادة المحاولة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    if (_groupBuys.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_rounded, size: 64.sp, color: _purple),
            SizedBox(height: 12.h),
            Text(
              l10n?.groupBuyEmpty ?? 'لا توجد شلّات نشطة',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n?.groupBuyEmptySub ?? 'أنشئ شلّة أو انتظر شلّات جديدة',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => context.push('/group-buys/create'),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                l10n?.groupBuySubmit ?? 'إنشاء الشلّة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchGroupBuys,
      color: _purple,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _groupBuys.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => _buildGroupBuyCard(_groupBuys[i]),
      ),
    );
  }

  Widget _buildGroupBuyCard(GroupBuyModel gb) {
    final remaining = _remaining[gb.id] ?? Duration.zero;
    final slotsLeft = gb.targetCount - gb.currentCount;

    return GestureDetector(
      onTap: () => context.push('/group/${gb.id}'),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: gb.productImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: gb.productImageUrl!,
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            SizedBox(width: 12.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    gb.productTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: gb.progress.clamp(0.0, 1.0),
                            minHeight: 6.h,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_purple),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${gb.currentCount}/${gb.targetCount}',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: _purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Price + time + slots
                  Row(
                    children: [
                      // Discount badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'خصم ${gb.discountPct}٪',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: _purple,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Time left
                      Icon(Icons.timer_outlined,
                          size: 12.sp, color: Colors.black45),
                      SizedBox(width: 2.w),
                      Text(
                        _formatDuration(remaining),
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: remaining.inMinutes < 60
                              ? Colors.red.shade600
                              : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // Slots remaining
                      Text(
                        '$slotsLeft متبقي',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Join button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _joinGroupBuy(gb.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'انضم',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.group_rounded, size: 32.sp, color: _purple),
    );
  }
}
