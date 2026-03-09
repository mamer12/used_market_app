import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/create_balla_cubit.dart';

/// Add Balla / Bulk listing page — Sooq Al-Balla (B2B thrift/bulk).
/// Items can be sold by piece, kg, or bundle.
class AddBallaPage extends StatefulWidget {
  final String? shopId;
  const AddBallaPage({super.key, this.shopId});

  @override
  State<AddBallaPage> createState() => _AddBallaPageState();
}

class _AddBallaPageState extends State<AddBallaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'بغداد');

  String _salesUnit = 'bundle'; // 'piece' | 'kg' | 'bundle'
  final List<File> _images = [];
  final _picker = ImagePicker();

  static const _units = ['piece', 'kg', 'bundle'];
  static const _unitLabels = {'piece': 'قطعة', 'kg': 'كيلو', 'bundle': 'بندل'};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
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

  void _submit(BuildContext innerContext) {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(innerContext).showSnackBar(
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

    innerContext.read<CreateBallaCubit>().submit(
      shopId: widget.shopId ?? '1', // Defaulting for now
      title: _titleCtrl.text,
      description: _descCtrl.text,
      price: double.parse(_priceCtrl.text),
      categoryId: 1, // Defaulting for now
      condition: 'good',
      salesUnit: _salesUnit,
      city: _cityCtrl.text.trim().isEmpty ? 'بغداد' : _cityCtrl.text.trim(),
      weight: double.tryParse(_quantityCtrl.text) ?? 1.0,
      localImages: _images,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateBallaCubit>(),
      child: BlocConsumer<CreateBallaCubit, CreateBallaState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إضافة البالة بنجاح!',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFF7C4DFF),
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
                          // Header chip
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF7C4DFF,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(
                                  0xFF7C4DFF,
                                ).withValues(alpha: 0.25),
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
                                  onTap: () =>
                                      setState(() => _salesUnit = unit),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(left: 8.w),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF7C4DFF)
                                          : AppTheme.background,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF7C4DFF)
                                            : AppTheme.inactive.withValues(
                                                alpha: 0.3,
                                              ),
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
                                    if (int.tryParse(v) == null) {
                                      return 'أرقام فقط';
                                    }
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
                          SizedBox(height: 14.h),
                          _buildField(
                            _cityCtrl,
                            'المدينة',
                            Icons.location_on_outlined,
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
                          color: Color(0xFF7C4DFF),
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

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : () => _submit(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: isLoading ? AppTheme.inactive : const Color(0xFF7C4DFF),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isLoading
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
          child: isLoading
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
