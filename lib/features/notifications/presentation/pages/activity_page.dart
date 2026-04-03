import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../bloc/notification_cubit.dart';

// -- Page --

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

class _ActivityView extends StatefulWidget {
  const _ActivityView();

  @override
  State<_ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<_ActivityView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['الكل', 'طلبات', 'مزادات', 'إشعارات'];

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header --
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppTheme.dinarGold,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'نشاطاتي',
                    style: GoogleFonts.tajawal(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationsLoaded &&
                          state.unreadCount > 0) {
                        return TextButton(
                          onPressed: () =>
                              context.read<NotificationCubit>().markAllRead(),
                          child: Text(
                            'تحديد الكل كمقروء',
                            style: GoogleFonts.tajawal(
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
            ),
            SizedBox(height: 16.h),

            // -- Tab bar --
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // -- Tab content --
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotifList(filter: null),
                  _buildNotifList(filter: 'order'),
                  _buildNotifList(filter: 'auction'),
                  _buildNotifList(filter: null, notificationsOnly: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifList({
    String? filter,
    bool notificationsOnly = false,
  }) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading || state is NotificationInitial) {
          return _buildSkeleton();
        }

        if (state is NotificationError) {
          return _buildError(context);
        }

        if (state is NotificationsLoaded) {
          var notifs = state.notifications;

          // Filter by type
          if (filter != null) {
            notifs = notifs
                .where((n) => (n['type'] as String?) == filter)
                .toList();
          }
          if (notificationsOnly) {
            notifs = notifs
                .where((n) =>
                    (n['type'] as String?) != 'order' &&
                    (n['type'] as String?) != 'auction')
                .toList();
          }

          if (notifs.isEmpty) return _buildEmpty();

          return RefreshIndicator(
            color: AppTheme.dinarGold,
            backgroundColor: AppTheme.primary,
            onRefresh: () async {
              await HapticFeedback.mediumImpact();
              if (context.mounted) {
                await context.read<NotificationCubit>().loadNotifications();
              }
            },
            child: ListView.separated(
              padding: EdgeInsetsDirectional.fromSTEB(
                0,
                0,
                0,
                100.h,
              ),
              itemCount: notifs.length,
              separatorBuilder: (_, _) => Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: const Divider(
                  height: 1,
                  color: AppTheme.divider,
                ),
              ),
              itemBuilder: (_, i) => _ActivityTile(
                notif: notifs[i],
                onTap: () => _handleTap(context, notifs[i]),
              ),
            ),
          );
        }

        return _buildEmpty();
      },
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

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: EdgeInsetsDirectional.all(16.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => Row(
        children: [
          SkeletonCircle(size: 44.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160.w, height: 14.h),
                SizedBox(height: 6.h),
                SkeletonBox(width: 220.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48.sp,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 12.h),
          Text(
            'تعذّر تحميل النشاطات',
            style: GoogleFonts.tajawal(
              fontSize: 15.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () =>
                context.read<NotificationCubit>().loadNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
          ),
        ],
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
              Icons.inbox_rounded,
              size: 36.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نشاطات',
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ستظهر نشاطاتك هنا عند وصولها',
            style: GoogleFonts.tajawal(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Activity tile --

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  const _ActivityTile({required this.notif, required this.onTap});

  String get _title => (notif['title'] as String?) ?? '';
  String get _body => (notif['body'] as String?) ?? '';
  bool get _isRead => notif['is_read'] as bool? ?? true;
  String get _type => (notif['type'] as String?) ?? '';
  String get _timeAgo => (notif['created_at'] as String?) ?? '';

  // Sooq color dot
  Color get _dotColor {
    switch (_type) {
      case 'order':
        return AppTheme.matajirBlue;
      case 'auction':
        return const Color(0xFFFF3D5A);
      case 'escrow':
        return AppTheme.emeraldGreen;
      case 'dispute':
        return AppTheme.ballaPurple;
      case 'message':
        return AppTheme.mustamalOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

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

  String get _statusLabel {
    final status = notif['status'] as String?;
    if (status == null) return '';
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التسليم';
      case 'won':
        return 'فزت!';
      case 'lost':
        return 'خسرت';
      case 'active':
        return 'نشط';
      default:
        return status;
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
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sooq color dot + icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _dotColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, size: 20.sp, color: _dotColor),
                ),
                // Sooq color dot
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp,
                            fontWeight:
                                _isRead ? FontWeight.w600 : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_statusLabel.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _dotColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _statusLabel,
                            style: GoogleFonts.tajawal(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: _dotColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _body,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_timeAgo.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _timeAgo.length > 16
                          ? _timeAgo.substring(0, 16)
                          : _timeAgo,
                      style: GoogleFonts.tajawal(
                        fontSize: 11.sp,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!_isRead)
              Padding(
                padding: EdgeInsetsDirectional.only(start: 8.w, top: 4.h),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.dinarGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
