import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Page for creating a new group buy (شلّة).
///
/// Features:
///   - Select product
///   - Set group price
///   - Set minimum buyers
///   - Set deadline
///   - Submit to POST /api/v1/group-buys
class CreateGroupBuyPage extends StatefulWidget {
  const CreateGroupBuyPage({super.key});

  @override
  State<CreateGroupBuyPage> createState() => _CreateGroupBuyPageState();
}

class _CreateGroupBuyPageState extends State<CreateGroupBuyPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupPriceController = TextEditingController();
  final _minBuyersController = TextEditingController(text: '3');

  String? _selectedProductId;
  String _selectedProductName = '';
  int _selectedProductOriginalPrice = 0;
  DateTime? _deadline;
  bool _isSubmitting = false;

  static const _purple = Color(0xFF7C3AED);

  // Mock inventory — in production, fetched from seller's shop
  final List<Map<String, dynamic>> _inventory = [
    {
      'id': 'p1',
      'name': 'سماعات بلوتوث سوني',
      'image': 'https://placehold.co/200x200/png',
      'price': 75000,
    },
    {
      'id': 'p2',
      'name': 'شاحن سريع أنكر',
      'image': 'https://placehold.co/200x200/png',
      'price': 25000,
    },
    {
      'id': 'p3',
      'name': 'كفر آيفون سيليكون',
      'image': 'https://placehold.co/200x200/png',
      'price': 15000,
    },
  ];

  @override
  void dispose() {
    _groupPriceController.dispose();
    _minBuyersController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null || !mounted) return;

    setState(() {
      _deadline =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null || _deadline == null) return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context);

    try {
      final dio = getIt<Dio>();
      final res = await dio.post('/api/v1/group-buys', data: {
        'product_id': _selectedProductId,
        'group_price': int.tryParse(_groupPriceController.text) ?? 0,
        'min_buyers': int.tryParse(_minBuyersController.text) ?? 3,
        'expires_at': _deadline!.toIso8601String(),
      });

      if (!mounted) return;

      final data = res.data['data'] as Map<String, dynamic>?;
      final groupId = data?['id'] as String? ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.groupBuyCreatedSuccess ?? 'تم إنشاء الشلّة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (groupId.isNotEmpty) {
        context.pushReplacement('/group/$groupId');
      } else {
        context.pop();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.groupBuyCreateError ?? 'فشل إنشاء الشلّة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ar_IQ');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0FF),
        appBar: AppBar(
          title: Text(
            l10n?.groupBuyCreateTitle ?? 'إنشاء شلّة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Product Selection ─────────────────────────────────
                _sectionTitle(
                    l10n?.groupBuySelectProduct ?? 'اختر المنتج'),
                SizedBox(height: 8.h),
                ...(_inventory.map((p) => _productTile(p))),
                SizedBox(height: 20.h),

                // ── Group Price ───────────────────────────────────────
                _sectionTitle(l10n?.groupBuyGroupPrice ?? 'سعر الشلّة'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _groupPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مثال: 50000',
                    suffixText: 'د.ع',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: _purple, width: 2),
                    ),
                  ),
                  style: GoogleFonts.tajawal(fontSize: 14.sp),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'مطلوب';
                    if (int.tryParse(v) == null) return 'أدخل رقم صحيح';
                    return null;
                  },
                ),
                if (_selectedProductOriginalPrice > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'السعر الأصلي: ${IqdFormatter.format(_selectedProductOriginalPrice)}',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),

                // ── Minimum Buyers ───────────────────────────────────
                _sectionTitle(
                    l10n?.groupBuyMinBuyers ?? 'الحد الأدنى للمشاركين'),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _minBuyersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '3',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: _purple, width: 2),
                    ),
                  ),
                  style: GoogleFonts.tajawal(fontSize: 14.sp),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'مطلوب';
                    final n = int.tryParse(v);
                    if (n == null || n < 2) return 'الحد الأدنى 2';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // ── Deadline ─────────────────────────────────────────
                _sectionTitle(l10n?.groupBuyDeadline ?? 'آخر موعد'),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18.sp, color: _purple),
                        SizedBox(width: 12.w),
                        Text(
                          _deadline != null
                              ? dateFormat.format(_deadline!)
                              : 'اختر التاريخ والوقت',
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp,
                            color: _deadline != null
                                ? AppTheme.textPrimary
                                : AppTheme.inactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // ── Submit Button ────────────────────────────────────
                ElevatedButton(
                  onPressed: _selectedProductId != null &&
                          _deadline != null &&
                          !_isSubmitting
                      ? _submit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _purple.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n?.groupBuySubmit ?? 'إنشاء الشلّة',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _productTile(Map<String, dynamic> product) {
    final isSelected = _selectedProductId == product['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = product['id'] as String;
          _selectedProductName = product['name'] as String;
          _selectedProductOriginalPrice = product['price'] as int;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _purple : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.inventory_2_rounded,
                  size: 24.sp, color: _purple),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: GoogleFonts.tajawal(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    IqdFormatter.format(product['price'] as int),
                    style: GoogleFonts.tajawal(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _purple, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
