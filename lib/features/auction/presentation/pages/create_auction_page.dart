import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _reservePriceController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startPriceController.dispose();
    _reservePriceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.auctionSelectTimesError,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Mock API Call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.auctionCreatedSuccess, style: GoogleFonts.cairo()),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(hours: isStart ? 1 : 24)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.auctionCreateTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                SizedBox(height: 32.h),

                _buildTextField(
                  controller: _titleController,
                  label: l10n.auctionFieldTitle,
                  icon: Icons.gavel_rounded,
                  validator: (v) =>
                      v!.isEmpty ? l10n.auctionFieldRequired : null,
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: _descController,
                  label: l10n.auctionFieldDescription,
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      v!.isEmpty ? l10n.auctionFieldRequired : null,
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _startPriceController,
                        label: l10n.auctionFieldStartPrice,
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? l10n.auctionFieldRequired : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _reservePriceController,
                        label: l10n.auctionFieldReservePrice,
                        icon: Icons.monetization_on_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Date Time Pickers
                Text(
                  l10n.auctionDuration,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        title: l10n.auctionStarts,
                        time: _startTime,
                        placeholder: l10n.auctionSelectTime,
                        onTap: () => _pickDateTime(true),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTimeSelector(
                        title: l10n.auctionEnds,
                        time: _endTime,
                        placeholder: l10n.auctionSelectTime,
                        onTap: () => _pickDateTime(false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                _buildSubmitButton(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.liveBadge.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.liveBadge.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppTheme.liveBadge.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_rounded,
              size: 32.sp,
              color: AppTheme.liveBadge,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.auctionHostTitle,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.auctionHostSub,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required DateTime? time,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final format = time != null
        ? '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, "0")}'
        : placeholder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.inactive,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16.sp,
                  color: AppTheme.liveBadge,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    format,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.inactive,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 70.h : 0),
          child: Icon(icon, color: AppTheme.inactive, size: 22.sp),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppTheme.liveBadge),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: _isLoading ? AppTheme.inactive : AppTheme.liveBadge,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.liveBadge.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textPrimary,
                  ),
                )
              : Text(
                  l10n.auctionLaunchBtn,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
