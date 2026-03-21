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

class BallaProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const BallaProductDetailsPage({super.key, required this.product});

  @override
  State<BallaProductDetailsPage> createState() =>
      _BallaProductDetailsPageState();
}

class _BallaProductDetailsPageState extends State<BallaProductDetailsPage> {
  int _currentImageIndex = 0;
  int _selectedUnit = 0; // 0=بالكيلو, 1=بالقطعة, 2=بالحزمة
  int _quantity = 1;
  bool _isBookmarked = false;
  final PageController _pageController = PageController();

  static const _units = ['بالكيلو', 'بالقطعة', 'بالحزمة'];

  double get _totalPrice => widget.product.price * _quantity;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Stack(
        children: [
          _buildScrollContent(),
          _buildHeader(),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          bottom: 8.h,
          left: 16.w,
          right: 16.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.ballaPurple.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HeaderBtn(
              icon: Icons.arrow_forward_rounded,
              onTap: () => context.pop(),
            ),
            Text(
              'تفاصيل عرض البالة',
              style: GoogleFonts.cairo(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Row(
              children: [
                _HeaderBtn(icon: Icons.share_outlined, onTap: () {}),
                SizedBox(width: 8.w),
                _HeaderBtn(
                  icon: _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                  color: _isBookmarked ? AppTheme.ballaPurple : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 64.h),
          _buildImageGallery(),
          _buildProductInfo(),
          _buildUnitSelector(),
          _buildQuantityCalculator(),
          _buildConditionBars(),
          _buildSellerCard(),
          _buildLocationInfo(),
          _buildDescription(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : ['https://placehold.co/800x800/png'];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppTheme.ballaPurple.withValues(alpha: 0.06),
                  ),
                );
              },
            ),
          ),
          // Dot indicators
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: active ? 20.w : 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.ballaPurple
                        : AppTheme.ballaPurple.withValues(alpha: 0.25),
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

  Widget _buildProductInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Wrap(
            spacing: 8.w,
            children: [
              const _Badge(label: 'بالجملة', color: AppTheme.ballaPurple),
              _Badge(
                label: 'نخب أول Grade A',
                color: Colors.green.shade600,
              ),
              const _Badge(label: '🇪🇺 استيراد أوروبي', color: AppTheme.textSecondary),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            widget.product.name,
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                IqdFormatter.format(widget.product.price)
                    .replaceAll(' د.ع', ''),
                style: GoogleFonts.cairo(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ballaPurple,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'د.ع / ${_units[_selectedUnit]}',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.ballaPurple.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: List.generate(_units.length, (i) {
          final selected = _selectedUnit == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedUnit = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.ballaPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  _units[i],
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuantityCalculator() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الكمية',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  _QtyBtn(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _QtyBtn(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _quantity++),
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppTheme.inactive.withValues(alpha: 0.1)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                IqdFormatter.format(_totalPrice),
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ballaPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBars() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة البضاعة',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          const _ConditionBar(label: 'النظافة', value: 0.9),
          SizedBox(height: 10.h),
          const _ConditionBar(label: 'الجودة', value: 0.85),
          SizedBox(height: 10.h),
          const _ConditionBar(label: 'الاكتمال', value: 0.95),
        ],
      ),
    );
  }

  Widget _buildSellerCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppTheme.ballaPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.warehouse_rounded,
              size: 28.sp,
              color: AppTheme.ballaPurple,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'مستودع البصرة الاستثماري',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.verified_rounded,
                      color: AppTheme.ballaPurple,
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'تاجر جملة موثق • 4.8 ★',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: AppTheme.inactive),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const _InfoRow(icon: Icons.location_on_rounded, label: 'مكان الحمولة', value: 'البصرة، العراق'),
          Divider(height: 20.h, color: AppTheme.inactive.withValues(alpha: 0.1)),
          const _InfoRow(icon: Icons.schedule_rounded, label: 'وقت التحميل', value: 'يومين عمل'),
          Divider(height: 20.h, color: AppTheme.inactive.withValues(alpha: 0.1)),
          const _InfoRow(icon: Icons.alt_route_rounded, label: 'نوع الشحن', value: 'شحن بري (TIR)'),
          Divider(height: 20.h, color: AppTheme.inactive.withValues(alpha: 0.1)),
          const _InfoRow(icon: Icons.inventory_rounded, label: 'الكمية المتاحة', value: 'متاح الآن'),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وصف المنتج',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.product.description ??
                'بالات ملابس شتوية نخب أول مختارة بعناية من الأسواق الأوروبية. تحتوي كل بالة على تشكيلة متنوعة من الجاكيتات، البلوفرات، والملابس الصوفية الثقيلة.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add to cart
            Expanded(
              child: BlocBuilder<BallaCartCubit, CartState>(
                builder: (ctx, cartState) {
                  final inCart = cartState.isInCart(widget.product.id);
                  return GestureDetector(
                    onTap: () {
                      ctx.read<BallaCartCubit>().addToCart(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم الإضافة إلى عرض الجملة',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: AppTheme.ballaPurple,
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
                        color: inCart
                            ? AppTheme.ballaPurpleSurface
                            : AppTheme.ballaPurple,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppTheme.ballaPurple,
                          width: inCart ? 1.5 : 0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        inCart ? 'موجود في السلة ✓' : 'أضف للسلة',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: inCart ? AppTheme.ballaPurple : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            // Buy now
            Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'اشتري الآن',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _HeaderBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: color ?? AppTheme.textPrimary, size: 20.sp),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyBtn({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: filled ? AppTheme.ballaPurple : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: filled
                ? AppTheme.ballaPurple
                : AppTheme.inactive.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: filled ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _ConditionBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 – 1.0

  const _ConditionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8.h,
              backgroundColor: AppTheme.ballaPurple.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.ballaPurple),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '${(value * 100).toInt()}%',
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.ballaPurple,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: AppTheme.ballaPurple),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
