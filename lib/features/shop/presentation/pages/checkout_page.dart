import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/shop_models.dart';

class CheckoutPage extends StatefulWidget {
  final List<ProductModel> products;

  const CheckoutPage({super.key, required this.products});

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
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mock an API call that registers the Order in PENDING_PAYMENT state
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Transition to simulated ZainCash/FIB Payment Flow
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentRedirectDialog(method: _selectedPayment),
    ).then((_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Clear Cart and go to Success
      // Here just as an example we clear the cart
      context.read<CartCubit>().clearCart();

      // Navigate back and show success
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed successfully! State: PAID_TO_ESCROW',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    num total = widget.products.fold(0, (sum, p) => sum + p.price);

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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOrderSummary(total),
                SizedBox(height: 32.h),

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

                SizedBox(height: 48.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(num total) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Total Amount',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${total.toInt()} IQD',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
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

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _processPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: _isLoading ? AppTheme.inactive : AppTheme.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _isLoading
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
          child: _isLoading
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
}

// ── Payment Mock Flow Window ───────────────────────────────────────────────
class _PaymentRedirectDialog extends StatefulWidget {
  final String method;

  const _PaymentRedirectDialog({required this.method});

  @override
  State<_PaymentRedirectDialog> createState() => _PaymentRedirectDialogState();
}

class _PaymentRedirectDialogState extends State<_PaymentRedirectDialog> {
  bool _success = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _success = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _success
                  ? Icon(
                      Icons.check_circle_rounded,
                      size: 60.sp,
                      color: const Color(0xFF2E7D32),
                      key: const ValueKey(1),
                    )
                  : SizedBox(
                      width: 60.sp,
                      height: 60.sp,
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 4,
                      ),
                    ),
            ),
            SizedBox(height: 24.h),
            Text(
              _success
                  ? 'Payment Verified!'
                  : 'Redirecting to ${widget.method} gateway...',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _success
                  ? 'Your order is now in escrow.'
                  : 'Please follow the portal instructions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
