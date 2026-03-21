import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../cart/presentation/cubit/balla_cart_cubit.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/shop_models.dart';

// ── Balla Theme constants ────────────────────────────────────────────────────

const _kBg            = Color(0xFFF5F0FF);
const _kSurface       = Color(0xFFFFFFFF);
const _kPurpleSurface = Color(0xFFEDE0FF);
const _kPurple        = Color(0xFF7C3AED);
const _kGold          = Color(0xFFFFB800);
const _kBorder        = Color(0xFFD8D0E8);
const _kTextPrimary   = Color(0xFF1C1713);
const _kTextSecondary = Color(0xFF6B5E52);
const _kTextTertiary  = Color(0xFFA89585);

// ── Unit enum ────────────────────────────────────────────────────────────────

enum _BallaUnit { kilo, piece, bundle }

extension _BallaUnitX on _BallaUnit {
  String get label {
    switch (this) {
      case _BallaUnit.kilo:   return 'كيلو';
      case _BallaUnit.piece:  return 'قطعة';
      case _BallaUnit.bundle: return 'حزمة';
    }
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class BallaProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const BallaProductDetailsPage({super.key, required this.product});

  @override
  State<BallaProductDetailsPage> createState() =>
      _BallaProductDetailsPageState();
}

class _BallaProductDetailsPageState extends State<BallaProductDetailsPage> {
  int _currentImageIndex = 0;
  _BallaUnit _selectedUnit = _BallaUnit.kilo;
  int _quantity = 1;
  bool _isBookmarked = false;
  bool _infoExpanded = false;
  final PageController _pageController = PageController();

  // ── Pricing ───────────────────────────────────────────────────────────────

  double get _totalPrice => widget.product.price;

  /// Derived kilo price assuming a 25 kg bale weight.
  double get _kiloPrice => widget.product.price / 25;

  /// Approximate piece price (kilo / 2).
  double get _piecePrice => _kiloPrice / 2;

