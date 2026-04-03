import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/chat_models.dart';
import '../bloc/chat_cubit.dart';

// ── Avatar palette ────────────────────────────────────────────────────────────

const _kAvatarColors = [
  Color(0xFF0D1F3C),
  Color(0xFF1B4FD8),
  Color(0xFF00BFA5),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
  Color(0xFF059669),
  Color(0xFFC9930A),
];

// ── Page ──────────────────────────────────────────────────────────────────────

/// Full-screen conversations list that connects to the real backend.
/// Route: /conversations
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => getIt<ChatCubit>()..loadConversations(),
      child: const _ConversationsView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _ConversationsView extends StatefulWidget {
  const _ConversationsView();

  @override
  State<_ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<_ConversationsView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'المحادثات',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 22.sp,
                color: AppTheme.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Search ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'بحث في المحادثات...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondary,
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: AppTheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // ── List / States ─────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () =>
                          context.read<ChatCubit>().loadConversations(),
                    );
                  }

                  if (state is ConversationsLoaded) {
                    final items = _query.isEmpty
                        ? state.conversations
                        : state.conversations
                            .where((c) =>
                                (c.otherUserName ?? '')
                                    .contains(_query) ||
                                (c.lastMessage ?? '').contains(_query))
                            .toList();

                    if (items.isEmpty) return const _EmptyState();

                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 32.h),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 76.w,
                        endIndent: 16.w,
                        color: AppTheme.divider,
                      ),
                      itemBuilder: (_, i) => _ConversationTile(
                        conv: items[i],
                        colorIndex: i % _kAvatarColors.length,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
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
                Icons.chat_bubble_outline_rounded,
                size: 36.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا توجد محادثات بعد',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'ابدأ محادثة مع البائع من صفحة المنتج',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48.sp, color: AppTheme.inactive),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
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

// ── Conversation tile ─────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;
  final int colorIndex;

  const _ConversationTile({required this.conv, required this.colorIndex});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return DateFormat('dd/MM', 'ar').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.unreadCount > 0;
    final avatarColor = _kAvatarColors[colorIndex];
    final name = conv.otherUserName ?? '';
    final initial = name.isNotEmpty ? name[0] : 'م';

    return InkWell(
      onTap: () => context.push(
        '/conversations/${conv.id}',
        extra: {
          'sellerName': conv.otherUserName ?? '',
          'contextType': conv.contextType,
          'contextId': conv.contextId,
        },
      ),
      child: Container(
        color: hasUnread
            ? AppTheme.primary.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Avatar + unread badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppTheme.dinarGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${conv.unreadCount}',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name.isNotEmpty ? name : 'مجهول',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(conv.lastMessageAt),
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: hasUnread
                              ? AppTheme.dinarGold
                              : AppTheme.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (conv.contextType != 'general') ...[
                    SizedBox(height: 2.h),
                    Text(
                      _contextLabel(conv.contextType),
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 2.h),
                  Text(
                    conv.lastMessage ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: hasUnread
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight:
                          hasUnread ? FontWeight.w600 : FontWeight.normal,
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

  String _contextLabel(String contextType) {
    switch (contextType) {
      case 'product':
        return 'منتج';
      case 'auction':
        return 'مزاد';
      case 'order':
        return 'طلب';
      default:
        return contextType;
    }
  }
}
