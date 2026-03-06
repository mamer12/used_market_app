import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';

/// Add Balla / Bulk listing page — Sooq Al-Balla (B2B thrift/bulk).
/// Items can be sold by piece, kg, or bundle.
class AddBallaPage extends StatefulWidget {
  const AddBallaPage({super.key});

  @override
  State<AddBallaPage> createState() => _AddBallaPageState();
}

class _AddBallaPageState extends State<AddBallaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();

  String _salesUnit = 'bundle'; // 'piece' | 'kg' | 'bundle'
  final List<File> _images = [];
  bool _isLoading = false;
  final _picker = ImagePicker();

  static const _units = ['piece', 'kg', 'bundle'];
  static const _unitLabels = {'piece': 'قطعة', 'kg': 'كيلو', 'bundle': 'بندل'};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 5 - _images.length;
    if (remaining <= 0) return;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() {
      for (final xf in picked) {
        if (_images.length < 5) _images.add(File(xf.path));
      }
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: wire to BallaRemoteDataSource.createListing() when available
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة البالة بنجاح!', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF7C4DFF),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'بيع بالة / جملة',
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
                // Header chip
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 32.sp,
                        color: const Color(0xFF7C4DFF),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'البالة — بضاعة بالجملة أو الكيلو',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Images
                _buildImagePicker(),
                SizedBox(height: 20.h),

                _buildField(
                  _titleCtrl,
                  'اسم البالة',
                  Icons.inventory_2_outlined,
                ),
                SizedBox(height: 14.h),
                _buildField(
                  _descCtrl,
                  'وصف المحتوى',
                  Icons.description_outlined,
                  maxLines: 3,
                ),
                SizedBox(height: 14.h),

                // Sales unit selector
                Text(
                  'وحدة البيع',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: _units.map((unit) {
                    final selected = _salesUnit == unit;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _salesUnit = unit),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF7C4DFF)
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7C4DFF)
                                  : AppTheme.inactive.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _unitLabels[unit] ?? unit,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        _priceCtrl,
                        'السعر / ${_unitLabels[_salesUnit]}',
                        Icons.attach_money,
                        type: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'مطلوب';
                          if (int.tryParse(v) == null) return 'أرقام فقط';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildField(
                        _quantityCtrl,
                        'الكمية المتاحة',
                        Icons.numbers,
                        type: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 88.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_images.length < 5)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 76.w,
                height: 76.w,
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF7C4DFF),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: const Color(0xFF7C4DFF),
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'صورة',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: const Color(0xFF7C4DFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (int i = 0; i < _images.length; i++)
            Stack(
              children: [
                Container(
                  width: 76.w,
                  height: 76.w,
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    image: DecorationImage(
                      image: FileImage(_images[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(i)),
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 11.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      validator: validator ?? (v) => v!.isEmpty ? 'مطلوب' : null,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: AppTheme.inactive,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.h : 0),
          child: Icon(icon, color: AppTheme.inactive, size: 20.sp),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: _isLoading ? AppTheme.inactive : const Color(0xFF7C4DFF),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
              : Text(
                  'نشر البالة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
