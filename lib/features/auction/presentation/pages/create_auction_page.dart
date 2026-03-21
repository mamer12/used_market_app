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

// ── Mazadat dark palette ────────────────────────────────────────────────────
const Color _kBg      = Color(0xFF0A0A0F);
const Color _kSurface = Color(0xFF12121A);
const Color _kBorder  = Color(0xFF1E1E2A);
const Color _kPrimary = Color(0xFFFF3D5A); // red
const Color _kCyan    = Color(0xFF00F5FF); // cyan
const Color _kTextPri = Color(0xFFFFFFFF);
const Color _kTextSec = Color(0xFF9CA3AF);

/// Create Auction form — "مزاد جديد".
///
/// Full dark Mazadat design (Stitch screen). Image upload grid (3-col),
/// condition chips, duration chips (cyan selected), delivery toggle, submit.
class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController      = TextEditingController();
  final _descController       = TextEditingController();
  final _startPriceController = TextEditingController();
  final _minBidController     = TextEditingController();
  final _buyNowController     = TextEditingController();

  // kept from original — city not shown in Stitch but preserved for submit
  final _cityController = TextEditingController(text: 'بغداد');

  String _selectedCategory    = 'ساعات';
  String _selectedCondition   = 'new';
  int    _selectedDurationIndex = 1; // 0=1d, 1=3d, 2=5d, 3=7d
  bool   _deliveryEnabled     = false;
  bool   _startNow            = true; // true = "الآن", false = date picker
  DateTime? _scheduledDate;

  static const _durationOptions = [
    {'label': 'يوم',    'hours': 24},
    {'label': '٣ أيام', 'hours': 72},
    {'label': '٥ أيام', 'hours': 120},
    {'label': '٧ أيام', 'hours': 168},
  ];

  static const _categoryOptions = ['ساعات', 'إلكترونيات', 'سيارات', 'عقارات'];

  static const _conditionOptions = [
    {'label': 'جديد',             'value': 'new'},
    {'label': 'مستعمل - ممتاز',  'value': 'used_excellent'},
    {'label': 'مستعمل - جيد',    'value': 'used_good'},
    {'label': 'مستعمل',          'value': 'used_fair'},
  ];

  static const _maxImages = 10;
  final List<File> _selectedImages = [];

  bool    _isLoading   = false;
  String? _loadingStep;

  final _picker    = ImagePicker();
  late final MediaRemoteDataSource _mediaDs;
  late final AuctionRemoteDataSource _auctionDs;

  // derived: publish button enabled only when title + start price are filled
  bool get _canPublish =>
      _titleController.text.trim().isNotEmpty &&
      _startPriceController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _mediaDs  = getIt<MediaRemoteDataSource>();
    _auctionDs = getIt<AuctionRemoteDataSource>();
    _titleController.addListener(_onFieldChanged);
    _startPriceController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _startPriceController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _descController.dispose();
    _startPriceController.dispose();
    _minBidController.dispose();
    _buyNowController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── Image picking ──────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) return;
    final remaining = _maxImages - _selectedImages.length;
    final picked    = await _picker.pickMultiImage(limit: remaining);
    if (picked.isEmpty) return;
    setState(() {
      for (final xf in picked) {
        if (_selectedImages.length < _maxImages) {
          _selectedImages.add(File(xf.path));
        }
      }
    });
  }

  void _removeImage(int index) =>
      setState(() => _selectedImages.removeAt(index));

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading   = true;
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
        title:           _titleController.text.trim(),
        description:     _descController.text.trim(),
        category:        _selectedCategory,
        condition:       _selectedCondition,
        startPrice:      int.parse(_startPriceController.text.trim()),
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

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.h),
                      _buildImageGrid(),
                      SizedBox(height: 20.h),
                      _buildCard(children: [
                        _buildSectionLabel('عنوان المزاد'),
                        SizedBox(height: 10.h),
                        _buildDarkTextField(
                          controller: _titleController,
                          hint: 'مثال: ساعة رولكس أصلية',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'العنوان مطلوب';
                            }
                            if (v.trim().length < 5) {
                              return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('الوصف'),
                        SizedBox(height: 10.h),
                        _buildDarkTextField(
                          controller: _descController,
                          hint: 'اكتب وصفاً تفصيلياً للمنتج…',
                          maxLines: 4,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'الوصف مطلوب' : null,
                        ),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('القسم'),
                        SizedBox(height: 10.h),
                        _buildCategoryRow(),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('الحالة'),
                        SizedBox(height: 10.h),
                        _buildConditionChips(),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('سعر البداية'),
                        SizedBox(height: 10.h),
                        _buildDarkTextField(
                          controller: _startPriceController,
                          hint: '0',
                          suffix: 'د.ع',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            final n = int.tryParse(v);
                            if (n == null) return 'أرقام فقط';
                            if (n < 1000) return 'الحد الأدنى 1,000';
                            return null;
                          },
                        ),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('الحد الأدنى للمزايدة'),
                        SizedBox(height: 10.h),
                        _buildDarkTextField(
                          controller: _minBidController,
                          hint: '0',
                          suffix: 'د.ع',
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
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('سعر الشراء الفوري (اختياري)'),
                        SizedBox(height: 10.h),
                        _buildDarkTextField(
                          controller: _buyNowController,
                          hint: '0',
                          suffix: 'د.ع',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final n = int.tryParse(v);
                              if (n == null) return 'أرقام فقط';
                            }
                            return null;
                          },
                        ),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('مدة المزاد'),
                        SizedBox(height: 10.h),
                        _buildDurationChips(),
                      ]),
                      SizedBox(height: 12.h),
                      _buildCard(children: [
                        _buildSectionLabel('تاريخ البدء'),
                        SizedBox(height: 10.h),
                        _buildStartDateSection(context),
                      ]),
                      SizedBox(height: 12.h),
                      _buildDeliveryToggle(),
                      if (_deliveryEnabled) ...[
                        SizedBox(height: 12.h),
                        _buildCard(children: [
                          _buildSectionLabel('تكلفة التوصيل'),
                          SizedBox(height: 10.h),
                          _buildDarkTextField(
                            controller: _cityController,
                            hint: '0',
                            suffix: 'د.ع',
                            keyboardType: TextInputType.number,
                          ),
                        ]),
                      ],
                      SizedBox(height: 24.h),
                      _buildPublishButton(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kSurface,
                border: Border.all(color: _kBorder),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: _kTextPri,
                size: 16.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'مزاد جديد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _kTextPri,
              ),
            ),
          ),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  // ── Image upload grid (3-column, dashed cyan first cell) ───────────────────
  Widget _buildImageGrid() {
    final total     = _maxImages;
    final filled    = _selectedImages.length;
    // show up to (filled + 1) cells capped at total, minimum 3
    final cellCount = (filled + 1).clamp(3, total);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1.0,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        if (index == 0 && filled == 0) {
          // First cell — upload CTA (dashed cyan)
          return GestureDetector(
            onTap: _pickImages,
            child: DashedBorderBox(
              color: _kCyan,
              borderRadius: 10.r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: _kCyan, size: 24.sp),
                  SizedBox(height: 4.h),
                  Text(
                    'أضف صور',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: _kCyan,
                    ),
                  ),
                  Text(
                    '${_selectedImages.length}/$total صور',
                    style: GoogleFonts.cairo(
                      fontSize: 9.sp,
                      color: _kTextSec,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // If we have an image at this index, show it
        if (index < filled) {
          return _buildImageThumbnail(index);
        }

        // "Add more" cell
        return GestureDetector(
          onTap: _pickImages,
          child: DashedBorderBox(
            color: _kCyan,
            borderRadius: 10.r,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: _kCyan, size: 24.sp),
                SizedBox(height: 4.h),
                Text(
                  'أضف صور',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: _kCyan,
                  ),
                ),
                Text(
                  '${_selectedImages.length}/$total صور',
                  style: GoogleFonts.cairo(
                    fontSize: 9.sp,
                    color: _kTextSec,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_selectedImages[index], fit: BoxFit.cover),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _kBorder),
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
      style: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: _kTextPri,
      ),
    );
  }

  // ── Dark TextField ─────────────────────────────────────────────────────────
  Widget _buildDarkTextField({
    required TextEditingController controller,
    String? hint,
    String? suffix,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: _kTextPri),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: _kTextSec),
        suffixText: suffix,
        suffixStyle:
            GoogleFonts.cairo(fontSize: 13.sp, color: _kTextSec),
        filled: true,
        fillColor: _kBg,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: _kCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: _kPrimary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        errorStyle: GoogleFonts.cairo(fontSize: 11.sp, color: _kPrimary),
      ),
    );
  }

  // ── Category row (tap to show bottom sheet) ────────────────────────────────
  Widget _buildCategoryRow() {
    return GestureDetector(
      onTap: () => _showCategorySheet(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategory,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: _kTextPri,
                ),
              ),
            ),
            Icon(Icons.chevron_left_rounded,
                color: _kTextSec, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ..._categoryOptions.map(
              (cat) => ListTile(
                title: Text(
                  cat,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    color: cat == _selectedCategory
                        ? _kCyan
                        : _kTextPri,
                    fontWeight: cat == _selectedCategory
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: cat == _selectedCategory
                    ? Icon(Icons.check_rounded,
                        color: _kCyan, size: 18.sp)
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ── Condition chips ────────────────────────────────────────────────────────
  Widget _buildConditionChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _conditionOptions.map((opt) {
        final value    = opt['value'] as String;
        final label    = opt['label'] as String;
        final selected = _selectedCondition == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCondition = value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? _kPrimary : _kSurface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: selected ? _kPrimary : _kBorder,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : _kTextSec,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Duration chips (cyan selected) ────────────────────────────────────────
  Widget _buildDurationChips() {
    return Row(
      children: List.generate(_durationOptions.length, (index) {
        final isSelected = _selectedDurationIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDurationIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kCyan.withValues(alpha: 0.2)
                    : _kBg,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? _kCyan : _kBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _durationOptions[index]['label'] as String,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _kCyan : _kTextSec,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Start date section ─────────────────────────────────────────────────────
  Widget _buildStartDateSection(BuildContext context) {
    return Column(
      children: [
        // Option 1: Immediate
        GestureDetector(
          onTap: () => setState(() => _startNow = true),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _startNow ? _kCyan : _kBorder,
                    width: 2,
                  ),
                ),
                child: _startNow
                    ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kCyan,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'الآن (مباشرة بعد النشر)',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: _startNow ? _kTextPri : _kTextSec,
                    fontWeight: _startNow
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // Option 2: Date picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate:
                  DateTime.now().add(const Duration(days: 30)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: _kCyan,
                    surface: _kSurface,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _scheduledDate = picked;
                _startNow      = false;
              });
            }
          },
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !_startNow ? _kCyan : _kBorder,
                    width: 2,
                  ),
                ),
                child: !_startNow
                    ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kCyan,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Icon(Icons.calendar_today_rounded,
                  color: _kCyan, size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _scheduledDate != null
                      ? '${_scheduledDate!.year}/${_scheduledDate!.month.toString().padLeft(2, '0')}/${_scheduledDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر تاريخاً',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: !_startNow ? _kTextPri : _kTextSec,
                    fontWeight: !_startNow
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Delivery toggle ────────────────────────────────────────────────────────
  Widget _buildDeliveryToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _deliveryEnabled
              ? _kCyan.withValues(alpha: 0.4)
              : _kBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _deliveryEnabled
                  ? _kCyan.withValues(alpha: 0.12)
                  : _kBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: _deliveryEnabled ? _kCyan : _kTextSec,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التوصيل متاح',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _kTextPri,
                  ),
                ),
                Text(
                  'هل يمكنك توصيل المنتج للمشتري؟',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: _kTextSec,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _deliveryEnabled,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _deliveryEnabled = v);
            },
            activeTrackColor: _kCyan,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ── Publish button ─────────────────────────────────────────────────────────
  Widget _buildPublishButton() {
    final enabled = _canPublish && !_isLoading;
    return GestureDetector(
      onTap: enabled ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52.h,
        decoration: BoxDecoration(
          color: enabled ? _kPrimary : _kPrimary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
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
                'نشر المزاد',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ── Dashed border helper widget ────────────────────────────────────────────────
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    required this.borderRadius,
  });

  final Widget child;
  final Color  color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: color.withValues(alpha: 0.05),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color  color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = 1.5
      ..style       = PaintingStyle.stroke;

    const dashLen  = 6.0;
    const gapLen   = 4.0;
    final rrect    = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path     = Path()..addRRect(rrect);
    final metrics  = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      bool   drawing  = true;
      while (distance < metric.length) {
        final len = drawing ? dashLen : gapLen;
        if (drawing) {
          final extracted = metric.extractPath(distance,
              (distance + len).clamp(0, metric.length));
          canvas.drawPath(extracted, paint);
        }
        distance += len;
        drawing   = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
