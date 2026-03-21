import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/data/datasources/auction_remote_data_source.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../media/data/datasources/media_remote_data_source.dart';

/// Create Auction form — "أطلق مزادك".
///
/// Image grid (1 main + thumbnails), duration chips, escrow guarantee card.
///
/// Based on Stitch Screen 6 (bce228b7).
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
  final _cityController = TextEditingController(text: 'بغداد');

  String _selectedCategory = 'electronics';
  String _selectedCondition = 'new';
  int _selectedDurationIndex = 1; // 0=1d, 1=3d, 2=5d, 3=7d

  static const _durationOptions = [
    {'label': 'يوم', 'hours': 24},
    {'label': '٣ أيام', 'hours': 72},
    {'label': '٥ أيام', 'hours': 120},
    {'label': '٧ أيام', 'hours': 168},
  ];

  final _buyNowController = TextEditingController();

  bool _deliveryEnabled = false;
  bool _buyNowEnabled = false;

  final List<File> _selectedImages = [];
  static const _maxImages = 6;

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
    _cityController.dispose();
    _buyNowController.dispose();
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
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _mediaDs.uploadImages(_selectedImages);
      }

      if (!mounted) return;
      setState(() => _loadingStep = 'جاري إطلاق المزاد…');

      final durationHours =
          _durationOptions[_selectedDurationIndex]['hours'] as int;

      final request = CreateAuctionRequest(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        startPrice: int.parse(_startPriceController.text.trim()),
        minBidIncrement: _minBidController.text.trim().isEmpty
            ? 1000
            : int.parse(_minBidController.text.trim()),
        durationHours: durationHours,
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
          backgroundColor: AppTheme.mazadGreen,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.auctionCreateTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                SizedBox(height: 24.h),

                // ── Image Grid (Stitch Screen 6) ────────────────────
                _buildImageGrid(l10n),
                SizedBox(height: 24.h),

                // ── Title ────────────────────────────────────────────
                _buildTextField(
                  controller: _titleController,
                  label: l10n.auctionFieldTitle,
                  icon: Icons.gavel_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.auctionFieldRequired;
                    if (v.trim().length < 5) {
                      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                    }
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
                          if (v == null || v.isEmpty) {
                            return l10n.auctionFieldRequired;
                          }
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
                SizedBox(height: 20.h),

                // ── Duration Chips (Stitch v2: يوم/٣/٥/٧) ───────────
                _buildDurationChips(),
                SizedBox(height: 20.h),

                // ── Delivery Toggle ───────────────────────────────────
                _buildToggleRow(
                  icon: Icons.local_shipping_rounded,
                  label: 'التوصيل متاح',
                  subtitle: 'هل يمكنك توصيل المنتج للمشتري؟',
                  value: _deliveryEnabled,
                  onChanged: (v) => setState(() => _deliveryEnabled = v),
                ),
                SizedBox(height: 12.h),

                // ── Buy-Now Toggle + Price ────────────────────────────
                _buildToggleRow(
                  icon: Icons.bolt_rounded,
                  label: 'سعر الشراء الفوري',
                  subtitle: 'اسمح للمشترين بشراء المنتج مباشرة',
                  value: _buyNowEnabled,
                  onChanged: (v) => setState(() => _buyNowEnabled = v),
                ),
                if (_buyNowEnabled) ...[
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: _buyNowController,
                    label: 'سعر الشراء الفوري (د.ع)',
                    icon: Icons.bolt_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (_buyNowEnabled && (v == null || v.isEmpty)) {
                        return 'يرجى إدخال السعر';
                      }
                      if (v != null && v.isNotEmpty) {
                        final n = int.tryParse(v);
                        if (n == null) return 'أرقام فقط';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 20.h),

                _buildTextField(
                  controller: _cityController,
                  label: 'المدينة',
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? 'يرجى إدخال المدينة' : null,
                ),
                SizedBox(height: 24.h),

                // ── Escrow Guarantee Card ──────────────────────────────
                _buildEscrowGuaranteeCard(),
                SizedBox(height: 24.h),

                _buildSubmitButton(l10n),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.mazadGreen.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 32.sp,
              color: AppTheme.mazadGreen,
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

  // ── Image Grid (Stitch: 1 main + 5 thumbs in 4-col arrangement) ──────────
  Widget _buildImageGrid(AppLocalizations l10n) {
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
        // Main large image area
        GestureDetector(
          onTap: _selectedImages.isEmpty ? _pickImages : null,
          child: Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _selectedImages.isEmpty
                  ? AppTheme.mazadGreen.withValues(alpha: 0.04)
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: _selectedImages.isEmpty
                    ? AppTheme.mazadGreen.withValues(alpha: 0.3)
                    : AppTheme.divider,
                width: _selectedImages.isEmpty ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppTheme.mazadGreen,
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'أضف صورة رئيسية',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: AppTheme.mazadGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'اسحب أو اضغط لرفع الصور',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        _selectedImages.first,
                        fit: BoxFit.cover,
                      ),
                      // Delete button
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(0),
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 16.sp,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // "Main" badge
                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppTheme.mazadGreen,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            'الرئيسية',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        // Thumbnail grid (5 slots)
        SizedBox(
          height: 72.h,
          child: Row(
            children: List.generate(5, (index) {
              final imgIndex = index + 1; // offset by 1 (main is at 0)
              final hasImage = imgIndex < _selectedImages.length;
              final isAddButton =
                  !hasImage && _selectedImages.length < _maxImages;

              return Expanded(
                child: GestureDetector(
                  onTap:
                      isAddButton ? _pickImages : null,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: isAddButton
                          ? AppTheme.surface
                          : AppTheme.shimmerBase,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isAddButton
                            ? AppTheme.divider
                            : Colors.transparent,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _selectedImages[imgIndex],
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 2,
                                left: 2,
                                child: GestureDetector(
                                  onTap: () => _removeImage(imgIndex),
                                  child: Container(
                                    width: 18.w,
                                    height: 18.w,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close,
                                        size: 10.sp, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : isAddButton
                            ? Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  color: AppTheme.textTertiary,
                                  size: 20.sp,
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Duration Chips (Stitch Screen 6) ──────────────────────────────────────
  Widget _buildDurationChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مدة المزاد',
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: List.generate(_durationOptions.length, (index) {
            final isSelected = _selectedDurationIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDurationIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.mazadGreen
                        : AppTheme.surfaceAlt,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.mazadGreen
                          : AppTheme.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.mazadGreen.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _durationOptions[index]['label'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Toggle Row (delivery / buy-now) ──────────────────────────────────────
  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: value
              ? AppTheme.mazadGreen.withValues(alpha: 0.4)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.mazadGreen.withValues(alpha: 0.12)
                  : AppTheme.shimmerBase,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.mazadGreen : AppTheme.inactive,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeTrackColor: AppTheme.mazadGreen,
          ),
        ],
      ),
    );
  }

  // ── Escrow Guarantee Card (Stitch Screen 6: "ضمان الأمانة") ───────────────
  Widget _buildEscrowGuaranteeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.mazadGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: AppTheme.mazadGreen,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ضمان الأمانة',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'مزادك محمي بنظام الضمان — المبلغ يُحجز حتى تسليم المنتج بأمان.',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      fillColor: AppTheme.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.mazadGreen),
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
        fillColor: AppTheme.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.mazadGreen),
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
          color: _isLoading ? AppTheme.inactive : AppTheme.mazadGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.mazadGreen.withValues(alpha: 0.3),
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.auctionLaunchBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.rocket_launch_rounded,
                        color: AppTheme.textPrimary, size: 20.sp),
                  ],
                ),
        ),
      ),
    );
  }
}
