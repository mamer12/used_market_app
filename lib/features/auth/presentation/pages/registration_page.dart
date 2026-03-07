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

/// Full-page Registration screen — Name + Role selection.
///
/// Fires [AuthRegistrationNameSubmitted] on submit.
/// Navigates to Home `/` when [AuthStatus.authenticated].
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if ((_formKey.currentState?.validate() ?? false) && _selectedRole != null) {
      context.read<AuthBloc>().add(
        AuthRegistrationNameSubmitted(
          fullName: _nameController.text.trim(),
          role: _selectedRole!,
        ),
      );
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).registerRoleTitle,
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 48.h),

                  // ── Step indicator ──────────────────────────────────
                  Text(
                    l10n.registerStepLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // ── Title ─────────────────────────────────────────
                  Text(
                    l10n.registerTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // ── Name field ────────────────────────────────────
                  Text(
                    l10n.registerFullNameLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.registerFullNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'الرجاء إدخال اسمك الكامل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),

                  // ── Role selection ────────────────────────────────
                  Text(
                    l10n.registerRoleTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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

                  // ── Error ─────────────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.error != curr.error,
                    builder: (context, state) {
                      if (state.error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Text(
                          state.error!,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: Colors.red.shade700,
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Submit button ─────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                    builder: (context, state) {
                      return PrimaryButton(
                        label: l10n.registerSubmit,
                        isLoading: state.isLoading,
                        onPressed: _selectedRole != null
                            ? () => _onSubmit(context)
                            : null,
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _RoleCard ─────────────────────────────────────────────────────────────────

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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.06)
              : AppTheme.surface,
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.inactive,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
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
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primary, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
