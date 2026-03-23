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

/// Full-page Registration screen — Stitch v2 step-by-step design.
///
/// Step 1: Full name
/// Step 2: City/governorate selector
/// Step 3: Profile photo (optional)
///
/// Fires [AuthRegistrationNameSubmitted] on final submit.
/// Navigates to Home `/` when [AuthStatus.authenticated].
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _selectedCity;
  String? _selectedRole;

  static const _iraqiCities = [
    'بغداد',
    'البصرة',
    'أربيل',
    'النجف',
    'كربلاء',
    'السليمانية',
    'دهوك',
    'الموصل',
    'كركوك',
    'بابل',
    'ديالى',
    'الأنبار',
    'واسط',
    'ذي قار',
    'ميسان',
    'المثنى',
    'القادسية',
    'صلاح الدين',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_selectedCity != null) {
        setState(() => _currentStep = 2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء اختيار المحافظة',
              style: GoogleFonts.tajawal(),
            ),
          ),
        );
      }
    } else if (_currentStep == 2) {
      _onSubmit();
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onSubmit() {
    context.read<AuthBloc>().add(
          AuthRegistrationNameSubmitted(
            fullName: _nameController.text.trim(),
            role: _selectedRole ?? 'user',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // -- Top bar with back button --
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.w, 8.h, 16.w, 0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 20.sp,
                        ),
                        onPressed: _onBack,
                      )
                    else
                      SizedBox(width: 48.w),
                    const Spacer(),
                    // Progress indicator
                    _StepIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                    ),
                    const Spacer(),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),

              // -- Content --
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStep(l10n),
                  ),
                ),
              ),

              // -- Bottom button --
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  24.w,
                  12.h,
                  24.w,
                  16.h,
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                  builder: (context, state) {
                    final label = _currentStep == 2
                        ? l10n.registerSubmit
                        : 'التالي';
                    return PrimaryButton(
                      label: label,
                      isLoading: state.isLoading && _currentStep == 2,
                      onPressed: _onNext,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _buildNameStep(l10n);
      case 1:
        return _buildCityStep(l10n);
      case 2:
        return _buildPhotoStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  // -- Step 1: Full name --
  Widget _buildNameStep(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('step_name'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Text(
            l10n.registerFullNameLabel,
            style: GoogleFonts.tajawal(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل اسمك الكامل كما تريد أن يظهر في ملفك',
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.registerFullNameHint,
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppTheme.textTertiary,
                size: 22.sp,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'الرجاء إدخال اسمك الكامل';
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
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
              );
            },
          ),
        ],
      ),
    );
  }

  // -- Step 2: City/governorate selector --
  Widget _buildCityStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step_city'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40.h),
        Text(
          'اختر محافظتك',
          style: GoogleFonts.tajawal(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'نحتاج معرفة موقعك لعرض المنتجات القريبة منك',
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 10.h,
          children: _iraqiCities.map((city) {
            final isSelected = _selectedCity == city;
            return GestureDetector(
              onTap: () => setState(() => _selectedCity = city),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  city,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // -- Step 3: Profile photo (optional) --
  Widget _buildPhotoStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step_photo'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40.h),
        Text(
          'أضف صورتك الشخصية',
          style: GoogleFonts.tajawal(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'اختياري — يمكنك إضافتها لاحقاً',
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        GestureDetector(
          onTap: () {
            // Photo picker placeholder
          },
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.divider,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: AppTheme.textTertiary,
                  size: 32.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  'اضغط للإضافة',
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h),

        // -- Role selection (compact) --
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.registerRoleTitle,
            style: GoogleFonts.tajawal(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _RoleCard(
          role: 'user',
          icon: Icons.shopping_bag_outlined,
          title: l10n.roleUser,
          description: l10n.roleUserDesc,
          isSelected: _selectedRole == 'user',
          onTap: () => setState(() => _selectedRole = 'user'),
        ),
        SizedBox(height: 10.h),
        _RoleCard(
          role: 'merchant',
          icon: Icons.storefront_outlined,
          title: l10n.roleMerchant,
          description: l10n.roleMerchantDesc,
          isSelected: _selectedRole == 'merchant',
          onTap: () => setState(() => _selectedRole = 'merchant'),
        ),
        SizedBox(height: 10.h),
        _RoleCard(
          role: 'auctioneer',
          icon: Icons.gavel_outlined,
          title: l10n.roleAuctioneer,
          description: l10n.roleAuctioneerDesc,
          isSelected: _selectedRole == 'auctioneer',
          onTap: () => setState(() => _selectedRole = 'auctioneer'),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

// -- Step Indicator --

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i <= currentStep;
        final isCurrent = i == currentStep;
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 3.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isCurrent ? 28.w : 10.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primary
                  : AppTheme.inactive.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        );
      }),
    );
  }
}

// -- _RoleCard --

class _RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.06)
              : AppTheme.surfaceAlt,
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primary,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
