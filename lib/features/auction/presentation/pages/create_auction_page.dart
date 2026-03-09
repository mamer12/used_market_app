import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/data/datasources/auction_remote_data_source.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../media/data/datasources/media_remote_data_source.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _minBidController = TextEditingController();
  final _durationController = TextEditingController(text: '24');
  final _cityController = TextEditingController(text: 'بغداد');

  String _selectedCategory = 'electronics';
  String _selectedCondition = 'new';

  final List<File> _selectedImages = [];
  static const _maxImages = 5;

  bool _isLoading = false;
  String? _loadingStep;

  final _picker = ImagePicker();
  late final MediaRemoteDataSource _mediaDs;
  late final AuctionRemoteDataSource _auctionDs;

  static const _categories = [
    'electronics',
    'cars',
    'furniture',
    'fashion',
    'real_estate',
    'other',
  ];

  static const _conditions = ['new', 'used_good', 'used_fair'];

  @override
  void initState() {
    super.initState();
    _mediaDs = getIt<MediaRemoteDataSource>();
    _auctionDs = getIt<AuctionRemoteDataSource>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startPriceController.dispose();
    _minBidController.dispose();
    _durationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) return;
    final remaining = _maxImages - _selectedImages.length;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() {
      for (final xf in picked) {
        if (_selectedImages.length < _maxImages) {
          _selectedImages.add(File(xf.path));
        }
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingStep = 'جاري رفع الصور…';
    });

    try {
      // Step 1: Upload images (if any) and get CDN URLs
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _mediaDs.uploadImages(_selectedImages);
      }

      if (!mounted) return;
      setState(() => _loadingStep = 'جاري إطلاق المزاد…');

      // Step 2: Build the request body and submit to the API
      final request = CreateAuctionRequest(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        startPrice: int.parse(_startPriceController.text.trim()),
        minBidIncrement: _minBidController.text.trim().isEmpty
            ? 1000
            : int.parse(_minBidController.text.trim()),
        durationHours: int.tryParse(_durationController.text.trim()) ?? 24,
        city: _cityController.text.trim().isEmpty
            ? 'بغداد'
            : _cityController.text.trim(),
        images: imageUrls,
      );

      await _auctionDs.createAuction(request);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auctionCreatedSuccess, style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل: $e', style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.auctionCreateTitle,
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
                _buildHeader(l10n),
                SizedBox(height: 24.h),

                // ── Image Picker ─────────────────────────────────────
                _buildImagePicker(l10n),
                SizedBox(height: 24.h),

                // ── Title ────────────────────────────────────────────
                _buildTextField(
                  controller: _titleController,
                  label: l10n.auctionFieldTitle,
                  icon: Icons.gavel_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.auctionFieldRequired;
                    if (v.trim().length < 5) return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // ── Description ──────────────────────────────────────
                _buildTextField(
                  controller: _descController,
                  label: l10n.auctionFieldDescription,
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      v!.isEmpty ? l10n.auctionFieldRequired : null,
                ),
                SizedBox(height: 16.h),

                // ── Category + Condition ─────────────────────────────
                Row(
                  children: [
                    Expanded(child: _buildCategoryPicker(l10n)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildConditionPicker(l10n)),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Price fields ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _startPriceController,
                        label: l10n.auctionFieldStartPrice,
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.auctionFieldRequired;
                          final n = int.tryParse(v);
                          if (n == null) return 'أرقام فقط';
                          if (n < 1000) return 'الحد الأدنى 1,000';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _minBidController,
                        label: l10n.auctionFieldReservePrice,
                        icon: Icons.trending_up_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final n = int.tryParse(v);
                            if (n == null) return 'أرقام فقط';
                            if (n < 1000) return 'الحد الأدنى 1,000';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Duration ─────────────────────────────────────────
                _buildTextField(
                  controller: _durationController,
                  label: 'مدة المزاد (ساعات)',
                  icon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return l10n.auctionFieldRequired;
                    if ((int.tryParse(v) ?? 0) < 1) return '1 ساعة على الأقل';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _cityController,
                  label: 'المدينة',
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? 'يرجى إدخال المدينة' : null,
                ),
                SizedBox(height: 32.h),

                _buildSubmitButton(l10n),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.liveBadge.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.liveBadge.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppTheme.liveBadge.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 32.sp,
              color: AppTheme.liveBadge,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.auctionHostTitle,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.auctionHostSub,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صور المنتج (حتى $_maxImages صور)',
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add photo button
              if (_selectedImages.length < _maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.primary,
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppTheme.primary,
                          size: 28.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'أضف صورة',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Thumbnails
              for (int i = 0; i < _selectedImages.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      margin: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
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
    );
  }

  Widget _buildCategoryPicker(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      dropdownColor: AppTheme.background,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.textPrimary),
      decoration: _inputDecoration('الفئة', Icons.category_outlined),
      onChanged: (v) => setState(() => _selectedCategory = v!),
      items: _categories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: GoogleFonts.cairo(fontSize: 13.sp)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConditionPicker(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCondition,
      dropdownColor: AppTheme.background,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.textPrimary),
      decoration: _inputDecoration('الحالة', Icons.star_outline_rounded),
      onChanged: (v) => setState(() => _selectedCondition = v!),
      items: _conditions
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: GoogleFonts.cairo(fontSize: 13.sp)),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(fontSize: 13.sp, color: AppTheme.inactive),
      prefixIcon: Icon(icon, color: AppTheme.inactive, size: 20.sp),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.cairo(
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
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 70.h : 0),
          child: Icon(icon, color: AppTheme.inactive, size: 22.sp),
        ),
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
          borderSide: const BorderSide(color: AppTheme.liveBadge),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: _isLoading ? AppTheme.inactive : AppTheme.liveBadge,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.liveBadge.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      _loadingStep ?? 'جاري التحميل…',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  l10n.auctionLaunchBtn,
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
