import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

// ── Mock notification model ───────────────────────────────────────────────────

enum _NotifType { order, auction, escrow, dispute, message }

class _Notif {
  final String id;
  final _NotifType type;
  final String title;
  final String subtitle;
  final String relativeTime;
  final String? routePath;
  bool isRead;

  _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.relativeTime,
    this.routePath,
    this.isRead = false,
  });
}

List<_Notif> _buildMockNotifs() => [
      _Notif(
        id: 'n1',
        type: _NotifType.order,
        title: 'تم شحن طلبك',
        subtitle: 'طلب #LQ-4A2F — آيفون 13 برو في الطريق إليك',
        relativeTime: 'منذ ساعتين',
        routePath: '/orders/LQ-4A2F',
      ),
      _Notif(
        id: 'n2',
        type: _NotifType.auction,
        title: 'فزت بالمزاد!',
        subtitle: 'لابتوب ديل XPS — ٧٥٠,٠٠٠ د.ع',
        relativeTime: 'منذ ٣ ساعات',
        routePath: '/mazadat',
      ),
      _Notif(
        id: 'n3',
        type: _NotifType.escrow,
        title: 'تم إفراج الضمان',
        subtitle: 'تم تحويل ٤٥٠,٠٠٠ د.ع إلى محفظتك',
        relativeTime: 'منذ ٥ ساعات',
      ),
      _Notif(
        id: 'n4',
        type: _NotifType.message,
        title: 'رسالة جديدة من أبو محمد',
        subtitle: 'هل المنتج لا يزال متاحاً؟',
        relativeTime: 'منذ ٦ ساعات',
        routePath: '/messages/1',
        isRead: true,
      ),
      _Notif(
        id: 'n5',
        type: _NotifType.dispute,
        title: 'تم حل النزاع',
        subtitle: 'النزاع #LQ-8C3E — تم إغلاقه لصالحك',
        relativeTime: 'أمس',
        routePath: '/orders/LQ-8C3E',
        isRead: true,
      ),
      _Notif(
        id: 'n6',
        type: _NotifType.order,
        title: 'تم تسليم طلبك',
        subtitle: 'طلب #LQ-3B1A — حذاء نايكي رياضي',
        relativeTime: 'أمس',
        routePath: '/orders/LQ-3B1A',
        isRead: true,
      ),
      _Notif(
        id: 'n7',
        type: _NotifType.auction,
        title: 'انتهت مزايدتك',
        subtitle: 'ساعة أوميغا — تجاوزك أحد المزايدين',
        relativeTime: 'منذ يومين',
        routePath: '/mazadat',
        isRead: true,
      ),
      _Notif(
        id: 'n8',
        type: _NotifType.escrow,
        title: 'طلب تأكيد الاستلام',
        subtitle: 'طلب #LQ-9F7C — يرجى تأكيد الاستلام',
        relativeTime: 'منذ يومين',
        isRead: true,
      ),
    ];

// ── Page ──────────────────────────────────────────────────────────────────────

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late List<_Notif> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = _buildMockNotifs();
  }

  bool get _allRead => _notifs.every((n) => n.isRead);

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.isRead = true;
      }
    });
  }

  List<_Notif> get _today =>
      _notifs.where((n) => n.relativeTime.contains('ساعات') || n.relativeTime == 'منذ ساعتين').toList();

  List<_Notif> get _earlier =>
      _notifs.where((n) => !_today.contains(n)).toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            'الإشعارات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          actions: [
            if (!_allRead)
              TextButton(
                onPressed: _markAllRead,
                child: Text(
                  'تحديد الكل كمقروء',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
          ],
        ),
        body: _allRead && _notifs.isEmpty
            ? _buildEmpty()
            : ListView(
                padding: EdgeInsets.only(bottom: 100.h),
                children: [
                  if (_today.isNotEmpty) ...[
                    _buildGroupHeader('اليوم'),
                    ..._today.map((n) => _NotifTile(
                          notif: n,
                          onTap: () => _handleTap(context, n),
                        )),
                  ],
                  if (_earlier.isNotEmpty) ...[
                    _buildGroupHeader('سابقاً'),
                    ..._earlier.map((n) => _NotifTile(
                          notif: n,
                          onTap: () => _handleTap(context, n),
                        )),
                  ],
                ],
              ),
      ),
    );
  }

  void _handleTap(BuildContext context, _Notif notif) {
    setState(() => notif.isRead = true);
    if (notif.routePath != null) {
      context.push(notif.routePath!);
    }
  }

  Widget _buildGroupHeader(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 36.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إشعارات',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ستظهر إشعاراتك هنا عند وصولها',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _iconFor(notif.type);
    final iconColor = _colorFor(notif.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isRead
            ? Colors.transparent
            : AppTheme.primary.withValues(alpha: 0.04),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: notif.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    notif.subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notif.relativeTime,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppTheme.inactive,
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

  IconData _iconFor(_NotifType type) {
    switch (type) {
      case _NotifType.order:
        return Icons.local_shipping_outlined;
      case _NotifType.auction:
        return Icons.gavel_rounded;
      case _NotifType.escrow:
        return Icons.account_balance_wallet_outlined;
      case _NotifType.dispute:
        return Icons.shield_outlined;
      case _NotifType.message:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Color _colorFor(_NotifType type) {
    switch (type) {
      case _NotifType.order:
        return AppTheme.matajirBlue;
      case _NotifType.auction:
        return AppTheme.mustamalOrange;
      case _NotifType.escrow:
        return AppTheme.success;
      case _NotifType.dispute:
        return AppTheme.ballaPurple;
      case _NotifType.message:
        return AppTheme.primary;
    }
  }
}
