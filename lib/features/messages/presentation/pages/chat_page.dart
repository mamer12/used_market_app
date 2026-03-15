import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

// ── Mock message model ────────────────────────────────────────────────────────

class _Message {
  final String id;
  final String text;
  final bool isMe;
  final String time;

  const _Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
  });
}

final Map<String, List<_Message>> _mockMessages = {
  '1': [
    const _Message(id: 'm1', text: 'السلام عليكم، هل الآيفون متاح؟', isMe: false, time: '١٠:٠٠ ص'),
    const _Message(id: 'm2', text: 'وعليكم السلام، نعم لا يزال متاحاً', isMe: true, time: '١٠:٠٢ ص'),
    const _Message(id: 'm3', text: 'ما هو السعر الأدنى؟', isMe: false, time: '١٠:٠٣ ص'),
    const _Message(id: 'm4', text: 'السعر ثابت ٩٥٠,٠٠٠ د.ع', isMe: true, time: '١٠:٠٥ ص'),
    const _Message(id: 'm5', text: 'هل المنتج لا يزال متاحاً؟', isMe: false, time: 'الآن'),
  ],
  '2': [
    const _Message(id: 'm1', text: 'مرحباً، تم استلام طلبك', isMe: false, time: '٩:٠٠ ص'),
    const _Message(id: 'm2', text: 'شكراً جزيلاً', isMe: true, time: '٩:٠٥ ص'),
    const _Message(id: 'm3', text: 'تم شحن الطلب وسيصلك خلال يومين', isMe: false, time: '١١:٠٠ ص'),
    const _Message(id: 'm4', text: 'شكراً، تم تأكيد طلبك', isMe: false, time: 'منذ ٢ س'),
  ],
  '3': [
    const _Message(id: 'm1', text: 'اهلاً، هل اللابتوب يعمل بشكل جيد؟', isMe: false, time: 'أمس'),
    const _Message(id: 'm2', text: 'نعم، يعمل بشكل ممتاز', isMe: true, time: 'أمس'),
    const _Message(id: 'm3', text: 'ما هو السعر الأدنى؟', isMe: false, time: 'أمس'),
  ],
  '4': [
    const _Message(id: 'm1', text: 'هل العباءة مقاس L؟', isMe: false, time: 'أمس'),
    const _Message(id: 'm2', text: 'نعم مقاس L', isMe: true, time: 'أمس'),
    const _Message(id: 'm3', text: 'سأتصل بك لاحقاً', isMe: false, time: 'أمس'),
  ],
  '5': [
    const _Message(id: 'm1', text: 'مرحباً، فتحنا نزاعاً بخصوص طلبك', isMe: false, time: 'منذ ٣ أيام'),
    const _Message(id: 'm2', text: 'متى سيتم الحل؟', isMe: true, time: 'منذ ٣ أيام'),
    const _Message(id: 'm3', text: 'نزاعك قيد المراجعة', isMe: false, time: 'منذ ٣ أيام'),
  ],
};

// ── ChatPage ─────────────────────────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const ChatPage({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  late List<_Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(
      _mockMessages[widget.sellerId] ?? [],
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isMe: true,
          time: 'الآن',
        ),
      );
      _inputController.clear();
    });

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
              child: _messages.isEmpty
                  ? _buildEmptyChat()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _BubbleTile(msg: _messages[i]),
                    ),
            ),

            // ── Input bar ──────────────────────────────────────────────────
            _buildInputBar(),
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

  Widget _buildInputBar() {
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
              onSubmitted: (_) => _sendMessage(),
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
            onTap: _sendMessage,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
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
  final _Message msg;

  const _BubbleTile({required this.msg});

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
            bottomLeft: msg.isMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight: msg.isMe ? Radius.circular(4.r) : Radius.circular(16.r),
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
              msg.text,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: msg.isMe ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              msg.time,
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
