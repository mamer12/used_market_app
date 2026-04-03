import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/auth_status.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Single-page Registration screen — "إنشاء حساب جديد".
///
/// Design: RTL Arabic, Tajawal font, Mustamal warm palette.
/// Fires [AuthRegistrationNameSubmitted] on submit.
/// Navigates to `/` when [AuthStatus.authenticated].
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  File? _avatarFile;
  String? _selectedCity;
  // 'user' = مشتري, 'merchant' = بائع
  String _selectedRole = 'user';
  bool _consentAccepted = false;

  static const _iraqiCities = [
    'بغداد',
    'أربيل',
    'البصرة',
    'الموصل',
    'النجف',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCity == null) {
      _showError('الرجاء اختيار المدينة');
      return;
    }
    if (!_consentAccepted) {
      _showError('يجب الموافقة على الشروط والأحكام للمتابعة');
      return;
    }
    context.read<AuthBloc>().add(
          AuthRegistrationNameSubmitted(
            fullName: _nameController.text.trim(),
            role: _selectedRole,
          ),
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16.h),
                        _buildHeader(),
                        SizedBox(height: 28.h),
                        _AvatarPicker(
                          file: _avatarFile,
                          onTap: _pickAvatar,
                        ),
                        SizedBox(height: 28.h),
                        _buildNameField(),
                        SizedBox(height: 16.h),
                        _buildUsernameField(),
                        SizedBox(height: 16.h),
                        _buildCityDropdown(),
                        SizedBox(height: 20.h),
                        _buildAccountTypeToggle(),
                        SizedBox(height: 20.h),
                        _buildConsentCheckbox(),
                        SizedBox(height: 16.h),
                        _buildErrorWidget(),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إنشاء حساب جديد',
            style: GoogleFonts.tajawal(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'أدخل بياناتك لإنشاء حسابك في مضمون',
            style: GoogleFonts.tajawal(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.tajawal(
        fontSize: 15.sp,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'الاسم الكامل',
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppTheme.textTertiary,
          size: 20.sp,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().length < 2) {
          return 'الرجاء إدخال الاسم الكامل';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      autocorrect: false,
      style: GoogleFonts.tajawal(
        fontSize: 15.sp,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'اسم المستخدم',
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
        ),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 14.w, end: 8.w),
          child: Text(
            '@',
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال اسم المستخدم';
        }
        final username = value.trim();
        if (username.length < 3) {
          return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
          return 'يُسمح فقط بالحروف الإنجليزية والأرقام والشرطة السفلية';
        }
        return null;
      },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      isExpanded: true,
      style: GoogleFonts.tajawal(
        fontSize: 15.sp,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'المدينة',
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
        ),
        prefixIcon: Icon(
          Icons.location_city_outlined,
          color: AppTheme.textTertiary,
          size: 20.sp,
        ),
      ),
      hint: Text(
        'اختر مدينتك',
        style: GoogleFonts.tajawal(
          fontSize: 14.sp,
          color: AppTheme.textTertiary,
        ),
      ),
      items: _iraqiCities
          .map(
            (city) => DropdownMenuItem(
              value: city,
              child: Text(city, style: GoogleFonts.tajawal(fontSize: 15.sp)),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedCity = value),
      validator: (_) =>
          _selectedCity == null ? 'الرجاء اختيار المدينة' : null,
    );
  }

  Widget _buildAccountTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الحساب',
          style: GoogleFonts.tajawal(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _AccountTypeOption(
                label: 'مشتري',
                icon: Icons.shopping_bag_outlined,
                isSelected: _selectedRole == 'user',
                onTap: () => setState(() => _selectedRole = 'user'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _AccountTypeOption(
                label: 'بائع',
                icon: Icons.storefront_outlined,
                isSelected: _selectedRole == 'merchant',
                onTap: () => setState(() => _selectedRole = 'merchant'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsentCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.w,
          child: Checkbox(
            value: _consentAccepted,
            activeColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            onChanged: (value) =>
                setState(() => _consentAccepted = value ?? false),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: navigate to terms page
                    },
                ),
                const TextSpan(text: ' و'),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: navigate to privacy page
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev.error != curr.error,
      builder: (context, state) {
        if (state.error == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
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
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24.w, 8.h, 24.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
            builder: (context, state) {
              return PrimaryButton(
                label: 'إنشاء الحساب',
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              );
            },
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'لديك حساب؟',
                style: GoogleFonts.tajawal(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar Picker ─────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _AvatarPicker({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CircleAvatar(
            radius: 54.r,
            backgroundColor: AppTheme.surface,
            backgroundImage: file != null ? FileImage(file!) : null,
            child: file == null
                ? Icon(
                    Icons.person_outline_rounded,
                    size: 40.sp,
                    color: AppTheme.textTertiary,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.background, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 13.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'أضف صورة',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account Type Option ───────────────────────────────────────────────────────

class _AccountTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeOption({
    required this.label,
    required this.icon,
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
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.07)
              : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14.sp,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
