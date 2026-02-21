import 'dart:async';

import 'package:flutter/material.dart';
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
  final _phoneFocus = FocusNode();
  final _nameController = TextEditingController();

  // 6 individual OTP controllers
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  StreamSubscription<AuthState>? _sub;

  // Resend timer
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;

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

      // Start resend timer when OTP is sent
      if (state.status == AuthStatus.otpSent) {
        _startResendTimer();
        // Auto-focus first OTP box
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
      }
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 30;
    _canResend = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _resendTimer?.cancel();
    _phoneController.dispose();
    _phoneFocus.dispose();
    _nameController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullOtp => _otpControllers.map((c) => c.text).join();

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
                if (state.status == AuthStatus.registrationNameRequired)
                  _buildNameView(state)
                else if (state.status == AuthStatus.otpSent)
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Lock Icon ─────────────────────────────
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EDF2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 20.h),

        // Title
        Text(
          l10n.authSheetTitle,
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),

        // Subtitle
        Text(
          l10n.authSheetSubtitle,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),

        // ── Phone Number Label ────────────────────
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.authPhoneLabel,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // ── Phone Input with Country Code ─────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Country code section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              // Phone number field
              Expanded(
                child: TextFormField(
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
                    hintText: '750 XXX XXXX',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.inactive,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // SMS hint text
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.authPhoneSmsHint,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
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
            if (phone.isNotEmpty) {
              context.read<AuthBloc>().add(AuthOtpRequested(phone));
            }
          },
        ),
        SizedBox(height: 16.h),

        // ── Use email / Need help links ──────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.authUseEmail,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.authNeedHelp,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── OTP Verification View ───────────────────────────────
  Widget _buildOtpView(AuthState state) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Lock Icon ─────────────────────────────
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 24.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        // Title
        Text(
          l10n.authVerifyTitle,
          style: GoogleFonts.cairo(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Code sent to + phone number + Edit
        Text(
          l10n.authCodeSentTo,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+964 ${state.phoneNumber ?? ''}',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthOtpCancelled());
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.authEdit,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 28.h),

        // ── 6 OTP Input Boxes ─────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final hasValue = _otpControllers[index].text.isNotEmpty;
            final hasFocus = _otpFocusNodes[index].hasFocus;

            return Container(
              width: 40.w,
              height: 52.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: hasFocus
                      ? AppTheme.textPrimary
                      : hasValue
                      ? AppTheme.textPrimary
                      : AppTheme.inactive.withValues(alpha: 0.5),
                  width: hasFocus || hasValue ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {}); // refresh border styling
                  if (value.isNotEmpty && index < 5) {
                    // Auto-advance to next box
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    // Go back on delete
                    _otpFocusNodes[index - 1].requestFocus();
                  }

                  // Auto-submit when all 6 digits entered
                  if (_fullOtp.length == 6) {
                    context.read<AuthBloc>().add(AuthOtpSubmitted(_fullOtp));
                  }
                },
              ),
            );
          }),
        ),

        // Error message
        if (state.error != null) ...[
          SizedBox(height: 12.h),
          Text(
            state.error!,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: AppTheme.liveBadge,
            ),
          ),
        ],

        SizedBox(height: 24.h),

        // Verify & Continue button
        PrimaryButton(
          label: l10n.authVerifyCode,
          isLoading: state.isLoading,
          onPressed: () {
            final otp = _fullOtp;
            if (otp.length == 6) {
              context.read<AuthBloc>().add(AuthOtpSubmitted(otp));
            }
          },
        ),
        SizedBox(height: 16.h),

        // ── Resend Timer ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.authResendCode,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(width: 8.w),
            if (!_canResend)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${(_resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(_resendSeconds % 60).toString().padLeft(2, '0')}',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () {
                  final phone =
                      context.read<AuthBloc>().state.phoneNumber ?? '';
                  if (phone.isNotEmpty) {
                    context.read<AuthBloc>().add(AuthOtpRequested(phone));
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Name Input View ──────────────────────────────────────
  Widget _buildNameView(AuthState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── User Icon ─────────────────────────────
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EDF2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 28.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 20.h),

        // Title
        Text(
          "Complete Your Profile",
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),

        // Subtitle
        Text(
          "Please enter your full name to finish registration.",
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),

        // ── Name Input ─────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Ali Mohammed',
              hintStyle: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.inactive,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
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

        // Submit Button
        PrimaryButton(
          label: "Complete Registration",
          isLoading: state.isLoading,
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              context.read<AuthBloc>().add(AuthRegistrationNameSubmitted(name));
            }
          },
        ),
        SizedBox(height: 16.h),

        // Cancel/Back
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthOtpCancelled());
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Cancel Log In",
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
