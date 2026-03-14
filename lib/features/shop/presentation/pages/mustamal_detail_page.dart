import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../home/data/models/portal_models.dart';

// ── Page ──────────────────────────────────────────────────────────────────

class MustamalDetailPage extends StatefulWidget {
  /// The listing item from the Mustamal portal feed.
  final ItemModel item;

  const MustamalDetailPage({super.key, required this.item});

  @override
  State<MustamalDetailPage> createState() => _MustamalDetailPageState();
}

class _MustamalDetailPageState extends State<MustamalDetailPage> {
  static const Color _orange = AppTheme.mustamalOrange;
  static const Color _orangeSurface = AppTheme.mustamalOrangeSurface;

  int _currentImage = 0;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp(String phone) async {
    final message = Uri.encodeComponent(
      'مرحبًا، رأيت إعلانك على لقطة بخصوص "${widget.item.title}"، هل لا يزال متاحًا؟',
    );
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذّر فتح واتساب', style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _orangeSurface,
        body: Stack(
          children: [
            _buildContent(),
            _buildTopBar(),
            _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          bottom: 8.h,
          right: 16.w,
          left: 16.w,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            _topBarButton(
              Icons.arrow_forward_ios_rounded,
              () => context.pop(),
            ),
            const Spacer(),
            _topBarButton(Icons.share_outlined, () {}),
          ],
        ),
      ),
    );
  }

  Widget _topBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.sp, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildContent() {
    final images = widget.item.images.isNotEmpty
        ? widget.item.images
        : ['https://placehold.co/800x800/png'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Photo carousel ───────────────────────────────────────────
          _buildCarousel(images),
          // ── Details card ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBadgesRow(),
                      SizedBox(height: 12.h),
                      Text(
                        widget.item.title,
                        style: GoogleFonts.cairo(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        IqdFormatter.format(widget.item.price),
                        style: GoogleFonts.cairo(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                _buildDescriptionSection(),
                _buildDivider(),
                _buildSellerSection(),
                _buildDivider(),
                _buildLocationSection(),
                SizedBox(height: 120.h), // footer spacing
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<String> images) {
    return SizedBox(
      height: 380.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemBuilder: (_, index) => CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, _) => const _SkeletonBox(),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.inactive.withValues(alpha: 0.15),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40.sp,
                  color: AppTheme.inactive,
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _currentImage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 24.w : 6.w,
                    height: 6.w,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: active ? _orange : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),
            ),
          // Image counter pill
          Positioned(
            top: MediaQuery.of(context).padding.top + 60.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99.r),
              ),
              child: Text(
                '${_currentImage + 1} / ${images.length}',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      children: [
        _badge('مستعمل', _orange, _orange.withValues(alpha: 0.12)),
        if (widget.item.condition != null) ...[
          SizedBox(width: 8.w),
          _badge(
            _conditionLabel(widget.item.condition!),
            AppTheme.textSecondary,
            AppTheme.inactive.withValues(alpha: 0.12),
          ),
        ],
      ],
    );
  }

  Widget _badge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: const Divider(color: Color(0xFFEEEEEE)),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('وصف القطعة'),
          SizedBox(height: 10.h),
          Text(
            'قطعة مستعملة بحالة جيدة، تم استخدامها باعتدال. للاستفسار يرجى التواصل عبر واتساب.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection() {
    // Seller phone placeholder — real data comes from API enrichment
    const sellerPhone = '+9647801234567';

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('معلومات البائع'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: _orange, size: 26.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بائع خاص',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'عضو في لقطة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openWhatsApp(sellerPhone),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'واتساب',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('الموقع'),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: _orange, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'بغداد، العراق',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    const sellerPhone = '+9647801234567';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54.h,
          child: ElevatedButton.icon(
            onPressed: () => _openWhatsApp(sellerPhone),
            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
            label: Text(
              'تواصل عبر واتساب',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _conditionLabel(String condition) {
    const labels = {
      'new': 'جديد',
      'like_new': 'كالجديد',
      'good': 'حالة جيدة',
      'fair': 'مقبول',
      'poor': 'يحتاج إصلاح',
    };
    return labels[condition] ?? condition;
  }
}

// ── Skeleton placeholder ──────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox();

  @override
  Widget build(BuildContext context) {
    return Container(color: AppTheme.inactive.withValues(alpha: 0.15));
  }
}
