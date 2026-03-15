import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/data/models/portal_models.dart';

// ── Mustamal colour tokens ─────────────────────────────────────────────────
const _orange = AppTheme.mustamalOrange;
const _orangeSurface = Color(0xFFFFF8F0);
const _whatsappGreen = Color(0xFF25D366);

// ── Page ───────────────────────────────────────────────────────────────────

class MustamalDetailPage extends StatefulWidget {
  final ItemModel item;
  const MustamalDetailPage({super.key, required this.item});

  @override
  State<MustamalDetailPage> createState() => _MustamalDetailPageState();
}

class _MustamalDetailPageState extends State<MustamalDetailPage> {
  int _currentImage = 0;
  bool _isFavorite = false;
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
            content: Text('تعذّر فتح واتساب', style: GoogleFonts.tajawal()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _callSeller(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذّر الاتصال', style: GoogleFonts.tajawal()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _orangeSurface,
        body: Stack(
          children: [
            _buildScrollContent(l10n),
            _buildTopBar(context),
            _buildStickyFooter(l10n),
          ],
        ),
      ),
    );
  }

  // ── Top Bar (floats over image) ──────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            colors: [Colors.black.withValues(alpha: 0.40), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            _TopBarButton(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () => context.pop(),
            ),
            Expanded(
              child: Text(
                l10n.mustamalDetailTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            _TopBarButton(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
            SizedBox(width: 8.w),
            _TopBarButton(
              icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: _isFavorite ? Colors.red : Colors.white,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isFavorite = !_isFavorite);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Main scroll content ──────────────────────────────────────────────────

  Widget _buildScrollContent(AppLocalizations l10n) {
    final images = widget.item.images.isNotEmpty
        ? widget.item.images
        : ['https://placehold.co/800x800/png'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCarousel(images, l10n),
          // White card with rounded top
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price + negotiable badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              IqdFormatter.format(widget.item.price),
                              style: GoogleFonts.tajawal(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                color: _orange,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _orange.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(
                                color: _orange.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              l10n.mustamalNegotiable,
                              style: GoogleFonts.tajawal(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: _orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // Title
                      Text(
                        widget.item.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Info chips
                      _buildInfoChips(),
                      SizedBox(height: 14.h),
                      // Safety banner
                      _buildSafetyBanner(l10n),
                    ],
                  ),
                ),
                _buildDivider(),
                // Seller card
                _buildSellerCard(l10n),
                _buildDivider(),
                // Description
                _buildDescriptionSection(l10n),
                _buildDivider(),
                // Location / Map
                _buildLocationSection(l10n),
                _buildDivider(),
                // Similar listings
                _buildSimilarListings(l10n),
                SizedBox(height: 130.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carousel ──────────────────────────────────────────────────────────────

  Widget _buildCarousel(List<String> images, AppLocalizations l10n) {
    return SizedBox(
      height: 360.h,
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
              placeholder: (context, url) =>
                  Container(color: AppTheme.inactive.withValues(alpha: 0.15)),
              errorWidget: (context, url, err) => Container(
                color: AppTheme.inactive.withValues(alpha: 0.15),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40.sp,
                  color: AppTheme.inactive,
                ),
              ),
            ),
          ),
          // Report flag
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 58.h,
            start: 16.w,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flag_outlined, color: Colors.white, size: 18.sp),
              ),
            ),
          ),
          // Image counter pill
          Positioned(
            bottom: 14.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${_currentImage + 1}/${images.length} صور',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Dot indicators
          if (images.length > 1)
            Positioned(
              bottom: 46.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _currentImage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 22.w : 6.w,
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
        ],
      ),
    );
  }

  // ── Info Chips ────────────────────────────────────────────────────────────

  Widget _buildInfoChips() {
    final condition = widget.item.condition;
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        _InfoChip(label: l10n.mustamalUsedBadge),
        if (condition != null) _InfoChip(label: _conditionLabel(condition)),
      ],
    );
  }

  // ── Safety Banner ─────────────────────────────────────────────────────────

  Widget _buildSafetyBanner(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: const Color(0xFFD97706), size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              l10n.mustamalSafetyBanner,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Seller Card ───────────────────────────────────────────────────────────

  Widget _buildSellerCard(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.mustamalSellerTitle, accent: _orange),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _orangeSurface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _orange.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                // Avatar with online dot
                Stack(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_rounded, color: _orange, size: 28.sp),
                    ),
                    Positioned(
                      bottom: 1.h,
                      right: 1.w,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                      Row(
                        children: [
                          Text(
                            'بائع خاص',
                            style: GoogleFonts.tajawal(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.verified_rounded,
                              color: Colors.blue, size: 16.sp),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: const Color(0xFFFBBF24), size: 15.sp),
                          SizedBox(width: 3.w),
                          Text(
                            '4.8',
                            style: GoogleFonts.tajawal(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '  •  عضو منذ 2022',
                            style: GoogleFonts.tajawal(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: AppTheme.textSecondary, size: 13.sp),
                          SizedBox(width: 2.w),
                          Text(
                            'بغداد — الكرادة  •  آخر ظهور: منذ ساعة',
                            style: GoogleFonts.tajawal(
                              fontSize: 11.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Description ───────────────────────────────────────────────────────────

  Widget _buildDescriptionSection(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.mustamalDescriptionTitle, accent: _orange),
          SizedBox(height: 10.h),
          Text(
            'قطعة مستعملة بحالة جيدة، تم استخدامها باعتدال. للاستفسار يرجى التواصل عبر واتساب.',
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Location / Map ────────────────────────────────────────────────────────

  Widget _buildLocationSection(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.mustamalLocationTitle, accent: _orange),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: 120.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred map placeholder
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFD1E8FF),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://placehold.co/800x300/D1E8FF/94A3B8?text=Map',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Overlay
                  Container(color: Colors.white.withValues(alpha: 0.15)),
                  // Pin + label
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _orange.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 22.sp),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            'الكرادة، بغداد',
                            style: GoogleFonts.tajawal(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Similar Listings ──────────────────────────────────────────────────────

  Widget _buildSimilarListings(AppLocalizations l10n) {
    // Placeholder cards using the same item as fallback
    final mockImages = [
      'https://placehold.co/400x400/FED7AA/9A3412?text=1',
      'https://placehold.co/400x400/FED7AA/9A3412?text=2',
      'https://placehold.co/400x400/FED7AA/9A3412?text=3',
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 20.w),
            child: Row(
              children: [
                _SectionHeader(
                    title: l10n.mustamalSimilarListings, accent: _orange),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    l10n.homeSeeAll,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 190.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mockImages.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) => _SimilarCard(
                imageUrl: mockImages[index],
                title: widget.item.title,
                price: widget.item.price,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ── Sticky Footer ─────────────────────────────────────────────────────────

  Widget _buildStickyFooter(AppLocalizations l10n) {
    const sellerPhone = '+9647801234567';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w,
            MediaQuery.of(context).padding.bottom + 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary: WhatsApp
            SizedBox(
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _openWhatsApp(sellerPhone);
                },
                icon: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20.sp),
                label: Text(
                  l10n.mustamalContactWhatsapp,
                  style: GoogleFonts.tajawal(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _whatsappGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Secondary: In-app chat + Call
            Row(
              children: [
                Expanded(
                  child: _SecondaryActionButton(
                    icon: Icons.forum_outlined,
                    label: l10n.mustamalInAppChat,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // TODO: navigate to in-app chat
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _SecondaryActionButton(
                    icon: Icons.call_outlined,
                    label: l10n.mustamalCallSeller,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _callSeller(sellerPhone);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppLocalizations get l10n => AppLocalizations.of(context);

  Widget _buildDivider() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
    child: const Divider(color: Color(0xFFF0F0F0)),
  );

  String _conditionLabel(String condition) {
    const labels = {
      'new': 'جديد',
      'like_new': 'كالجديد',
      'excellent': 'ممتاز',
      'good': 'حالة جيدة',
      'fair': 'مقبول',
      'poor': 'يحتاج إصلاح',
    };
    return labels[condition] ?? condition;
  }
}

// ── Top Bar Button ─────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _TopBarButton({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: iconColor ?? AppTheme.textPrimary),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accent;

  const _SectionHeader({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Info Chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ── Similar Card ───────────────────────────────────────────────────────────

class _SimilarCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final num price;

  const _SimilarCard({
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, err) =>
                  Container(color: AppTheme.inactive.withValues(alpha: 0.15)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  IqdFormatter.format(price),
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Secondary Action Button ────────────────────────────────────────────────

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: _orange.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _orange.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _orange, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
