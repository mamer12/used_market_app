import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/chat_models.dart';
import '../bloc/chat_cubit.dart';

/// Chat room page showing a conversation thread with a recipient.
/// Route: /conversations/:id
class ChatRoomPage extends StatelessWidget {
  final String conversationId;
  final String recipientName;

  const ChatRoomPage({
    super.key,
    required this.conversationId,
    required this.recipientName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => getIt<ChatCubit>()..loadMessages(conversationId),
      child: _ChatRoomView(
        conversationId: conversationId,
        recipientName: recipientName,
      ),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _ChatRoomView extends StatefulWidget {
  final String conversationId;
  final String recipientName;

  const _ChatRoomView({
    required this.conversationId,
    required this.recipientName,
  });

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final body = _inputController.text.trim();
    if (body.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() => _isSending = true);

    try {
      await context
          .read<ChatCubit>()
          .sendMessage(widget.conversationId, body);
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is MessagesLoaded) _scrollToBottom();
                  if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () => context
                          .read<ChatCubit>()
                          .loadMessages(widget.conversationId),
                    );
                  }

                  if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return const _EmptyState();
                    }
                    return _MessageList(
                      messages: state.messages,
                      scrollController: _scrollController,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _InputBar(
              controller: _inputController,
              isSending: _isSending,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final initial = widget.recipientName.isNotEmpty
        ? widget.recipientName[0]
        : 'م';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20.sp,
          color: AppTheme.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.recipientName.isNotEmpty
                  ? widget.recipientName
                  : 'محادثة',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final showTime = i == 0 ||
            messages[i].createdAt
                    .difference(messages[i - 1].createdAt)
                    .inMinutes
                    .abs() >
                10;
        return Column(
          children: [
            if (showTime) _TimeSeparator(dateTime: msg.createdAt),
            _MessageBubble(message: msg),
          ],
        );
      },
    );
  }
}

// ── Time separator ────────────────────────────────────────────────────────────

class _TimeSeparator extends StatelessWidget {
  final DateTime dateTime;

  const _TimeSeparator({required this.dateTime});

  String _label() {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dateTime);
    if (diff.inDays == 1) return 'أمس ${DateFormat('HH:mm').format(dateTime)}';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            _label(),
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.72.sw),
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft:
                isMe ? Radius.circular(4.r) : Radius.circular(18.r),
            bottomRight:
                isMe ? Radius.circular(18.r) : Radius.circular(4.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.body,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: isMe ? Colors.white : AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        MediaQuery.of(context).padding.bottom + 8.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                minLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color:
                    isSending ? AppTheme.primary.withValues(alpha: 0.5) : AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
            ),
          ),
        ],
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
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 32.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد رسائل بعد',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'ابدأ المحادثة بإرسال رسالة',
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
            Icon(Icons.cloud_off_rounded,
                size: 48.sp, color: AppTheme.inactive),
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
