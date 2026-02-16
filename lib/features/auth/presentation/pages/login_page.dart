import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';

/// "Iraqi-First" Login — Phone number centered with 🇮🇶 +964 prefix.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      _navigateToHome();
    }
  }

  void _onGoogleSignIn() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                // ── Header ──────────────────────────────
                Text(
                  l10n.loginWelcomeTo,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.appTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: GoogleFonts.cairo(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // ── Phone Label ─────────────────────────
                Text(
                  l10n.loginPhoneNumber,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                // ── Phone Input ─────────────────────────
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.loginPhoneHint,
                    prefixIcon: Container(
                      width: 90.w,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 12.w),
                          Text('🇮🇶', style: TextStyle(fontSize: 20.sp)),
                          SizedBox(width: 6.w),
                          Text(
                            '+964',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 1,
                            height: 24.h,
                            color: AppTheme.inactive,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.loginPhoneEmpty;
                    }
                    if (value.length < 10) {
                      return l10n.loginPhoneInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // ── Continue Button ─────────────────────
                PrimaryButton(
                  label: l10n.loginContinue,
                  onPressed: _onContinue,
                ),
                SizedBox(height: 24.h),

                // ── Divider ─────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.inactive)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        l10n.loginOr,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.inactive)),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Google Sign-In ──────────────────────
                PrimaryButton(
                  label: l10n.loginContinueGoogle,
                  isOutlined: true,
                  onPressed: _onGoogleSignIn,
                ),
                SizedBox(height: 32.h),

                // ── Terms ───────────────────────────────
                Center(
                  child: Text(
                    l10n.loginTerms,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.inactive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
