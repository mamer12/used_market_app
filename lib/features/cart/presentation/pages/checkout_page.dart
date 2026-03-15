import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CheckoutPage extends StatefulWidget {
  final String appContext; // e.g. 'matajir' or 'balla'

  const CheckoutPage({super.key, required this.appContext});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'zain_cash';

  @override
  Widget build(BuildContext context) {
    // Determine colors/text based on appContext
    final isMatajir = widget.appContext == 'matajir';
    final primaryColor = isMatajir ? AppTheme.primary : AppTheme.ballaPurple;
    final flowText = isMatajir
        ? 'دورة تسوق المتاجر الرسمية (Matajir Official Shopping Flow)'
        : 'دورة تسوق البالة (Balla Bulk Shopping Flow)';

    // Mock totals
    final subtotal = 75000.0;
    final deliveryFee = 3000.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'إتمام الطلب (Checkout)',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 100.h),
                children: [
                  // Context Indicator
                  _buildContextIndicator(flowText, primaryColor),

                  // Contact Info Section
                  _buildSectionTitle('معلومات الاتصال (Contact Info)'),
                  _buildContactInfo(),

                  // Shipping Address Section
                  _buildSectionTitleWithAction(
                    title: 'عنوان الشحن',
                    actionLabel: 'إضافة عنوان جديد',
                    actionIcon: Icons.add_location_alt_rounded,
                    primaryColor: primaryColor,
                  ),
                  _buildAddressTile(primaryColor),

                  // Payment Method Section
                  _buildSectionTitle('وسيلة الدفع'),
                  _buildPaymentMethods(primaryColor),

                  // Madhmoon Escrow Protection Banner
                  _buildEscrowBanner(context),

                  // Billing Summary Section
                  _buildBillingSummary(
                    subtotal,
                    deliveryFee,
                    total,
                    primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildFooterAction(primaryColor),
    );
  }

  Widget _buildContextIndicator(String text, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: primaryColor, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: primaryColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithAction({
    required String title,
    required String actionLabel,
    required IconData actionIcon,
    required Color primaryColor,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Icon(actionIcon, size: 16.sp, color: primaryColor),
                SizedBox(width: 4.w),
                Text(
                  actionLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildTextField(
            label: 'الاسم الكامل',
            hint: 'أدخل اسمك الكامل',
            initialValue: 'أحمد محمد',
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'رقم الهاتف',
                  hint: '07XXXXXXXX',
                  isNumeric: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'هاتف بديل',
                  hint: '07XXXXXXXX',
                  isNumeric: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          keyboardType: isNumeric ? TextInputType.phone : TextInputType.name,
          textDirection: isNumeric ? TextDirection.ltr : TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              color: AppTheme.inactive,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.inactive.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppTheme.inactive.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTile(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        border: Border.all(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: primaryColor, width: 4),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنزل الحالي',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'قرب مكتبة البصرة المركزية، دار 42',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'البصرة، العراق',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.inactive,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_rounded, color: AppTheme.inactive, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(Color primaryColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildPaymentOption(
            id: 'zain_cash',
            title: 'ZainCash (زين كاش)',
            logoWidget: _buildTextLogo('ZC', primaryColor),
            primaryColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildPaymentOption(
            id: 'asia_hawala',
            title: 'AsiaHawala (آسيا حوالة)',
            logoWidget: _buildTextLogo('AH', AppTheme.primary),
            primaryColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildPaymentOption(
            id: 'cod',
            title: 'الدفع عند الاستلام',
            logoWidget: Icon(
              Icons.payments_outlined,
              color: AppTheme.textSecondary,
              size: 24.sp,
            ),
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTextLogo(String text, Color color) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required Widget logoWidget,
    required Color primaryColor,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    final borderColor = isSelected
        ? primaryColor
        : AppTheme.inactive.withValues(alpha: 0.2);
    final bgColor = isSelected ? Colors.white : AppTheme.surface;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: logoWidget,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14.sp,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: primaryColor, size: 24.sp)
            else
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.inactive, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscrowBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.tigrisBlue.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: AppTheme.emeraldGreen, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context).escrowProtectionText,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.tigrisBlue,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSummary(
    double subtotal,
    double deliveryFee,
    double total,
    Color primaryColor,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الفاتورة',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryRow('المجموع الفرعي', IqdFormatter.format(subtotal)),
          _buildSummaryRow('خدمة التوصيل', IqdFormatter.format(deliveryFee)),
          Divider(
            color: AppTheme.inactive.withValues(alpha: 0.2),
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الكلي الواجب دفعه',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                IqdFormatter.format(total),
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction(Color primaryColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          shadowColor: primaryColor.withValues(alpha: 0.4),
          elevation: 8,
        ),
        onPressed: () {
          // Confirm purchase
        },
        child: Text(
          'تأكيد الشراء (Confirm Purchase)',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
