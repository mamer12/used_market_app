import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

// ── Simple in-memory store (persists for session; replace with Hive/sqflite) ──
class ShippingAddressStore {
  ShippingAddressStore._();
  static ShippingAddressStore instance = ShippingAddressStore._();

  ShippingAddress? saved;
}

class ShippingAddress {
  final String fullName;
  final String phone;
  final String city;
  final String district;
  final String details;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.city,
    required this.district,
    required this.details,
  });
}

// ── Page ─────────────────────────────────────────────────────────────────────

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _saving = false;

  static const _iraqiCities = [
    'بغداد',
    'البصرة',
    'الموصل',
    'أربيل',
    'النجف',
    'كربلاء',
    'السليمانية',
    'كركوك',
    'الأنبار',
    'ذي قار',
    'ديالى',
    'بابل',
    'واسط',
    'صلاح الدين',
    'المثنى',
    'القادسية',
    'ميسان',
    'دهوك',
    'حلبجة',
  ];

  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    final saved = ShippingAddressStore.instance.saved;
    if (saved != null) {
      _nameCtrl.text = saved.fullName;
      _phoneCtrl.text = saved.phone;
      _selectedCity = saved.city;
      _districtCtrl.text = saved.district;
      _detailsCtrl.text = saved.details;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    ShippingAddressStore.instance.saved = ShippingAddress(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _selectedCity!,
      district: _districtCtrl.text.trim(),
      details: _detailsCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ العنوان بنجاح', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: AppTheme.textPrimary,
            onPressed: () => context.pop(),
          ),
          title: Text(
            'عنوان التوصيل',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل *',
                  hint: 'أحمد محمد',
                  keyboardType: TextInputType.name,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'يرجى إدخال الاسم الكامل'
                      : null,
                ),
                SizedBox(height: 16.h),
                _field(
                  controller: _phoneCtrl,
                  label: 'رقم الهاتف *',
                  hint: '07XXXXXXXXX',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    if (!RegExp(r'^07[3-9]\d{8}$').hasMatch(v.trim())) {
                      return 'رقم هاتف عراقي غير صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _label('المحافظة *'),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppTheme.inactive.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'اختر المحافظة',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: AppTheme.inactive,
                          ),
                        ),
                      ),
                      items: _iraqiCities
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  c,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCity = v),
                    ),
                  ),
                ),
                if (_saving == false &&
                    _formKey.currentState != null &&
                    _selectedCity == null)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h, right: 12.w),
                    child: Text(
                      'يرجى اختيار المحافظة',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                _field(
                  controller: _districtCtrl,
                  label: 'الحي / المنطقة *',
                  hint: 'مثال: الكرادة، المنصور',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'يرجى إدخال اسم الحي'
                      : null,
                ),
                SizedBox(height: 16.h),
                _field(
                  controller: _detailsCtrl,
                  label: 'تفاصيل العنوان *',
                  hint: 'رقم البناية، الشارع، قرب...',
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'يرجى إدخال تفاصيل العنوان'
                      : null,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () {
                            if (_selectedCity == null) {
                              setState(() {}); // trigger rebuild to show city error
                            }
                            _save();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.matajirBlue,
                      disabledBackgroundColor: AppTheme.inactive,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'حفظ العنوان',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(label),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.inactive,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide:
                  BorderSide(color: AppTheme.inactive.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide:
                  BorderSide(color: AppTheme.inactive.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide:
                  const BorderSide(color: AppTheme.matajirBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 14.h : 0,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
