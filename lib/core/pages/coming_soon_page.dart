import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Shown when a user navigates to a Sooq that is not yet launched in their city.
class ComingSoonPage extends StatelessWidget {
  final String sooqId;

  const ComingSoonPage({super.key, required this.sooqId});

  String get _sooqName => switch (sooqId) {
    'matajir'  => 'متاجر',
    'balla'    => 'بالة وجملة',
    'mustamal' => 'مستعمل',
    _           => 'هذا السوق',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 42.sp,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(height: 32.h),

              // Title
              Text(
                'قريباً في مدينتك',
                style: GoogleFonts.cairo(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Subtitle
              Text(
                'سوق $_sooqName غير متاح حالياً في منطقتك.\nنعمل بجد للوصول إليك قريباً!',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  color: AppTheme.textSecondary,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),

              // Back to home
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'العودة للرئيسية',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
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
