import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../data/models/shop_models.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentImageIndex = 0;
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [_buildContent(), _buildHeader(), _buildStickyFooter()],
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
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.textPrimary,
                    size: 24.sp,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildHeaderButton(Icons.share_outlined, () {}),
                  SizedBox(width: 12.w),
                  _buildHeaderButton(
                    _isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    () {
                      setState(() => _isWishlisted = !_isWishlisted);
                      // context.read<CartCubit>().toggleSaved(widget.product);
                    },
                    color: _isWishlisted ? AppTheme.error : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: color ?? AppTheme.textPrimary, size: 22.sp),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(),
          _buildProductInfo(),
          _buildVendorCard(),
          _buildDescription(),
          _buildSpecifications(),
          SizedBox(height: 120.h), // Footer spacing
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : ['https://placehold.co/800x800/png'];

    return Stack(
      children: [
        SizedBox(
          height: 400.h,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 24.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = index == _currentImageIndex;
                return Container(
                  width: isActive ? 24.w : 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.matajirBlue
                        : AppTheme.matajirBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'متوفر',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 20.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '4.9 (120)',
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
          SizedBox(height: 12.h),
          Text(
            widget.product.name,
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                IqdFormatter.format(
                  widget.product.price,
                ).replaceAll(' د.ع', ''),
                style: AppTheme.priceStyle(
                  fontSize: 32.sp,
                  color: AppTheme.matajirBlue,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'د.ع',
                style: AppTheme.priceSuffixStyle(
                  color: AppTheme.matajirBlue.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.inactive.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 24.sp,
              color: AppTheme.matajirBlue,
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
                      'متجر أبل الرسمي',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.verified_rounded,
                      color: AppTheme.matajirBlue,
                      size: 16.sp,
                    ),
                  ],
                ),
                Text(
                  'بائع موثوق لدى لقطة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.matajirBlue,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              side: const BorderSide(color: AppTheme.matajirBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            child: Text(
              'زيارة المتجر',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('وصف المنتج'),
          SizedBox(height: 12.h),
          Text(
            widget.product.description ??
                'يتميز هذا المنتج بجودة عالية وتصميم عصري يناسب جميع الاحتياجات. تم فحصه بعناية لضمان أفضل تجربة للمستخدم.',
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppTheme.matajirBlue,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    final specs = [
      {'label': 'الذاكرة', 'value': '256 جيجابايت'},
      {'label': 'الرام', 'value': '6 جيجابايت'},
      {'label': 'الشاشة', 'value': '6.7 إنش XDR'},
      {'label': 'اللون', 'value': 'بنفسجي غامق'},
    ];

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: specs.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.matajirBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.matajirBlue.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  specs[index]['label']!.toUpperCase(),
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  specs[index]['value']!,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: AppTheme.divider),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatajirCartCubit>().addToCart(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم الإضافة إلى سلة المتاجر',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: AppTheme.matajirBlue,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.matajirBlue,
                  shape: const StadiumBorder(),
                  minimumSize: Size(double.infinity, 56.h),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'أضف إلى السلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppTheme.matajirBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: AppTheme.matajirBlue,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
