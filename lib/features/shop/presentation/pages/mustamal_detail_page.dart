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
const _bg = Color(0xFFFFF8F5);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFEDE6DC);
const _textPrimary = Color(0xFF1C1713);
const _textSecondary = Color(0xFF6B5E52);
const _textTertiary = Color(0xFFA89585);
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
  bool _descExpanded = false;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp(String phone) async {
    final message = Uri.encodeComponent(
      'مرحبًا، رأيت إعلانك على مضمون بخصوص "${widget.item.title}"، هل لا يزال متاحًا؟',
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
        backgroundColor: _bg,
        appBar: _buildAppBar(context, l10n),
        body: Stack(
          children: [
            _buildScrollContent(l10n),
            _buildStickyFooter(l10n),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _textPrimary,
          size: 20.sp,
        ),
      ),
      title: Text(
        l10n.mustamalDetailTitle,
        style: GoogleFonts.tajawal(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.share_outlined, color: _textPrimary, size: 22.sp),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isFavorite = !_isFavorite);
          },
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? Colors.red : _textPrimary,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 4.w),
      ],
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
          _buildCarousel(images),
          // White content card
          Container(
            color: _surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceRow(),
                      SizedBox(height: 10.h),
                      _buildTitle(),
                      SizedBox(height: 12.h),
                      _buildMetaRow(),
                      SizedBox(height: 12.h),
                      _buildConditionChips(),
                    ],
                  ),
                ),
                _buildDivider(),
                _buildSellerCard(l10n),
                _buildDivider(),
                _buildDescriptionSection(l10n),
                _buildDivider(),
                _buildSafetyTips(),
                _buildDivider(),
                _buildSimilarListings(l10n),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carousel ──────────────────────────────────────────────────────────────

  Widget _buildCarousel(List<String> images) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            child: PageView.builder(
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
          ),
          // Favorite heart overlay top-right — white circle 40px
          PositionedDirectional(
            top: 12.h,
            end: 16.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isFavorite = !_isFavorite);
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorite ? Colors.red : _textSecondary,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          // Dot indicators bottom-center
          if (images.length > 1)
            Positioned(
              bottom: 14.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _currentImage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 20.w : 6.w,
                    height: 6.w,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: active
                          ? _orange
                          : Colors.white.withValues(alpha: 0.7),
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

  // ── Price Row ─────────────────────────────────────────────────────────────

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          IqdFormatter.format(widget.item.price),
          style: GoogleFonts.tajawal(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: _orange,
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: _orange.withValues(alpha: 0.30)),
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
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Text(
      widget.item.title,
      style: GoogleFonts.tajawal(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        height: 1.35,
      ),
    );
  }

  // ── Meta Row (time, location, views) ──────────────────────────────────────

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 14.w,
      runSpacing: 6.h,
      children: [
        _MetaItem(icon: Icons.schedule_rounded, label: 'منذ ٣ ساعات'),
        _MetaItem(
          icon: Icons.location_on_outlined,
          label: widget.item.city ?? 'المنصور، بغداد',
        ),
        _MetaItem(icon: Icons.remove_red_eye_outlined, label: '١٤٢ مشاهدة'),
      ],
    );
  }

  // ── Condition + Category Chips ────────────────────────────────────────────

  Widget _buildConditionChips() {
    final condition = widget.item.condition;
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        // Condition badge — green
        if (condition != null)
          _ConditionBadge(label: _conditionLabel(condition)),
        // Category chip
        if (widget.item.category.isNotEmpty)
          _InfoChip(label: widget.item.category),
      ],
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
              color: _bg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded, color: _orange, size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أحمد محمد الجبوري',
                        style: GoogleFonts.tajawal(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Stars + rating + member since
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 13.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(٤.٨)  •  عضو منذ ٢٠٢١',
                            style: GoogleFonts.tajawal(
                              fontSize: 11.sp,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Listings button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: BorderSide(color: _orange.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'إعلانات (١٢)',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
    const fullDesc =
        'ايفون ١٥ برو ماكس ٢٥٦ جيجابايت بحالة ممتازة، تم استخدامه باعتدال. '
        'الشاشة سليمة تمامًا بدون خدوش، البطارية تعمل بكفاءة عالية. '
        'يأتي مع الكرتون الأصلي وكابل الشحن. للاستفسار يرجى التواصل عبر واتساب.';

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: l10n.mustamalDescriptionTitle, accent: _orange),
          SizedBox(height: 10.h),
          Text(
            _descExpanded ? fullDesc : '${fullDesc.substring(0, 100)}...',
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: _textSecondary,
              height: 1.7,
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'عرض أقل' : 'عرض المزيد',
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Safety Tips ───────────────────────────────────────────────────────────

  Widget _buildSafetyTips() {
    const tips = [
      'التقِ بالبائع في مكان عام ومضاء جيدًا',
      'تحقق من الرقم التسلسلي للجهاز قبل الشراء',
      'لا تحوّل الأموال مسبقًا دون تسلّم البضاعة',
    ];

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _orange.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: _orange, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'نصائح الأمان والتعامل',
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...tips.map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6.h),
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: _orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.tajawal(
                          fontSize: 13.sp,
                          color: _textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Similar Listings ──────────────────────────────────────────────────────

  Widget _buildSimilarListings(AppLocalizations l10n) {
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
                  title: l10n.mustamalSimilarListings,
                  accent: _orange,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'عرض الكل',
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
              separatorBuilder: (_, _x) => SizedBox(width: 12.w),
              itemBuilder: (_, index) => _SimilarCard(
                imageUrl: mockImages[index],
                title: widget.item.title,
                price: widget.item.price,
              ),
            ),
          ),
          SizedBox(height: 16.h),
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
        padding: EdgeInsets.fromLTRB(
          16.w,
          14.h,
          16.w,
          MediaQuery.of(context).padding.bottom + 14.h,
        ),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // WhatsApp button
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _openWhatsApp(sellerPhone);
                  },
                  icon: Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  label: Text(
                    'واتساب',
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
            ),
            SizedBox(width: 12.w),
            // Call button
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _callSeller(sellerPhone);
                  },
                  icon: Icon(Icons.call_outlined, color: _orange, size: 18.sp),
                  label: Text(
                    'اتصال',
                    style: GoogleFonts.tajawal(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _orange,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _orange, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    foregroundColor: _orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  AppLocalizations get l10n => AppLocalizations.of(context);

  Widget _buildDivider() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
    child: const Divider(color: _border),
  );

  String _conditionLabel(String condition) {
    const labels = {
      'new': 'جديد',
      'like_new': 'كالجديد',
      'excellent': 'مستعمل - ممتاز',
      'good': 'مستعمل - جيد',
      'fair': 'مقبول',
      'poor': 'يحتاج إصلاح',
    };
    return labels[condition] ?? condition;
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
            color: const Color(0xFF1C1713),
          ),
        ),
      ],
    );
  }
}

// ── Meta Item ──────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: _textTertiary),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12.sp,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Condition Badge (green) ─────────────────────────────────────────────────

class _ConditionBadge extends StatelessWidget {
  final String label;
  const _ConditionBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF166534),
        ),
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _border),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
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
        border: Border.all(color: _border),
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
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  IqdFormatter.format(price),
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
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
