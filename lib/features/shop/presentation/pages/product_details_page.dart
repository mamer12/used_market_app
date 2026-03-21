import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../data/models/shop_models.dart';

// ── Theme constants (Matajir Clean Light) ─────────────────────────────────
const Color _kBg            = Color(0xFFFAFAFA);
const Color _kSurface       = Color(0xFFFFFFFF);
const Color _kBorder        = Color(0xFFEDE6DC);
const Color _kBlue          = Color(0xFF1B4FD8);
const Color _kBlueSurface   = Color(0xFFEBF0FE);
const Color _kGreen         = Color(0xFF00B37E);
const Color _kEscrowGreen   = Color(0xFF059669);
const Color _kTextPrimary   = Color(0xFF1C1713);
const Color _kTextSecondary = Color(0xFF6B5E52);
const Color _kTextTertiary  = Color(0xFFA89585);
const Color _kDiscountRed   = Color(0xFF812800);
const Color _kDiscountBg    = Color(0xFFFFDBCF);

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentImageIndex = 0;
  bool _isWishlisted     = false;
  bool _descExpanded     = false;
  bool _specsExpanded    = false;
  int  _quantity         = 1;
  int  _selectedColor    = 0;
  int  _selectedSize     = 0;

  // Mock colour swatches for demo
  static const List<Color> _colorSwatches = [
    Color(0xFF1C1713),
    Color(0xFF1B4FD8),
    Color(0xFF059669),
  ];

  static const List<String> _sizes = ['قياسي', 'كبير (Pro)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildScrollBody(),
          _buildAppBar(),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: _kSurface,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 4.h,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back arrow (RTL → forward arrow)
              _AppBarButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () => context.pop(),
              ),
              Row(
                children: [
                  _AppBarButton(
                    icon: Icons.share_outlined,
                    onTap: () {},
                  ),
                  SizedBox(width: 8.w),
                  _AppBarButton(
                    icon: _isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    onTap: () =>
                        setState(() => _isWishlisted = !_isWishlisted),
                    iconColor:
                        _isWishlisted ? AppTheme.error : _kTextPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Scrollable body ──────────────────────────────────────────────────────

  Widget _buildScrollBody() {
    final topPad =
        MediaQuery.of(context).padding.top + 56.h; // appbar height
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPad),
          _buildImageCarousel(),
          _buildPriceAndEscrow(),
          _buildProductTitle(),
          _buildRatingRow(),
          _buildColorSelector(),
          _buildSizeSelector(),
          _buildShopCard(),
          _buildDescriptionSection(),
          _buildSpecsAccordion(),
          _buildReviewsSection(),
          _buildSimilarProducts(),
          SizedBox(height: 110.h), // sticky footer clearance
        ],
      ),
    );
  }

  // ── Image Carousel ───────────────────────────────────────────────────────

  Widget _buildImageCarousel() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : ['https://placehold.co/800x800/png'];

    return Stack(
      children: [
        Container(
          height: 280.h,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, i) => CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (ctx, url, err) => Container(
                color: _kBorder,
                child: Icon(Icons.image_not_supported_outlined,
                    color: _kTextTertiary, size: 48.sp),
              ),
            ),
          ),
        ),

        // Discount badge — top-left (in RTL this is top-start)
        Positioned(
          top: 12.h,
          right: 12.w,
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _kDiscountBg,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Text(
              '-٣٠٪',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: _kDiscountRed,
              ),
            ),
          ),
        ),

        // Page dots
        if (images.length > 1)
          Positioned(
            bottom: 14.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 20.w : 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: active
                        ? _kBlue
                        : _kBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // ── Price Row + Escrow Badge ─────────────────────────────────────────────

  Widget _buildPriceAndEscrow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                IqdFormatter.format(widget.product.price),
                style: GoogleFonts.cairo(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: _kBlue,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                // Fictional original price: price / 0.7
                IqdFormatter.format(widget.product.price / 0.7),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: _kTextTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Escrow badge
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _kEscrowGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: _kEscrowGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _kEscrowGreen,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'مضمون',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  AppLocalizations.of(context).escrowProtectionText,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: _kEscrowGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Title ─────────────────────────────────────────────────────────

  Widget _buildProductTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Text(
        widget.product.name,
        style: GoogleFonts.cairo(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _kTextPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  // ── Rating Row ────────────────────────────────────────────────────────────

  Widget _buildRatingRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Row(
        children: [
          ...List.generate(5, (i) {
            final filled = i < 4;
            return Icon(
              filled ? Icons.star_rounded : Icons.star_half_rounded,
              color: const Color(0xFFF59E0B),
              size: 18.sp,
            );
          }),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () {},
            child: Text(
              '(١٢٣ تقييم)',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: _kBlue,
                decoration: TextDecoration.underline,
                decorationColor: _kBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Color Selector ────────────────────────────────────────────────────────

  Widget _buildColorSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر اللون',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: List.generate(_colorSwatches.length, (i) {
              final selected = i == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = i),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  margin: EdgeInsetsDirectional.only(end: 12.w),
                  decoration: BoxDecoration(
                    color: _colorSwatches[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kBlue : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _kBlue.withValues(alpha: 0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Size Selector ─────────────────────────────────────────────────────────

  Widget _buildSizeSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحجم',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: List.generate(_sizes.length, (i) {
              final selected = i == _selectedSize;
              return GestureDetector(
                onTap: () => setState(() => _selectedSize = i),
                child: Container(
                  margin: EdgeInsetsDirectional.only(end: 10.w),
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                        selected ? _kBlue : _kSurface,
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(
                      color: selected ? _kBlue : _kBorder,
                    ),
                  ),
                  child: Text(
                    _sizes[i],
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : _kTextPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Shop Card ─────────────────────────────────────────────────────────────

  Widget _buildShopCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shop avatar
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _kBlueSurface,
              shape: BoxShape.circle,
              border: Border.all(color: _kBorder),
            ),
            child: Icon(Icons.storefront_rounded,
                color: _kBlue, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'متجر التقنية',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.verified_rounded,
                        color: _kGreen, size: 16.sp),
                  ],
                ),
                Text(
                  '٥.٢ ألف متابع',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: _kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _OutlineChip(
                label: 'متابعة',
                color: _kBlue,
                onTap: () {},
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'زيارة المتجر',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: _kBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: _kBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Description (Expandable) ──────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    final fullText = widget.product.description ??
        'يتميز هذا المنتج بجودة عالية وتصميم عصري يناسب جميع الاحتياجات. '
            'توفر سماعات البلوتوث هذه تجربة صوتية استثنائية مع تقنية إلغاء الضجيج '
            'النشطة، مما يجعلها مثالية للاستخدام في بيئات مختلفة.';
    const maxLines = 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'وصف المنتج'),
          SizedBox(height: 10.h),
          Text(
            fullText,
            maxLines: _descExpanded ? null : maxLines,
            overflow: _descExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: _kTextSecondary,
              height: 1.65,
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () =>
                setState(() => _descExpanded = !_descExpanded),
            child: Text(
              _descExpanded ? 'عرض أقل' : 'قراءة المزيد',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Specifications Accordion ──────────────────────────────────────────────

  Widget _buildSpecsAccordion() {
    final specs = [
      ('بلوتوث', '5.2'),
      ('عمر البطارية', '٤٠ ساعة'),
      ('وقت الشحن', '١.٥ ساعة'),
      ('الوزن', '٢٥٠ جرام'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _specsExpanded = !_specsExpanded),
            child: Row(
              children: [
                const Expanded(child: _SectionHeader(title: 'المواصفات الفنية')),
                Icon(
                  _specsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _kTextSecondary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
          if (_specsExpanded) ...[
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < specs.length; i++) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            specs[i].$1,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: _kTextSecondary,
                            ),
                          ),
                          Text(
                            specs[i].$2,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < specs.length - 1)
                      Divider(
                          height: 1,
                          color: _kBorder,
                          indent: 16.w,
                          endIndent: 16.w),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Reviews Section ───────────────────────────────────────────────────────

  Widget _buildReviewsSection() {
    final reviews = [
      (
        'أحمد الكريم',
        'منتج رائع وجودة ممتازة، وصل بسرعة والتغليف كان محكماً',
        '٣ أيام',
        5,
      ),
      (
        'سارة محمد',
        'سماعات ممتازة وصوت نقي جداً، إلغاء الضجيج يعمل بشكل مثالي',
        'أسبوع',
        4,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'التقييمات'),
          SizedBox(height: 12.h),
          // Aggregate score
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _kBlueSurface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      '4.5',
                      style: GoogleFonts.cairo(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: _kBlue,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < 4
                              ? Icons.star_rounded
                              : Icons.star_half_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 14.sp,
                        ),
                      ),
                    ),
                    Text(
                      '١٢٣ تقييم',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: _kTextSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final fill =
                          star == 5 ? 0.7 : star == 4 ? 0.2 : 0.03;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            Text(
                              '$star',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: _kTextSecondary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(99.r),
                                child: LinearProgressIndicator(
                                  value: fill,
                                  minHeight: 6.h,
                                  backgroundColor: _kBorder,
                                  valueColor:
                                      const AlwaysStoppedAnimation<
                                          Color>(
                                    Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          ...reviews.map((r) => _ReviewCard(
                name:    r.$1,
                body:    r.$2,
                timeAgo: r.$3,
                rating:  r.$4,
              )),
        ],
      ),
    );
  }

  // ── Similar Products ──────────────────────────────────────────────────────

  Widget _buildSimilarProducts() {
    // Using demo mock cards; replace with real data when API is available
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const _SectionHeader(title: 'منتجات مشابهة'),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 190.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (_, i) => _SimilarProductCard(
                price: widget.product.price * (0.8 + i * 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky Footer ─────────────────────────────────────────────────────────

  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16.w,
          12.h,
          16.w,
          MediaQuery.of(context).padding.bottom + 12.h,
        ),
        decoration: BoxDecoration(
          color: _kSurface,
          border: const Border(top: BorderSide(color: _kBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity selector (right side in RTL = leading)
            Container(
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () =>
                        setState(() => _quantity++),
                  ),
                  SizedBox(
                    width: 32.w,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<MatajirCartCubit>()
                      .addToCart(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم الإضافة إلى السلة',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: _kBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  shape: const StadiumBorder(),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'أضافة للسلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
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
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: _kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon,
            color: iconColor ?? _kTextPrimary, size: 22.sp),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: _kBlue,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlineChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 18.sp, color: _kTextPrimary),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String body;
  final String timeAgo;
  final int rating;

  const _ReviewCard({
    required this.name,
    required this.body,
    required this.timeAgo,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: _kBlueSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded,
                    color: _kBlue, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    Text(
                      'منذ $timeAgo',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: _kTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            body,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: _kTextSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarProductCard extends StatelessWidget {
  final double price;
  const _SimilarProductCard({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110.h,
            color: _kBorder,
            child: Center(
              child: Icon(Icons.image_outlined,
                  color: _kTextTertiary, size: 32.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'منتج مشابه',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format(price),
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kBlue,
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
