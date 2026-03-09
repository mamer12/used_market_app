import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_mustamal_cubit.dart';

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
  final _cityCtrl = TextEditingController();

  String _condition = 'like_new';
  String _category = 'electronics';
  final List<File> _images = [];
  final _picker = ImagePicker();

  static const _conditions = ['new', 'like_new', 'good', 'fair'];
  static const _categories = [
    'electronics',
    'fashion',
    'furniture',
    'cars',
    'real_estate',
    'other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _cityCtrl.dispose();
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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إضافة صورة واحدة على الأقل',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<CreateMustamalCubit>().submit(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      price: double.parse(_priceCtrl.text),
      categoryId: 1, // Defaulting for now
      condition: _condition,
      city: _cityCtrl.text.trim().isEmpty ? 'بغداد' : _cityCtrl.text.trim(),
      localImages: _images,
    );
  }

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
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: AppTheme.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red,
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

          return Scaffold(
            backgroundColor: AppTheme.surface,
            appBar: AppBar(
              title: Text(
                'بيع شيء مستعمل',
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ... Header ...
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppTheme.secondary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.autorenew_rounded,
                                    size: 28.sp,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'سوق المستعمل',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'المشترون سيتواصلون معك مباشرة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Images
                          _buildImagePicker(),
                          SizedBox(height: 20.h),

                          _buildField(_titleCtrl, 'عنوان الإعلان', Icons.title),
                          SizedBox(height: 14.h),
                          _buildField(
                            _descCtrl,
                            'وصف الإعلان',
                            Icons.description_outlined,
                            maxLines: 3,
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            _priceCtrl,
                            'السعر (دينار)',
                            Icons.attach_money,
                            type: TextInputType.number,
                            validator: (v) {
                              if (v!.isEmpty) return 'مطلوب';
                              if (int.tryParse(v) == null) return 'أرقام فقط';
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            _cityCtrl,
                            'المدينة',
                            Icons.location_on_outlined,
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'الحالة',
                                  Icons.star_outline,
                                  _conditions,
                                  _condition,
                                  (v) => setState(() => _condition = v!),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildDropdown(
                                  'الفئة',
                                  Icons.category_outlined,
                                  _categories,
                                  _category,
                                  (v) => setState(() => _category = v!),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          _buildSubmitButton(context, isLoading),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.secondary,
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
                  color: AppTheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.secondary, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: AppTheme.secondary,
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'صورة',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: AppTheme.secondary,
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
          borderSide: const BorderSide(color: AppTheme.secondary),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> options,
    String value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppTheme.background,
      style: GoogleFonts.cairo(fontSize: 13.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          color: AppTheme.inactive,
        ),
        prefixIcon: Icon(icon, color: AppTheme.inactive, size: 18.sp),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      onChanged: onChanged,
      items: options
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: GoogleFonts.cairo(fontSize: 12.sp)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : () => _submit(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.inactive : AppTheme.secondary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                )
              : Text(
                  'نشر الإعلان',
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
