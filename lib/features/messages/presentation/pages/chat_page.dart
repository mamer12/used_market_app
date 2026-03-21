import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../chat/data/models/chat_models.dart';
import '../../../chat/presentation/bloc/chat_cubit.dart';

// ── ChatPage ─────────────────────────────────────────────────────────────────

class ChatPage extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const ChatPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => getIt<ChatCubit>()..loadMessages(sellerId),
      child: _ChatView(
        conversationId: sellerId,
        sellerName: sellerName,
      ),
    );
  }
}

// ── Inner view ────────────────────────────────────────────────────────────────

class _ChatView extends StatefulWidget {
  final String conversationId;
  final String sellerName;

  const _ChatView({
    required this.conversationId,
    required this.sellerName,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatCubit cubit) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    cubit.sendMessage(widget.conversationId, text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B4FD8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.sellerName.isNotEmpty
                      ? widget.sellerName[0]
                      : 'م',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sellerName,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'متصل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppTheme.textPrimary,
                size: 22.sp,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Messages list ──────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 40.sp,
                              color: AppTheme.inactive,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: () =>
                                  cubit.loadMessages(widget.conversationId),
                              child: Text(
                                'إعادة المحاولة',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is MessagesLoaded) {
                    if (state.messages.isEmpty) {
                      return _buildEmptyChat();
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (_, i) =>
                          _BubbleTile(msg: state.messages[i]),
                    );
                  }

                  return _buildEmptyChat();
                },
              ),
            ),

            // ── Input bar ──────────────────────────────────────────────────
            _buildInputBar(cubit),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48.sp,
            color: AppTheme.inactive,
          ),
          SizedBox(height: 12.h),
          Text(
            'ابدأ المحادثة',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatCubit cubit) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12.w,
        10.h,
        12.w,
        MediaQuery.of(context).padding.bottom + 10.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(cubit),
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
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _sendMessage(cubit),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bubble tile ───────────────────────────────────────────────────────────────

class _BubbleTile extends StatelessWidget {
  final MessageModel msg;

  const _BubbleTile({required this.msg});

  String _formatTime(DateTime dt) {
    return DateFormat('hh:mm a', 'ar').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8.h,
          left: msg.isMe ? 60.w : 0,
          right: msg.isMe ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: msg.isMe ? AppTheme.matajirBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft:
                msg.isMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight:
                msg.isMe ? Radius.circular(4.r) : Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.body,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: msg.isMe ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(msg.createdAt),
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: msg.isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
