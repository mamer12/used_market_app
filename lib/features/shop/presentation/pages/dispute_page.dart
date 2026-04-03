import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../orders/data/repositories/dispute_repository.dart';

// ── Dispute reason enum ────────────────────────────────────────────────────

enum DisputeReason {
  itemNotReceived('item_not_received', 'لم يصل المنتج'),
  itemNotAsDescribed('item_not_as_described', 'المنتج لا يطابق الوصف'),
  itemDamaged('item_damaged', 'المنتج تالف'),
  other('other', 'أخرى');

  const DisputeReason(this.apiValue, this.arabicLabel);
  final String apiValue;
  final String arabicLabel;
}

// ── Cubit state ────────────────────────────────────────────────────────────

enum _DisputeStatus { idle, uploading, loading, success, error }

class _DisputeState {
  final _DisputeStatus status;
  final String? error;

  const _DisputeState({this.status = _DisputeStatus.idle, this.error});

  _DisputeState copyWith({_DisputeStatus? status, String? error}) =>
      _DisputeState(status: status ?? this.status, error: error ?? this.error);
}

// ── Page ──────────────────────────────────────────────────────────────────

class DisputePage extends StatefulWidget {
  final String orderId;

  const DisputePage({super.key, required this.orderId});

  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> {
  static const Color _disputeRed = Color(0xFFD32F2F);
  static const int _maxPhotos = 3;

  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  DisputeReason? _selectedReason;
  _DisputeState _state = const _DisputeState();
  final List<File> _pickedImages = [];

  late final DisputeRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = getIt<DisputeRepository>();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Photo picking ─────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    if (_pickedImages.length >= _maxPhotos) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1280,
    );
    if (picked == null) return;

    setState(() => _pickedImages.add(File(picked.path)));
  }

  void _removePhoto(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // ── Upload evidence photos and return URLs ────────────────────────────────

  Future<List<String>> _uploadEvidencePhotos() async {
    if (_pickedImages.isEmpty) return [];

    final dio = getIt<Dio>();
    final urls = <String>[];

    for (final file in _pickedImages) {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      final response = await dio.post(ApiConstants.mediaUpload, data: formData);
      final url = (response.data as Map<String, dynamic>?)?['url'] as String? ?? '';
      if (url.isNotEmpty) urls.add(url);
    }

    return urls;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار سبب النزاع', style: GoogleFonts.cairo()),
          backgroundColor: _disputeRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Step 1: upload photos if any
      setState(() => _state = _state.copyWith(status: _DisputeStatus.uploading));
      final evidenceUrls = await _uploadEvidencePhotos();

      // Step 2: submit dispute
      setState(() => _state = _state.copyWith(status: _DisputeStatus.loading));
      await _repository.createDispute(
        orderId: widget.orderId,
        reason: _selectedReason!.apiValue,
        description: _descCtrl.text.trim(),
        evidenceUrls: evidenceUrls,
      );

      if (!mounted) return;
      setState(() => _state = _state.copyWith(status: _DisputeStatus.success));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
          'حدث خطأ، يرجى المحاولة لاحقًا';
      setState(
        () => _state = _state.copyWith(status: _DisputeStatus.error, error: msg),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _state = _state.copyWith(
          status: _DisputeStatus.error,
          error: 'حدث خطأ، يرجى المحاولة لاحقًا',
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
            'تقديم نزاع',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: _state.status == _DisputeStatus.success
            ? _buildSuccessState()
            : _buildForm(),
      ),
    );
  }

  Widget _buildSuccessState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تقديم النزاع بنجاح، سيتم مراجعته قريبًا',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 48.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            'تم تقديم النزاع بنجاح',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'سيقوم فريق مضمون بمراجعة نزاعك والتواصل معك في أقرب وقت',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isLoading = _state.status == _DisputeStatus.loading ||
        _state.status == _DisputeStatus.uploading;
    final loadingLabel = _state.status == _DisputeStatus.uploading
        ? 'جارٍ رفع الصور...'
        : 'جارٍ الإرسال...';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Order ID banner ──────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _disputeRed.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _disputeRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: _disputeRed, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'رقم الطلب: ${widget.orderId}',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: _disputeRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Reason dropdown ──────────────────────────────────────────
            _buildSectionLabel('سبب النزاع *'),
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
                child: DropdownButton<DisputeReason>(
                  value: _selectedReason,
                  isExpanded: true,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'اختر سببًا',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppTheme.inactive,
                      ),
                    ),
                  ),
                  items: DisputeReason.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              r.arabicLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _selectedReason = v),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Description ──────────────────────────────────────────────
            _buildSectionLabel('وصف المشكلة * (20 حرف على الأقل)'),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              enabled: !isLoading,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'اشرح مشكلتك بالتفصيل...',
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
                  borderSide: const BorderSide(color: _disputeRed, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: _disputeRed),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى كتابة وصف للمشكلة';
                if (v.trim().length < 20) return 'يجب أن يكون الوصف 20 حرفًا على الأقل';
                return null;
              },
            ),
            SizedBox(height: 24.h),

            // ── Photo evidence (up to 3) ─────────────────────────────────
            Row(
              children: [
                _buildSectionLabel('صور إثبات (اختياري، حتى 3 صور)'),
                const Spacer(),
                Text(
                  '${_pickedImages.length}/$_maxPhotos',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildPhotoRow(isLoading),
            SizedBox(height: 16.h),

            // ── Error message ────────────────────────────────────────────
            if (_state.status == _DisputeStatus.error) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _disputeRed.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: _disputeRed, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _state.error ?? 'حدث خطأ غير متوقع',
                        style:
                            GoogleFonts.cairo(fontSize: 13.sp, color: _disputeRed),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // ── Submit button ────────────────────────────────────────────
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _disputeRed,
                  disabledBackgroundColor: AppTheme.inactive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            loadingLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'تقديم النزاع',
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
    );
  }

  // ── Photo row widget ──────────────────────────────────────────────────────

  Widget _buildPhotoRow(bool disabled) {
    return SizedBox(
      height: 90.h,
      child: Row(
        children: [
          // Existing picked images
          for (int i = 0; i < _pickedImages.length; i++) ...[
            _buildPhotoThumbnail(i, disabled),
            SizedBox(width: 8.w),
          ],
          // Add button (shown if < maxPhotos)
          if (_pickedImages.length < _maxPhotos)
            _buildAddPhotoButton(disabled),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index, bool disabled) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.file(
            _pickedImages[index],
            width: 80.w,
            height: 80.h,
            fit: BoxFit.cover,
          ),
        ),
        if (!disabled)
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 12.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton(bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : _pickPhoto,
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppTheme.inactive.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              color: disabled ? AppTheme.inactive : AppTheme.textSecondary,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'إضافة',
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                color: disabled ? AppTheme.inactive : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
