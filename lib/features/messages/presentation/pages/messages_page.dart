import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../chat/data/models/chat_models.dart';
import '../../../chat/presentation/bloc/chat_cubit.dart';

// ── Avatar colors ─────────────────────────────────────────────────────────────

const _kAvatarColors = [
  Color(0xFF1B4FD8),
  Color(0xFF00BFA5),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
  Color(0xFFFF3D5A),
  Color(0xFF059669),
  Color(0xFF0891B2),
];

// ── Page wrapper with BlocProvider ────────────────────────────────────────────

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => getIt<ChatCubit>()..loadConversations(),
      child: const _MessagesView(),
    );
  }
}

// ── Inner view ────────────────────────────────────────────────────────────────

class _MessagesView extends StatefulWidget {
  const _MessagesView();

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  final _searchController = TextEditingController();
  String _query = '';

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
            // ── Header ──────────────────────────────────────────────────
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

            // ── Thread list / states ────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return _buildError(state.message, context);
                  }

                  if (state is ConversationsLoaded) {
                    final filtered = _query.isEmpty
                        ? state.conversations
                        : state.conversations
                            .where((c) =>
                                (c.otherUserName ?? '').contains(_query) ||
                                (c.lastMessage ?? '').contains(_query) ||
                                c.contextType.contains(_query))
                            .toList();

                    if (filtered.isEmpty) return _buildEmpty(l10n);

                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 100.h),
                      itemCount: filtered.length,
                      separatorBuilder: (context, i) => Divider(
                        height: 1,
                        indent: 76.w,
                        endIndent: 16.w,
                      ),
                      itemBuilder: (_, i) => _ConversationTile(
                        conv: filtered[i],
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

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48.sp,
              color: AppTheme.inactive,
            ),
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
              onPressed: () => context.read<ChatCubit>().loadConversations(),
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
      onTap: () {
        context.push(
          '/messages/${conv.id}',
          extra: {
            'sellerName': conv.otherUserName ?? '',
            'relatedItem': conv.contextType,
          },
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
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
                      Text(
                        name,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _formatTime(conv.lastMessageAt),
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
                    conv.contextType,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
