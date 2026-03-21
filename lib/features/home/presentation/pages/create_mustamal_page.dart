import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_mustamal_cubit.dart';

// ── Mustamal colour tokens ────────────────────────────────────────────────────
const _orange = AppTheme.mustamalOrange;
const _bg = Color(0xFFFFF8F5);
const _surface = Color(0xFFFFFFFF);
const _border = Color(0xFFEDE6DC);
const _textPrimary = Color(0xFF1C1713);
const _textSecondary = Color(0xFF6B5E52);
const _textTertiary = Color(0xFFA89585);

/// Create Used Item listing page — Sooq Al-Mustamal (C2C fixed-price).
/// Sellers negotiate via WhatsApp/Chat; no cart involved.
class CreateMustamalPage extends StatefulWidget {
  const CreateMustamalPage({super.key});

  @override
  State<CreateMustamalPage> createState() => _CreateMustamalPageState();
}

class _CreateMustamalPageState extends State<CreateMustamalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Condition: new | excellent | good
  String _condition = 'excellent';

  // City / district
  String _city = 'بغداد';
  String _district = 'المنصور';

  // Price negotiable toggle
  bool _negotiable = true;

  // Contact methods (multi-select)
  final Set<String> _contactMethods = {'whatsapp'};

  // Category (shown as bottom-sheet selector stub)
  String _category = 'هواتف ذكية';

  // Images
  final List<File> _images = [];
  final _picker = ImagePicker();

  static const int _maxImages = 10;

  static const _cities = ['بغداد', 'البصرة', 'الموصل', 'أربيل', 'النجف', 'كركوك'];
  static const _districts = [
    'المنصور',
    'الكرخ',
    'الرصافة',
    'الكرادة',
    'زيونة',
    'حي بابل',
    'الجادرية',
    'الدورة',
  ];
  static const _categories = [
    'هواتف ذكية',
    'حاسبات وأجهزة',
    'سيارات',
    'أثاث منزلي',
    'ملابس وأزياء',
    'كتب وتعليم',
    'رياضة ولياقة',
    'أخرى',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Image Picking ──────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) return;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() {
      for (final xf in picked) {
        if (_images.length < _maxImages) _images.add(File(xf.path));
      }
    });
  }

  void _removeImage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _images.removeAt(index));
  }

  // ── Category Bottom Sheet ──────────────────────────────────────────────────

  void _showCategorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'اختر القسم',
              style: GoogleFonts.tajawal(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            ..._categories.map(
              (cat) => ListTile(
                title: Text(
                  cat,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    color: _textPrimary,
                    fontWeight: _category == cat
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                trailing: _category == cat
                    ? Icon(Icons.check_rounded, color: _orange, size: 18.sp)
                    : null,
                onTap: () {
                  setState(() => _category = cat);
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إضافة صورة واحدة على الأقل',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<CreateMustamalCubit>().submit(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      categoryId: _categories.indexOf(_category) + 1,
      condition: _condition,
      city: _city,
      localImages: _images,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateMustamalCubit>(),
      child: BlocConsumer<CreateMustamalCubit, CreateMustamalState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم نشر الإعلان بنجاح!',
                    style: GoogleFonts.tajawal(),
                  ),
                  backgroundColor: AppTheme.emeraldGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg, style: GoogleFonts.tajawal()),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: _bg,
              appBar: _buildAppBar(context, isLoading),
              body: Stack(
                children: [
                  _buildBody(context),
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: _orange,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isLoading) {
    return AppBar(
      backgroundColor: _surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _textPrimary,
          size: 20.sp,
        ),
      ),
      title: Text(
        'إعلان جديد',
        style: GoogleFonts.tajawal(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => _submit(context),
          child: Text(
            'نشر',
            style: GoogleFonts.tajawal(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isLoading ? _textTertiary : _orange,
            ),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Images section
            _buildImageSection(),
            SizedBox(height: 16.h),

            // Title
            _buildCard(children: [_buildTitleField()]),
            SizedBox(height: 12.h),

            // Description
            _buildCard(children: [_buildDescField()]),
            SizedBox(height: 12.h),

            // Category
            _buildCard(children: [_buildCategoryRow()]),
            SizedBox(height: 12.h),

            // Condition chips
            _buildCard(
              children: [
                _buildSectionLabel('الحالة'),
                SizedBox(height: 10.h),
                _buildConditionChips(),
              ],
            ),
            SizedBox(height: 12.h),

            // Price + negotiable
            _buildCard(children: [_buildPriceRow()]),
            SizedBox(height: 12.h),

            // City
            _buildCard(children: [_buildCityRow()]),
            SizedBox(height: 12.h),

            // District
            _buildCard(children: [_buildDistrictRow()]),
            SizedBox(height: 12.h),

            // Contact method
            _buildCard(
              children: [
                _buildSectionLabel('طريقة التواصل'),
                SizedBox(height: 10.h),
                _buildContactChips(),
              ],
            ),
            SizedBox(height: 12.h),

            // Phone
            _buildCard(children: [_buildPhoneField()]),
            SizedBox(height: 24.h),

            // Submit button
            _buildSubmitButton(context),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────────

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.tajawal(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: _textSecondary,
      ),
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صور الإعلان',
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Text(
                '${_arabicDigits(_images.length)} / ${_arabicDigits(_maxImages)} صور',
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  color: _textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 88.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add slot
                if (_images.length < _maxImages)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 76.w,
                      height: 76.w,
                      margin: EdgeInsetsDirectional.only(end: 10.w),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _orange.withValues(alpha: 0.5),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: _orange,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'إضافة صور',
                            style: GoogleFonts.tajawal(
                              fontSize: 10.sp,
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Image thumbnails
                for (int i = 0; i < _images.length; i++)
                  Stack(
                    children: [
                      Container(
                        width: 76.w,
                        height: 76.w,
                        margin: EdgeInsetsDirectional.only(end: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          image: DecorationImage(
                            image: FileImage(_images[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 4,
                        end: 14,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      style: GoogleFonts.tajawal(fontSize: 14.sp, color: _textPrimary),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
      decoration: _inputDecoration(
        label: 'عنوان الإعلان',
        hint: 'مثال: آيفون ١٥ برو ماكس ٢٥٦ جيجا',
      ),
    );
  }

  // ── Description ────────────────────────────────────────────────────────────

  Widget _buildDescField() {
    return TextFormField(
      controller: _descCtrl,
      maxLines: 4,
      style: GoogleFonts.tajawal(fontSize: 14.sp, color: _textPrimary),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
      decoration: _inputDecoration(
        label: 'الوصف',
        hint: 'صف حالة المنتج والتفاصيل المهمة...',
      ),
    );
  }

  // ── Category row ───────────────────────────────────────────────────────────

  Widget _buildCategoryRow() {
    return GestureDetector(
      onTap: _showCategorySheet,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.category_outlined, color: _textTertiary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'القسم',
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    color: _textTertiary,
                  ),
                ),
                Text(
                  _category,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: _textTertiary, size: 20.sp),
        ],
      ),
    );
  }

  // ── Condition Chips ────────────────────────────────────────────────────────

  Widget _buildConditionChips() {
    const conditions = [
      ('new', 'جديد'),
      ('excellent', 'مستعمل - ممتاز'),
      ('good', 'مستعمل - جيد'),
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: conditions.map((entry) {
        final (value, label) = entry;
        final selected = _condition == value;
        return GestureDetector(
          onTap: () => setState(() => _condition = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected ? _orange : _bg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? _orange : _border,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Price Row ──────────────────────────────────────────────────────────────

  Widget _buildPriceRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  color: _textPrimary,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  if (int.tryParse(v) == null) return 'أرقام فقط';
                  return null;
                },
                decoration: _inputDecoration(
                  label: 'السعر (دينار)',
                  hint: '٠',
                  prefixIcon: Icons.attach_money_rounded,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: () => setState(() => _negotiable = !_negotiable),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: _negotiable ? _orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: _negotiable ? _orange : _border,
                    width: 1.5,
                  ),
                ),
                child: _negotiable
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13.sp,
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Text(
                'قابل للتفاوض',
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── City Row ───────────────────────────────────────────────────────────────

  Widget _buildCityRow() {
    return _DropdownRow(
      icon: Icons.location_city_outlined,
      label: 'المدينة',
      value: _city,
      items: _cities,
      onChanged: (v) => setState(() => _city = v ?? _city),
    );
  }

  // ── District Row ───────────────────────────────────────────────────────────

  Widget _buildDistrictRow() {
    return _DropdownRow(
      icon: Icons.map_outlined,
      label: 'المنطقة',
      value: _district,
      items: _districts,
      onChanged: (v) => setState(() => _district = v ?? _district),
    );
  }

  // ── Contact Method Chips ───────────────────────────────────────────────────

  Widget _buildContactChips() {
    const methods = [
      ('messages', 'رسائل'),
      ('call', 'اتصال'),
      ('whatsapp', 'واتساب'),
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: methods.map((entry) {
        final (value, label) = entry;
        final selected = _contactMethods.contains(value);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                if (_contactMethods.length > 1) {
                  _contactMethods.remove(value);
                }
              } else {
                _contactMethods.add(value);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected ? _orange.withValues(alpha: 0.10) : _bg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? _orange : _border,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? _orange : _textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Phone Field ────────────────────────────────────────────────────────────

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.tajawal(fontSize: 14.sp, color: _textPrimary),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'مطلوب';
        if (v.trim().length < 10) return 'رقم غير صحيح';
        return null;
      },
      decoration: _inputDecoration(
        label: 'رقم الهاتف',
        hint: '07XX XXX XXXX',
        prefixIcon: Icons.phone_outlined,
      ),
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: ElevatedButton(
        onPressed: () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(
          'نشر الإعلان',
          style: GoogleFonts.tajawal(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Input Decoration Helper ─────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.tajawal(fontSize: 13.sp, color: _textTertiary),
      hintStyle: GoogleFonts.tajawal(fontSize: 13.sp, color: _textTertiary),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: _textTertiary, size: 18.sp)
          : null,
      filled: true,
      fillColor: _bg,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
      ),
    );
  }

  // ── Arabic Digits Helper ───────────────────────────────────────────────────

  String _arabicDigits(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) {
      final code = int.tryParse(d);
      return code != null ? digits[code] : d;
    }).join();
  }
}

// ── Dropdown Row Widget ────────────────────────────────────────────────────────

class _DropdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: _surface,
        style: GoogleFonts.tajawal(fontSize: 14.sp, color: _textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.tajawal(fontSize: 13.sp, color: _textTertiary),
          prefixIcon: Icon(icon, color: _textTertiary, size: 18.sp),
          filled: true,
          fillColor: _bg,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: _orange, width: 1.5),
          ),
        ),
        onChanged: onChanged,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    color: _textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
