import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../bloc/cart_cubit.dart';
import '../cubit/balla_cart_cubit.dart';

class BallaCartPage extends StatelessWidget {
  const BallaCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'سلة البالة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BallaCartCubit, CartState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80.sp,
                    color: AppTheme.inactive,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'سلة البالة فارغة',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalProductsPrice = state.cartItems.fold(
            0.0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );
          final shippingFee = 25000.0;
          final serviceFee = 5000.0;
          final totalAmount = totalProductsPrice + shippingFee + serviceFee;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      // Items List
                      ...state.cartItems.map((item) {
                        return _buildCartItem(context, item);
                      }),

                      SizedBox(height: 16.h),

                      // Logistics Summary Card
                      _buildLogisticsSummary(),

                      SizedBox(height: 16.h),

                      // Order Summary
                      _buildOrderSummary(
                        totalProductsPrice,
                        shippingFee,
                        serviceFee,
                        totalAmount,
                      ),
                    ],
                  ),
                ),
                // Footer Action
                _buildFooterAction(totalAmount),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      item.product.images.isNotEmpty
                          ? item.product.images.first
                          : 'https://placehold.co/400x400/png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${IqdFormatter.format(item.product.price)} / kg',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'الوزن: 50kg', // Mock weight
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppTheme.inactive,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      IqdFormatter.format(item.product.price * item.quantity),
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ballaPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_rounded,
                        size: 20.sp,
                        color: AppTheme.ballaPurple,
                      ),
                      onPressed: () {
                        context.read<BallaCartCubit>().addToCart(item.product);
                      },
                    ),
                    Text(
                      '${item.quantity}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_rounded,
                        size: 20.sp,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        context.read<BallaCartCubit>().updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.error,
                ),
                onPressed: () {
                  // If we want to remove completely, we can loop removeItem or add a removeAll method
                  // For now, removing 1 by 1 or calling clear logic
                  final cubit = context.read<BallaCartCubit>();
                  cubit.removeFromCart(item.product.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildLogisticRow(
            icon: Icons.warehouse_rounded,
            title: 'Warehouse Location',
            subtitle: 'Basra Hub',
          ),
          Divider(
            color: AppTheme.inactive.withValues(alpha: 0.2),
            height: 16.h,
          ),
          _buildLogisticRow(
            icon: Icons.schedule_rounded,
            title: 'Estimated Loading Time',
            subtitle: '2 Business Days',
          ),
          Divider(
            color: AppTheme.inactive.withValues(alpha: 0.2),
            height: 16.h,
          ),
          _buildLogisticRow(
            icon: Icons.local_shipping_rounded,
            title: 'Shipping Method',
            subtitle: 'Ground Freight (Bulk)',
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppTheme.ballaPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppTheme.ballaPurple, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    double totalProductsPrice,
    double shippingFee,
    double serviceFee,
    double totalAmount,
  ) {
    return Container(
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
            'ملخص الطلب',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            'سعر المنتج',
            IqdFormatter.format(totalProductsPrice),
          ),
          _buildSummaryRow(
            'رسوم الشحن على الوزن',
            IqdFormatter.format(shippingFee),
          ),
          _buildSummaryRow('رسوم الخدمة', IqdFormatter.format(serviceFee)),
          Divider(
            color: AppTheme.inactive.withValues(alpha: 0.2),
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                IqdFormatter.format(totalAmount),
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction(double totalAmount) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Proceed to Checkout API logic usually goes here
              // For demonstration, navigate to unified checkout or dummy success
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ballaPurple,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              shadowColor: AppTheme.ballaPurple.withValues(alpha: 0.4),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'إتمام الشراء للجملة (Proceed)',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: AppTheme.textSecondary,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'تسوق آمن ومضمون عبر Luqta Balla',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
