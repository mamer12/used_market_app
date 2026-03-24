import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/auth_status.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Full-page Login screen — Stitch v2 design system.
///
/// Fires [AuthOtpRequested] on submit; listens to [AuthState] for
/// navigation side-effects:
///   - [AuthStatus.otpSent] -> push /verify-otp
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

  void _onContinue(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = '+964${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(AuthOtpRequested(phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          context.go('/verify-otp');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80.h),

                  // -- Logo --
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'م',
                        style: GoogleFonts.tajawal(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.dinarGold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // -- App name --
                  Text(
                    'مضمون',
                    style: GoogleFonts.tajawal(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    l10n.loginWelcomeTo,
                    style: GoogleFonts.tajawal(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // -- Phone Label --
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.loginPhoneNumber,
                      style: GoogleFonts.tajawal(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // -- Phone Input --
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: GoogleFonts.tajawal(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.loginPhoneHint,
                      hintStyle: GoogleFonts.tajawal(
                        fontSize: 14.sp,
                        color: AppTheme.textTertiary,
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
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Container(
                        width: 130.w,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 12.w),
                            Text(
                              '\u{1F1EE}\u{1F1F6}',
                              style: TextStyle(fontSize: 20.sp),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '+964',
                              style: GoogleFonts.tajawal(
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

                  // -- Error --
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.error != curr.error,
                    builder: (context, state) {
                      if (state.error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsetsDirectional.only(bottom: 12.h),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            state.error!,
                            style: GoogleFonts.tajawal(
                              fontSize: 13.sp,
                              color: AppTheme.error,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // -- Login Button --
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                    builder: (context, state) {
                      return PrimaryButton(
                        label: l10n.loginContinue,
                        isLoading: state.isLoading,
                        onPressed: () => _onContinue(context),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // -- Register link --
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'مستخدم جديد؟',
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          'سجل الآن',
                          style: GoogleFonts.tajawal(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // -- Terms --
                  Text(
                    l10n.loginTerms,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.sp,
                      color: AppTheme.inactive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