  double get _unitPrice {
    switch (_selectedUnit) {
      case _BallaUnit.kilo:   return _kiloPrice;
      case _BallaUnit.piece:  return _piecePrice;
      case _BallaUnit.bundle: return widget.product.price;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildScrollContent(),
          _buildAppBar(),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: topPad + 6.h,
          bottom: 8.h,
          left: 12.w,
          right: 12.w,
        ),
        color: _kBg,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back arrow
            _CircleBtn(
              icon: Icons.arrow_forward_rounded,
              onTap: () => context.pop(),
            ),
            // Share + Favorite icons
            Row(
              children: [
                _CircleBtn(icon: Icons.share_outlined, onTap: () {}),
                SizedBox(width: 8.w),
                _CircleBtn(
                  icon: _isBookmarked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isBookmarked ? Colors.redAccent : null,
                  onTap: () =>
                      setState(() => _isBookmarked = !_isBookmarked),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Scroll body ───────────────────────────────────────────────────────────

  Widget _buildScrollContent() {
    final topPad = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Space for app bar
          SizedBox(height: topPad + 56.h),

          // Image carousel
          _buildImageCarousel(),

          SizedBox(height: 16.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              widget.product.name,
              style: GoogleFonts.tajawal(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
                height: 1.35,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Price breakdown card
          _buildPriceCard(),

          SizedBox(height: 12.h),

          // Unit selector pill chips
          _buildUnitSelector(),

          SizedBox(height: 12.h),

          // Quantity row
          _buildQuantityRow(),

          SizedBox(height: 12.h),

          // Supplier card
          _buildSupplierCard(),

          SizedBox(height: 12.h),

          // Info section (expandable)
          _buildInfoSection(),

          SizedBox(height: 16.h),

          // Similar bales
          _buildSimilarBales(),

          // Bottom padding for sticky footer
          SizedBox(height: 100.h + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // ── Image Carousel ────────────────────────────────────────────────────────

  Widget _buildImageCarousel() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : ['https://placehold.co/800x600/EDE0FF/7C3AED/png?text=بالة'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image pages
          SizedBox(
            height: 260.h,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) => CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, p2) => Container(
                      color: _kPurpleSurface,
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 48.sp,
                          color: _kPurple.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    errorWidget: (_, p2, p3) => Container(
                      color: _kPurpleSurface,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48.sp,
                          color: _kPurple.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),

                // "بالة" purple pill badge — top-start (RTL: visually top-left)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _kPurple,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Text(
                      'بالة',
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dot page indicators
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: active ? 18.w : 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: active
                        ? _kPurple
                        : _kPurple.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Price Breakdown Card ──────────────────────────────────────────────────

  Widget _buildPriceCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kPurpleSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'السعر الإجمالي',
                style: GoogleFonts.tajawal(
                  fontSize: 13.sp,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                IqdFormatter.format(_totalPrice),
                style: GoogleFonts.tajawal(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: _kPurple,
                  height: 1.1,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(height: 1, color: _kPurple.withValues(alpha: 0.12)),
          SizedBox(height: 10.h),

          // Kilo price
          _PriceRow(
            label: 'سعر الكيلو',
            value: '${IqdFormatter.format(_kiloPrice)}/كغم',
          ),

          SizedBox(height: 6.h),

          // Piece price
          _PriceRow(
            label: 'سعر القطعة (تقريبي)',
            value: '${IqdFormatter.format(_piecePrice)}/قطعة',
          ),
        ],
      ),
    );
  }

  // ── Unit Selector — pill chips ────────────────────────────────────────────

  Widget _buildUnitSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: _BallaUnit.values.map((unit) {
          final selected = _selectedUnit == unit;
          final isLast = unit == _BallaUnit.values.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isLast ? 0 : 6.w),
              child: GestureDetector(
                onTap: () => setState(() => _selectedUnit = unit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected ? _kPurple : _kSurface,
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(
                      color: _kPurple,
                      width: selected ? 0 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unit.label,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _kPurple,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Quantity Row ──────────────────────────────────────────────────────────

  Widget _buildQuantityRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus (−)
            _QtyButton(
              icon: Icons.remove_rounded,
              onTap: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
            ),

            // Count centered
            SizedBox(
              width: 72.w,
              child: Text(
                '$_quantity',
                style: GoogleFonts.tajawal(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Plus (+)
            _QtyButton(
              icon: Icons.add_rounded,
              filled: true,
              onTap: () => setState(() => _quantity++),
            ),
          ],
        ),
      ),
    );
  }

  // ── Supplier Card ─────────────────────────────────────────────────────────

  Widget _buildSupplierCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Warehouse icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _kPurpleSurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.warehouse_rounded,
              size: 26.sp,
              color: _kPurple,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + verified badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'مستودع الأمانة للجملة',
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.verified_rounded,
                      size: 15.sp,
                      color: _kPurple,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Stars + reviews + divider + bales count chip
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14.sp, color: _kGold),
                    SizedBox(width: 3.w),
                    Text(
                      '4.9',
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '(٢٣٠ تقييم)',
                      style: GoogleFonts.tajawal(
                        fontSize: 11.sp,
                        color: _kTextSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(width: 1, height: 12.h, color: _kBorder),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Text(
                        '٣٥ بالة معروضة',
                        style: GoogleFonts.tajawal(
                          fontSize: 10.sp,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_left_rounded,
            size: 20.sp,
            color: _kTextTertiary,
          ),
        ],
      ),
    );
  }

  // ── Expandable Info Section ───────────────────────────────────────────────

  Widget _buildInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Header / toggle
          GestureDetector(
            onTap: () => setState(() => _infoExpanded = !_infoExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: _kPurple,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'معلومات البالة',
                    style: GoogleFonts.tajawal(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _infoExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: _kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: _kBorder),
                  SizedBox(height: 12.h),
                  const _InfoDetailRow(label: 'المنشأ', value: 'أوروبا (ألمانيا)'),
                  SizedBox(height: 8.h),
                  _InfoDetailRow(
                    label: 'المحتوى',
                    value: widget.product.description ??
                        'ملابس نسائية مشكلة — جاكيتات، بلوفرات، فساتين',
                  ),
                  SizedBox(height: 8.h),
                  const _InfoDetailRow(label: 'الحالة', value: 'نخب أول — Grade A'),
                  SizedBox(height: 8.h),
                  const _InfoDetailRow(label: 'الوزن التقريبي', value: '٢٥ كغم/بالة'),
                  SizedBox(height: 8.h),
                  const _InfoDetailRow(
                    label: 'عدد القطع',
                    value: '٤٠–٦٠ قطعة/بالة',
                  ),
                ],
              ),
            ),
            crossFadeState: _infoExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ── Similar Bales ─────────────────────────────────────────────────────────

  Widget _buildSimilarBales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بالات مشابهة',
                style: GoogleFonts.tajawal(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _kPurple,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        SizedBox(
          height: 160.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, i) => SizedBox(width: 10.w),
            itemBuilder: (context, i) => _SimilarBaleCard(index: i),
          ),
        ),
      ],
    );
  }

  // ── Sticky Footer ─────────────────────────────────────────────────────────

  Widget _buildStickyFooter() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomPad),
        decoration: BoxDecoration(
          color: _kSurface,
          border: const Border(top: BorderSide(color: _kBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<BallaCartCubit, CartState>(
          builder: (ctx, cartState) {
            final inCart = cartState.isInCart(widget.product.id);
            return Row(
              children: [
                // Selected unit label + price
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedUnit.label,
                      style: GoogleFonts.tajawal(
                        fontSize: 11.sp,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      IqdFormatter.format(_unitPrice * _quantity),
                      style: GoogleFonts.tajawal(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: _kPurple,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 12.w),

                // "إضافة للسلة" full-width purple pill button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ctx
                          .read<BallaCartCubit>()
                          .addToCart(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            inCart
                                ? 'تم تحديث السلة'
                                : 'تمت الإضافة إلى السلة',
                            style: GoogleFonts.tajawal(),
                            textDirection: TextDirection.rtl,
                          ),
                          backgroundColor: _kPurple,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: inCart ? AppTheme.ballaPurpleSurface : _kPurple,
                        borderRadius: BorderRadius.circular(99.r),
                        border: inCart
                            ? Border.all(color: _kPurple, width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        inCart ? 'موجود في السلة ✓' : 'إضافة للسلة',
                        style: GoogleFonts.tajawal(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: inCart ? _kPurple : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _CircleBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: _kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18.sp, color: color ?? _kTextPrimary),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: filled ? _kPurple : _kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: filled ? _kPurple : _kBorder),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: filled ? Colors.white : _kTextPrimary,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12.sp,
            color: _kTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _kTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 12.sp,
              color: _kTextTertiary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarBaleCard extends StatelessWidget {
  final int index;

  const _SimilarBaleCard({required this.index});

  static const _titles = [
    'بالة ملابس رجالية',
    'بالة أطفال شتوية',
    'بالة ملابس مشكلة',
  ];

  static const _prices = [95000.0, 85000.0, 110000.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130.w,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder
          Container(
            height: 90.h,
            color: _kPurpleSurface,
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 32.sp,
                color: _kPurple.withValues(alpha: 0.4),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titles[index % _titles.length],
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  IqdFormatter.format(_prices[index % _prices.length]),
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _kPurple,
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
