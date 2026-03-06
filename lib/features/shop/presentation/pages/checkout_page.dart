import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_context.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/order_models.dart';
import '../../data/models/shop_models.dart';
import '../bloc/order_cubit.dart';

class CheckoutPage extends StatefulWidget {
  final List<ProductModel> products;
  final CartCubit? cartCubit;

  const CheckoutPage({super.key, required this.products, this.cartCubit});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedPayment = 'ZAIN_CASH';
  String _fulfillmentType = 'delivery'; // 'delivery' or 'pickup'

  @override
  void dispose() {
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_fulfillmentType == 'delivery' && !_formKey.currentState!.validate()) {
      return;
    }

    final shippingAddress = ShippingAddress(
      city: _cityCtrl.text,
      district: _districtCtrl.text,
      street: _streetCtrl.text,
      building: _buildingCtrl.text,
      phone: _phoneCtrl.text,
    );

    final targetCubit = widget.cartCubit ?? context.read<CartCubit>();
    final appContext = targetCubit is ScopedCartCubit
        ? targetCubit.appContext.apiValue
        : null;

    final request = BuyProductRequest(
      productId: widget.products.first.id,
      quantity: 1,
      shippingAddress: shippingAddress,
      fulfillmentType: _fulfillmentType,
      appContext: appContext,
    );

    unawaited(
      context.read<OrderCubit>().buyProduct(
        request,
        isCOD: _selectedPayment == 'COD',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final num total = widget.products.fold(0, (sum, p) => sum + p.price);

    return BlocProvider(
      create: (context) => getIt<OrderCubit>(),
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state.status == OrderProcessStatus.success) {
            final targetCubit = widget.cartCubit ?? context.read<CartCubit>();
            targetCubit.clearCart();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order placed successfully!',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == OrderProcessStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error ?? 'Order failed',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            final isLoading = state.status == OrderProcessStatus.loading;
            return Scaffold(
              backgroundColor: AppTheme.surface,
              appBar: AppBar(
                title: Text(
                  'Checkout',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                backgroundColor: AppTheme.surface,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: AppTheme.textPrimary),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildOrderSummary(total),
                        SizedBox(height: 32.h),
                        Text(
                          'Fulfillment Method',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFulfillmentOption(
                                'delivery',
                                'Delivery\n(5,000 IQD)',
                                Icons.local_shipping_outlined,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildFulfillmentOption(
                                'pickup',
                                'Pick Up In-Store\n(Free)',
                                Icons.storefront_outlined,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _fulfillmentType == 'delivery'
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          secondChild: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: AppTheme.primary,
                                  size: 28.sp,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Text(
                                    'Your money will be held in Escrow until you scan the shop\'s QR code upon pickup.',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Shipping details',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityCtrl,
                                      label: 'City',
                                      icon: Icons.location_city,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _districtCtrl,
                                      label: 'District',
                                      icon: Icons.map_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      controller: _streetCtrl,
                                      label: 'Street',
                                      icon: Icons.add_road_outlined,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    flex: 1,
                                    child: _buildTextField(
                                      controller: _buildingCtrl,
                                      label: 'Bldg.',
                                      icon: Icons.apartment_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              _buildTextField(
                                controller: _phoneCtrl,
                                label: 'Phone number',
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          'Payment method',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildPaymentOption(
                          'ZAIN_CASH',
                          'ZainCash',
                          Icons.account_balance_wallet_rounded,
                          const Color(0xFFD81B60),
                        ),
                        SizedBox(height: 12.h),
                        _buildPaymentOption(
                          'FIB',
                          'First Iraqi Bank',
                          Icons.account_balance_rounded,
                          const Color(0xFF1976D2),
                        ),
                        SizedBox(height: 12.h),
                        // COD only available for Matajir / Balla — not for auction invoices
                        _buildPaymentOption(
                          'COD',
                          'الدفع عند الاستلام (COD)',
                          Icons.local_shipping_outlined,
                          const Color(0xFF388E3C),
                        ),
                        SizedBox(height: 48.h),
                        _buildSubmitButton(isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary(num total) {
    final hasBalla = widget.products.any((p) => p.isBalla);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Show individual Balla line items with unit format
          if (hasBalla)
            ...widget.products
                .where((p) => p.isBalla)
                .map(
                  (p) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${p.price.toInt()} دينار (1 ${_unitLabel(p.salesUnit)})',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (hasBalla)
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
              margin: EdgeInsets.only(bottom: 12.h),
            ),
          Text(
            'إجمالي الطلب',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${total.toInt() + (_fulfillmentType == 'delivery' ? 5000 : 0)} دينار',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          if (_selectedPayment == 'COD')
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'الدفع عند الاستلام — ادفع للسائق',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: const Color(0xFF388E3C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentOption(String value, String title, IconData icon) {
    final isSelected = _fulfillmentType == value;
    return GestureDetector(
      onTap: () => setState(() => _fulfillmentType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.inactive.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28.sp,
              color: isSelected ? AppTheme.primary : AppTheme.inactive,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.inactive,
        ),
        prefixIcon: Icon(icon, color: AppTheme.inactive, size: 22.sp),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _processPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.inactive : AppTheme.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textPrimary,
                  ),
                )
              : Text(
                  'Confirm & Pay',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  String _unitLabel(String unit) {
    const labels = {'piece': 'قطعة', 'kg': 'كيلو', 'bundle': 'بندل'};
    return labels[unit] ?? unit;
  }
}
