import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../cubit/group_buy_cubit.dart';
import '../../data/models/group_buy_model.dart';

class GroupBuyPage extends StatelessWidget {
  final String groupBuyId;

  const GroupBuyPage({super.key, required this.groupBuyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GroupBuyCubit>()..fetchGroupBuy(groupBuyId),
      child: _GroupBuyView(groupBuyId: groupBuyId),
    );
  }
}

class _GroupBuyView extends StatefulWidget {
  final String groupBuyId;

  const _GroupBuyView({required this.groupBuyId});

  @override
  State<_GroupBuyView> createState() => _GroupBuyViewState();
}

class _GroupBuyViewState extends State<_GroupBuyView> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _hasJoined = false;

  static const _purple = Color(0xFF7C3AED);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime expiresAt) {
    _timer?.cancel();
    _updateRemaining(expiresAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining(expiresAt);
    });
  }

  void _updateRemaining(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _shareLink() {
    final link = 'madhmoon://group/${widget.groupBuyId}';
    Clipboard.setData(ClipboardData(text: link));
    unawaited(SharePlus.instance.share(ShareParams(text: link, subject: 'انضم إلى الشلة')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0FF),
        appBar: AppBar(
          title: Text(
            'الشلة',
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
        ),
        body: BlocConsumer<GroupBuyCubit, GroupBuyState>(
          listener: (context, state) {
            if (state is GroupBuyLoaded || state is GroupBuyJoined) {
              final gb = state is GroupBuyLoaded
                  ? state.groupBuy
                  : (state as GroupBuyJoined).groupBuy;
              _startCountdown(gb.expiresAt);
              if (state is GroupBuyJoined) {
                setState(() => _hasJoined = true);
              }
            }
            if (state is GroupBuyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GroupBuyLoading) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF7C3AED)),
              );
            }
            if (state is GroupBuyError) {
              return _buildError(context, state.message);
            }
            GroupBuyModel? gb;
            if (state is GroupBuyLoaded) gb = state.groupBuy;
            if (state is GroupBuyJoined) gb = state.groupBuy;
            if (gb == null) return const SizedBox.shrink();
            return _buildContent(context, gb);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GroupBuyModel gb) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          if (gb.productImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: gb.productImageUrl!,
                height: 200.h,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _imagePlaceholder(),
              ),
            )
          else
            _imagePlaceholder(),

          SizedBox(height: 16.h),

          // Product title
          Text(
            gb.productTitle,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Counter card
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
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
            child: Column(
              children: [
                // Large counter
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.cairo(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w900,
                        color: _purple),
                    children: [
                      TextSpan(text: gb.arabicCurrentCount),
                      TextSpan(
                        text: ' من ${gb.arabicTargetCount} انضموا',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: gb.progress.clamp(0.0, 1.0),
                    minHeight: 10.h,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_purple),
                  ),
                ),
                SizedBox(height: 12.h),

                // Discount badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: _purple.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'خصم ${gb.discountPct}٪ عند الاكتمال',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Countdown
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  'الوقت المتبقي',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDuration(_remaining),
                  style: GoogleFonts.cairo(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: _remaining.inMinutes < 60
                        ? Colors.red.shade600
                        : Colors.black87,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Completed state
          if (gb.isCompleted) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '🎉 اكتملت الشلة! ادفع بالسعر المخفض',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Share button
          OutlinedButton.icon(
            onPressed: _shareLink,
            icon: const Icon(Icons.share_outlined),
            label: Text(
              'شارك الرابط',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _purple,
              side: const BorderSide(color: _purple),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
          SizedBox(height: 10.h),

          // Join button
          if (!gb.isCompleted && !_hasJoined)
            ElevatedButton(
              onPressed: () =>
                  context.read<GroupBuyCubit>().joinGroupBuy(gb.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'انضم الآن',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          if (_hasJoined && !gb.isCompleted)
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade600, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'أنت منضم إلى الشلة',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Icon(Icons.group_rounded,
            size: 64.sp, color: const Color(0xFF7C3AED)),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
          SizedBox(height: 12.h),
          Text(message,
              style: GoogleFonts.cairo(
                  fontSize: 14.sp, color: Colors.black54)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context
                .read<GroupBuyCubit>()
                .fetchGroupBuy(widget.groupBuyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: Text('إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
