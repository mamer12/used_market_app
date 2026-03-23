import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Page for creating and posting a new shop story.
///
/// Features:
///   - Camera / gallery picker (via image_picker)
///   - Caption text input
///   - Posts to POST /api/v1/stories
class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  File? _selectedMedia;
  bool _isPosting = false;

  static const _matajirBlue = AppTheme.matajirBlue;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _selectedMedia = File(picked.path));
    }
  }

  void _showMediaPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l10n.storyFromCamera,
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.storyFromGallery,
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _postStory() async {
    if (_selectedMedia == null || _isPosting) return;

    setState(() => _isPosting = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final dio = getIt<Dio>();
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          _selectedMedia!.path,
          filename: 'story_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (_captionController.text.trim().isNotEmpty)
          'caption': _captionController.text.trim(),
      });

      await dio.post('/api/v1/stories', data: formData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.storyPostedSuccess,
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.storyPostError,
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text(
            l10n.storyCreateTitle,
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Media preview / picker
              GestureDetector(
                onTap: _showMediaPicker,
                child: Container(
                  height: 360.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _selectedMedia != null
                          ? _matajirBlue
                          : AppTheme.divider,
                      width: _selectedMedia != null ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedMedia != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _selectedMedia!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8.h,
                              left: 8.w,
                              child: GestureDetector(
                                onTap: _showMediaPicker,
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 18.sp),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                size: 64.sp, color: _matajirBlue),
                            SizedBox(height: 12.h),
                            Text(
                              l10n.storySelectMedia,
                              style: GoogleFonts.tajawal(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),

              // Caption
              TextField(
                controller: _captionController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: l10n.storyCaption,
                  hintStyle: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    color: AppTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: _matajirBlue, width: 2),
                  ),
                ),
                style: GoogleFonts.tajawal(fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),

              // Post button
              ElevatedButton(
                onPressed:
                    _selectedMedia != null && !_isPosting ? _postStory : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _matajirBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _matajirBlue.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: _isPosting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.storyPost,
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
    );
  }
}
