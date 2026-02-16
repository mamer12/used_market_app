import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/auth_status.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Smart Login Bottom Sheet — slides up over the current screen.
///
/// The "Smart Action Retry" magic: accepts an [onSuccess] callback
/// that fires automatically after login, preserving the user's intent.
class AuthBottomSheet {
  AuthBottomSheet._();

  /// Show the login sheet. Returns `true` if user authenticated.
  static Future<bool> show(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _AuthSheetContent(onSuccess: onSuccess),
      ),
    );
    return result ?? false;
  }
}

// ── Sheet Content (Phone → OTP flow) ──────────────────────
class _AuthSheetContent extends StatefulWidget {
  final VoidCallback? onSuccess;
  const _AuthSheetContent({this.onSuccess});

  @override
  State<_AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends State<_AuthSheetContent> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpFocus = FocusNode();
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    // Auto-focus phone input on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocus.requestFocus();
    });

    // Listen for auth success → close sheet + fire callback
    _sub = context.read<AuthBloc>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && mounted) {
        Navigator.of(context).pop(true);
        // CRUCIAL: Execute the original intent after a short frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSuccess?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle Bar ──────────────────────────
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.inactive,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Content based on auth state ─────────
                if (state.status == AuthStatus.otpSent)
                  _buildOtpView(state)
                else
                  _buildPhoneView(state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Phone Input View ────────────────────────────────────
  Widget _buildPhoneView(AuthState state) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          l10n.authSheetTitle,
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.authSheetSubtitle,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),

        // Phone input
        TextFormField(
          controller: _phoneController,
          focusNode: _phoneFocus,
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
                  Container(width: 1, height: 24.h, color: AppTheme.inactive),
                ],
              ),
            ),
          ),
        ),

        // Error message
        if (state.error != null) ...[
          SizedBox(height: 8.h),
          Text(
            state.error!,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: AppTheme.liveBadge,
            ),
          ),
        ],

        SizedBox(height: 20.h),

        // Get Code button
        PrimaryButton(
          label: l10n.authGetCode,
          isLoading: state.isLoading,
          onPressed: () {
            final phone = _phoneController.text.trim();
            if (phone.length >= 10) {
              context.read<AuthBloc>().add(AuthOtpRequested(phone));
            }
          },
        ),
        SizedBox(height: 16.h),

        // ── Or divider + Google ──────────────────────
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
        SizedBox(height: 16.h),

        PrimaryButton(
          label: l10n.loginContinueGoogle,
          isOutlined: true,
          isLoading: state.isLoading,
          onPressed: () {
            context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
          },
        ),
      ],
    );
  }

  // ── OTP Verification View ───────────────────────────────
  Widget _buildOtpView(AuthState state) {
    final l10n = AppLocalizations.of(context);

    // Auto-focus OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocus.requestFocus();
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back to phone view
        TextButton.icon(
          onPressed: () {
            // Reset to guest so we show phone view again
            context.read<AuthBloc>().add(const AuthOtpCancelled());
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16.sp,
            color: AppTheme.textSecondary,
          ),
          label: Text(
            l10n.authChangeNumber,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        SizedBox(height: 16.h),

        // Title
        Text(
          l10n.authVerifyTitle,
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            children: [
              TextSpan(text: '${l10n.authCodeSentTo} '),
              TextSpan(
                text: '+964 ${state.phoneNumber ?? ''}',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // OTP Input
        TextFormField(
          controller: _otpController,
          focusNode: _otpFocus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.cairo(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 12.w,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '• • • • • •',
            hintStyle: GoogleFonts.cairo(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.inactive,
              letterSpacing: 12.w,
            ),
          ),
        ),

        // Error message
        if (state.error != null) ...[
          SizedBox(height: 8.h),
          Text(
            state.error!,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: AppTheme.liveBadge,
            ),
          ),
        ],

        SizedBox(height: 20.h),

        // Verify button
        PrimaryButton(
          label: l10n.authVerifyCode,
          isLoading: state.isLoading,
          onPressed: () {
            final otp = _otpController.text.trim();
            if (otp.isNotEmpty) {
              context.read<AuthBloc>().add(AuthOtpSubmitted(otp));
            }
          },
        ),
      ],
    );
  }
}
