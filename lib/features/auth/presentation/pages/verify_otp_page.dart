import 'dart:async';

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

/// Full-page OTP verification screen — Stitch v2 design.
///
/// Navigates to:
///   - Home `/` when [AuthStatus.authenticated]
///   - Registration `/register` when [AuthStatus.registrationRequired]
class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _resendTimer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_otpValue.length == 6) {
      _submit();
    }
  }

  void _submit() {
    final otp = _otpValue;
    if (otp.length == 6) {
      context.read<AuthBloc>().add(AuthOtpSubmitted(otp));
    }
  }

  void _onResend() {
    final phone = context.read<AuthBloc>().state.phoneNumber;
    if (phone != null) {
      context.read<AuthBloc>().add(AuthOtpRequested(phone));
      _startResendTimer();
    }
  }

  void _onEditNumber() {
    context.read<AuthBloc>().add(const AuthOtpCancelled());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/');
        } else if (state.status == AuthStatus.registrationRequired) {
          context.go('/register');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),

                // -- Logo icon --
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sms_outlined,
                    color: AppTheme.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // -- Header --
                Text(
                  l10n.verifyOtpTitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final phone = state.phoneNumber ?? '';
                    return Text(
                      '${l10n.verifyOtpSubtitle} $phone',
                      style: GoogleFonts.tajawal(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),

                // -- Edit number --
                TextButton(
                  onPressed: _onEditNumber,
                  child: Text(
                    l10n.verifyOtpEditNumber,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.sp,
                      color: AppTheme.dinarGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // -- OTP digit row --
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 4.w,
                        ),
                        child: _OtpDigitBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (v) => _onDigitChanged(index, v),
                          autofocus: index == 0,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 12.h),

                // -- Error --
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) => prev.error != curr.error,
                  builder: (context, state) {
                    if (state.error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsetsDirectional.only(top: 8.h),
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

                SizedBox(height: 32.h),

                // -- Verify button --
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                  builder: (context, state) {
                    return PrimaryButton(
                      label: l10n.verifyOtpSubmit,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // -- Resend countdown (60 seconds) --
                Center(
                  child: _secondsLeft > 0
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n.verifyOtpResendIn} ',
                              style: GoogleFonts.tajawal(
                                fontSize: 13.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${_secondsLeft}s',
                                style: GoogleFonts.tajawal(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : TextButton(
                          onPressed: _onResend,
                          child: Text(
                            l10n.verifyOtpResend,
                            style: GoogleFonts.tajawal(
                              fontSize: 14.sp,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- _OtpDigitBox --

class _OtpDigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      height: 56.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.tajawal(
          fontSize: 24.sp,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppTheme.surfaceAlt,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
