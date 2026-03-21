import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/notification_cubit.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationCubit>()..loadNotifications(),
      child: const _ActivityView(),
    );
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView();

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
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.unreadCount > 0) {
                  return TextButton(
                    onPressed: () =>
                        context.read<NotificationCubit>().markAllRead(),
                    child: Text(
                      'تحديد الكل كمقروء',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading ||
                state is NotificationInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48.sp, color: AppTheme.textSecondary),
                    SizedBox(height: 12.h),
                    Text(
                      'تعذّر تحميل الإشعارات',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NotificationCubit>().loadNotifications(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary),
                      child: Text('إعادة المحاولة',
                          style: GoogleFonts.cairo(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationsLoaded) {
              final notifs = state.notifications;
              if (notifs.isEmpty) return _buildEmpty();

              // Group: today = first 3, earlier = rest (API returns newest first)
              final today = notifs.length > 3 ? notifs.sublist(0, 3) : notifs;
              final earlier =
                  notifs.length > 3 ? notifs.sublist(3) : <Map<String, dynamic>>[];

              return ListView(
                padding: EdgeInsets.only(bottom: 100.h),
                children: [
                  if (today.isNotEmpty) ...[
                    _buildGroupHeader('اليوم'),
                    ...today.map((n) => _NotifTile(
                          notif: n,
                          onTap: () => _handleTap(context, n),
                        )),
                  ],
                  if (earlier.isNotEmpty) ...[
                    _buildGroupHeader('سابقاً'),
                    ...earlier.map((n) => _NotifTile(
                          notif: n,
                          onTap: () => _handleTap(context, n),
                        )),
                  ],
                ],
              );
            }

            return _buildEmpty();
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, Map<String, dynamic> notif) {
    final id = notif['id'] as String?;
    if (id != null) {
      context.read<NotificationCubit>().markRead(id);
    }
    final link = notif['action_url'] as String?;
    if (link != null && link.isNotEmpty) {
      context.push(link);
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
  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.onTap});

  String get _title => (notif['title'] as String?) ?? '';
  String get _body => (notif['body'] as String?) ?? '';
  bool get _isRead => notif['is_read'] as bool? ?? true;
  String get _type => (notif['type'] as String?) ?? '';

  // Map API type → icon & colour
  IconData get _icon {
    switch (_type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'auction':
        return Icons.gavel_rounded;
      case 'escrow':
        return Icons.account_balance_wallet_outlined;
      case 'dispute':
        return Icons.shield_outlined;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (_type) {
      case 'order':
        return AppTheme.matajirBlue;
      case 'auction':
        return AppTheme.mustamalOrange;
      case 'escrow':
        return AppTheme.success;
      case 'dispute':
        return AppTheme.ballaPurple;
      case 'message':
        return AppTheme.primary;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: _isRead
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
                color: _color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 20.sp, color: _color),
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
                          _title,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: _isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!_isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _body,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
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
}
