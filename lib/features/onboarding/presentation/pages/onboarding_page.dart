import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/widgets/main_shell.dart';

/// Onboarding — 3-slide PageView with "Industrial Pop" aesthetics.
///
/// Shown only on first launch. "Start Browsing" enters guest mode
/// and navigates straight to HomePage (Lazy Auth pattern).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _startBrowsing();
    }
  }

  /// Enter guest mode and go to HomePage.
  void _startBrowsing() {
    context.read<AuthBloc>().add(const AuthGuestModeEntered());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  void _onSkip() {
    _startBrowsing();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final slides = [
      _SlideData(
        icon: Icons.verified_user_outlined,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      _SlideData(
        icon: Icons.camera_alt_outlined,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _SlideData(
        icon: Icons.gavel_outlined,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ─────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, right: 8.w, left: 8.w),
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    l10n.onboardingSkip,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inactive,
                    ),
                  ),
                ),
              ),
            ),

            // ── Page View ───────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _SlideWidget(data: slide);
                },
              ),
            ),

            // ── Dot Indicators ──────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 28.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.textPrimary
                          : AppTheme.inactive,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),

            // ── Start Browsing / Next Button ─────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: PrimaryButton(
                label: _currentPage == slides.length - 1
                    ? l10n.onboardingGetStarted
                    : l10n.onboardingNext,
                onPressed: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide Data Model ──────────────────────────────────────
class _SlideData {
  final IconData icon;
  final String title;
  final String description;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ── Individual Slide Widget ───────────────────────────────
class _SlideWidget extends StatelessWidget {
  final _SlideData data;

  const _SlideWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Illustration Placeholder ─────────────────
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80.sp, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 48.h),

          // ── Title ───────────────────────────────────
          Text(
            data.title,
            style: GoogleFonts.cairo(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // ── Description ─────────────────────────────
          Text(
            data.description,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
