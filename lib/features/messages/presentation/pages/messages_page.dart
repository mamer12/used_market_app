import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

// ── Mock thread model ─────────────────────────────────────────────────────────

class _ChatThread {
  final String id;
  final String name;
  final String avatarInitial;
  final Color avatarColor;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String relatedItem;

  const _ChatThread({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.avatarColor,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.relatedItem,
  });
}

const _mockThreads = [
  _ChatThread(
    id: '1',
    name: 'أبو محمد',
    avatarInitial: 'أ',
    avatarColor: Color(0xFF1B4FD8),
    lastMessage: 'هل المنتج لا يزال متاحاً؟',
    time: 'الآن',
    unreadCount: 3,
    relatedItem: 'آيفون 13 برو - مستعمل',
  ),
  _ChatThread(
    id: '2',
    name: 'متجر الأمل',
    avatarInitial: 'م',
    avatarColor: Color(0xFF00BFA5),
    lastMessage: 'شكراً، تم تأكيد طلبك',
    time: 'منذ ٢ س',
    unreadCount: 0,
    relatedItem: 'طلب #LQ-4A2F',
  ),
  _ChatThread(
    id: '3',
    name: 'علي حسين',
    avatarInitial: 'ع',
    avatarColor: Color(0xFF7C3AED),
    lastMessage: 'ما هو السعر الأدنى؟',
    time: 'أمس',
    unreadCount: 1,
    relatedItem: 'لابتوب ديل - بالة',
  ),
  _ChatThread(
    id: '4',
    name: 'فاطمة الزهراء',
    avatarInitial: 'ف',
    avatarColor: Color(0xFFEA580C),
    lastMessage: 'سأتصل بك لاحقاً',
    time: 'أمس',
    unreadCount: 0,
    relatedItem: 'عباءة بغدادية',
  ),
  _ChatThread(
    id: '5',
    name: 'دعم مضمون',
    avatarInitial: 'د',
    avatarColor: Color(0xFF00BFA5),
    lastMessage: 'نزاعك قيد المراجعة',
    time: 'منذ ٣ أيام',
    unreadCount: 0,
    relatedItem: 'طلب #LQ-8C3E',
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  List<_ChatThread> get _filtered => _query.isEmpty
      ? _mockThreads
      : _mockThreads
          .where((t) =>
              t.name.contains(_query) ||
              t.lastMessage.contains(_query) ||
              t.relatedItem.contains(_query))
          .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.messagesTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.inactive.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'بحث في الرسائل...',
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
                  fillColor: Colors.grey.shade100,
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

            // ── Thread list / empty state ────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty(l10n)
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: 100.h),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 76.w,
                        endIndent: 16.w,
                      ),
                      itemBuilder: (_, i) =>
                          _ThreadTile(thread: _filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
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
              l10n.messagesEmpty,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              l10n.messagesEmptySub,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Thread tile ───────────────────────────────────────────────────────────────

class _ThreadTile extends StatelessWidget {
  final _ChatThread thread;

  const _ThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;

    return InkWell(
      onTap: () {
        context.push(
          '/messages/${thread.id}',
          extra: {'sellerName': thread.name, 'relatedItem': thread.relatedItem},
        );
      },
      child: Container(
        color: hasUnread
            ? AppTheme.primary.withValues(alpha: 0.03)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Unread indicator + avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: thread.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    thread.avatarInitial,
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
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${thread.unreadCount}',
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
                      Text(
                        thread.name,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        thread.time,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: hasUnread
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    thread.relatedItem,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: hasUnread
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
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
