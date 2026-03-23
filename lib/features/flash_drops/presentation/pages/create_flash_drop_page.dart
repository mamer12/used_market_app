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
import '../widgets/flash_countdown_timer.dart';

/// Page for sellers to create a new Flash Drop (حار ومكسب).
///
/// Features:
///   - Select product from inventory
///   - Set discount percentage (slider)
///   - Set number of slots (1-5)
///   - Set start/end time
///   - Preview card showing countdown
///   - Submit to POST /api/v1/flash-drops
class CreateFlashDropPage extends StatefulWidget {
  const CreateFlashDropPage({super.key});

  @override
  State<CreateFlashDropPage> createState() => _CreateFlashDropPageState();
}

class _CreateFlashDropPageState extends State<CreateFlashDropPage> {
  final _formKey = GlobalKey<FormState>();

  // Selected product
  String? _selectedProductId;
  String _selectedProductName = '';
  int _selectedProductPrice = 0;

  // Flash drop settings
  double _discountPct = 20;
  int _slots = 1;
  DateTime? _startTime;
  DateTime? _endTime;

  bool _isSubmitting = false;
  bool _showPreview = false;

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

  static const _orange = Color(0xFFEA580C);

  int get _flashPrice =>
      (_selectedProductPrice * (1 - _discountPct / 100)).round();

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null || _startTime == null || _endTime == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context);

    try {
      final dio = getIt<Dio>();
      await dio.post('/api/v1/flash-drops', data: {
        'product_id': _selectedProductId,
        'discount_pct': _discountPct.round(),
        'slots': _slots,
        'starts_at': _startTime!.toIso8601String(),
        'ends_at': _endTime!.toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.flashDropCreatedSuccess ?? 'Flash drop created',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.flashDropCreateError ?? 'Failed to create drop',
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
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text(
            l10n?.flashDropCreateTitle ?? 'إنشاء عرض خاطف',
            style: GoogleFonts.tajawal(
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
                _sectionTitle(l10n?.flashDropSelectProduct ?? 'اختر المنتج'),
                SizedBox(height: 8.h),
                ...(_inventory.map((p) => _productTile(p))),
                SizedBox(height: 20.h),

                // ── Discount Slider ──────────────────────────────────
                _sectionTitle(
                    '${l10n?.flashDropDiscount ?? 'نسبة الخصم'}: ${_discountPct.round()}٪'),
                SizedBox(height: 8.h),
                Slider(
                  value: _discountPct,
                  min: 5,
                  max: 90,
                  divisions: 17,
                  activeColor: _orange,
                  label: '${_discountPct.round()}٪',
                  onChanged: (v) => setState(() => _discountPct = v),
                ),
                SizedBox(height: 16.h),

                // ── Slots Selector ───────────────────────────────────
                _sectionTitle(
                    '${l10n?.flashDropSlots ?? 'عدد الفرص'}: $_slots'),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(5, (i) {
                    final slot = i + 1;
                    final isSelected = slot == _slots;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _slots = slot),
                        child: Container(
                          margin: EdgeInsetsDirectional.only(
                              end: i < 4 ? 8.w : 0),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _orange
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isSelected
                                  ? _orange
                                  : AppTheme.divider,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$slot',
                            style: GoogleFonts.tajawal(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),

                // ── Time Pickers ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _timePicker(
                        label: l10n?.flashDropStartTime ?? 'وقت البداية',
                        value: _startTime != null
                            ? dateFormat.format(_startTime!)
                            : null,
                        onTap: () => _pickDateTime(isStart: true),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _timePicker(
                        label: l10n?.flashDropEndTime ?? 'وقت النهاية',
                        value: _endTime != null
                            ? dateFormat.format(_endTime!)
                            : null,
                        onTap: () => _pickDateTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Preview Toggle ───────────────────────────────────
                if (_selectedProductId != null)
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showPreview = !_showPreview),
                    icon: Icon(
                      _showPreview
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    label: Text(
                      l10n?.flashDropPreview ?? 'معاينة',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _orange,
                      side: const BorderSide(color: _orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),

                // ── Preview Card ─────────────────────────────────────
                if (_showPreview && _selectedProductId != null) ...[
                  SizedBox(height: 16.h),
                  _buildPreviewCard(),
                ],
                SizedBox(height: 24.h),

                // ── Submit Button ────────────────────────────────────
                ElevatedButton(
                  onPressed: _selectedProductId != null &&
                          _startTime != null &&
                          _endTime != null &&
                          !_isSubmitting
                      ? _submit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _orange.withValues(alpha: 0.4),
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
                          l10n?.flashDropSubmit ?? 'إطلاق العرض',
                          style: GoogleFonts.tajawal(
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
      style: GoogleFonts.tajawal(
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
          _selectedProductPrice = product['price'] as int;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _orange : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.inventory_2_rounded,
                  size: 24.sp, color: _orange),
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
              Icon(Icons.check_circle_rounded,
                  color: _orange, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _timePicker({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11.sp,
                color: AppTheme.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value ?? 'اختر الوقت',
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color:
                    value != null ? AppTheme.textPrimary : AppTheme.inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final previewEnd =
        _endTime ?? DateTime.now().add(const Duration(hours: 2));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'خصم ${_discountPct.round()}٪',
              style: GoogleFonts.tajawal(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _selectedProductName,
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                IqdFormatter.format(_selectedProductPrice),
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                IqdFormatter.format(_flashPrice),
                style: GoogleFonts.tajawal(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_slots فرصة',
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              FlashCountdownTimer(endsAt: previewEnd),
            ],
          ),
        ],
      ),
    );
  }
}
