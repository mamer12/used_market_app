import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/shop_models.dart';
import '../bloc/create_shop_cubit.dart';

class CreateShopPage extends StatefulWidget {
  const CreateShopPage({super.key});

  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Data State
  String _shopType = 'physical'; // 'physical' or 'digital'

  // Step 2 Form
  final _profileFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();

  // Step 3 Form (Logistics)
  final _logisticsFormKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _instagramController = TextEditingController();
  final _streetController = TextEditingController();
  String? _storefrontPhotoPath;

  // Step 4 Form (KYC)
  String? _idCardPhotoPath;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _cityController.dispose();
    _instagramController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 1 && !_profileFormKey.currentState!.validate()) return;
    if (_currentStep == 2 && !_logisticsFormKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submit() {
    // KYC validation
    if (_idCardPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload your National ID.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final request = CreateShopRequest(
      name: _nameController.text,
      slug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
      description: _descController.text,
      category: _categoryController.text,
      shopType: _shopType,
      locationCity: _cityController.text,
      locationAddress: _streetController.text,
      instagramUrl: _instagramController.text,
      idCardUrl: _idCardPhotoPath,
      storefrontUrl: _storefrontPhotoPath,
    );

    context.read<CreateShopCubit>().createShop(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateShopCubit>(),
      child: BlocListener<CreateShopCubit, CreateShopState>(
        listener: (context, state) {
          if (state.status == CreateShopStatus.success) {
            Navigator.of(context).pop(); // close page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your shop is under review. We will notify you within 24 hours.',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: AppTheme.primary,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state.status == CreateShopStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error ?? 'Failed to create shop',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<CreateShopCubit, CreateShopState>(
          builder: (context, state) {
            final isLoading = state.status == CreateShopStatus.loading;
            return Scaffold(
              backgroundColor: AppTheme.surface,
              appBar: AppBar(
                backgroundColor: AppTheme.surface,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    _currentStep == 0
                        ? Icons.close
                        : Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: _prevStep,
                ),
                title: Text(
                  'Open Lugta Shop',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    _buildProgressBar(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1Type(),
                          _buildStep2Profile(),
                          _buildStep3Logistics(),
                          _buildStep4KYC(),
                          _buildStep5Review(),
                        ],
                      ),
                    ),
                    _buildBottomNav(isLoading),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 4 ? 0 : 4.w),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.inactive.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- STEP 1: SHOP TYPE ---
  Widget _buildStep1Type() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Shop Type',
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select the category that best describes your business model.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),

          // Physical Shop Radio
          _ShopTypeCard(
            title: 'Physical Store (محل واقعي)',
            subtitle:
                'I have a brick-and-mortar storefront for users to visit or pick up items.',
            icon: Icons.storefront_rounded,
            isSelected: _shopType == 'physical',
            onTap: () => setState(() => _shopType = 'physical'),
          ),
          SizedBox(height: 16.h),

          // eShop Radio
          _ShopTypeCard(
            title: 'Digital eShop (أونلاين)',
            subtitle:
                'I sell online from over Instagram or home without a verifiable physical map address.',
            icon: Icons.phone_iphone_rounded,
            isSelected: _shopType == 'digital',
            onTap: () => setState(() => _shopType = 'digital'),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: PROFILE ---
  Widget _buildStep2Profile() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Profile',
              style: GoogleFonts.cairo(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tell us about your brand.',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            _buildTextField(
              controller: _nameController,
              label: 'Shop Name (English & Arabic)',
              icon: Icons.business_rounded,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _categoryController,
              label: 'Category (e.g., Electronics, Fashion)',
              icon: Icons.category_rounded,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _descController,
              label: 'Short Bio',
              icon: Icons.text_snippet_rounded,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 3: LOGISTICS & LOCATION ---
  Widget _buildStep3Logistics() {
    final isPhysical = _shopType == 'physical';
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _logisticsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logistics & Location',
              style: GoogleFonts.cairo(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isPhysical
                  ? 'Adding a proven address increases trust.'
                  : 'Link your socials to build reputation.',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            if (isPhysical) ...[
              _buildLocationPinWidget(),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _streetController,
                label: 'Street / Building Info',
                icon: Icons.location_city_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16.h),
              _buildPhotoUploadWidget(
                title: 'Storefront Photo',
                subtitle: 'A clear picture of your store from the outside.',
                imagePath: _storefrontPhotoPath,
                onTap: () {
                  // MOCK IMAGE PICKER
                  setState(
                    () => _storefrontPhotoPath = 'mocked_store_photo.jpg',
                  );
                },
              ),
            ] else ...[
              _buildTextField(
                controller: _cityController,
                label: 'Base City (e.g. Baghdad, Basra)',
                icon: Icons.map_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _instagramController,
                label: 'Instagram Page Link',
                icon: Icons.link_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- STEP 4: KYC IDENTIFICATION ---
  Widget _buildStep4KYC() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner Identity (KYC)',
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Secure payouts via ZainCash/FIB require ID verification.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 32.h),
          _buildPhotoUploadWidget(
            title: 'Unified Card (البطاقة الموحدة)',
            subtitle: 'Clear, readable scan or photo of your official ID.',
            imagePath: _idCardPhotoPath,
            onTap: () {
              // MOCK
              setState(() => _idCardPhotoPath = 'mocked_id.jpg');
            },
          ),
        ],
      ),
    );
  }

  // --- STEP 5: REVIEW ---
  Widget _buildStep5Review() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 64.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Ready to Submit',
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'By tapping submit, you agree to Mustamal terms of service and business guidelines.\n\nYour application will be securely verified.',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildBottomNav(bool isLoading) {
    final isLast = _currentStep == 4;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: isLoading ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(
                    color: AppTheme.inactive.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppTheme.liveBadge : AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimary,
                      ),
                    )
                  : Text(
                      isLast ? 'Submit Application' : 'Continue',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 15.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          color: AppTheme.inactive,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.h : 0),
          child: Icon(icon, color: AppTheme.inactive, size: 22.sp),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLocationPinWidget() {
    return InkWell(
      onTap: () {
        // Mock pin dropping request
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('GPS Location Captured.')));
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.05),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_fixed_rounded, color: AppTheme.primary, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Drop GPS Pin',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.primary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUploadWidget({
    required String title,
    required String subtitle,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: imagePath != null
                ? AppTheme.primary
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(
              imagePath != null
                  ? Icons.check_circle_rounded
                  : Icons.add_a_photo_rounded,
              color: imagePath != null ? AppTheme.primary : AppTheme.inactive,
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              imagePath != null ? 'Uploaded Successfully' : title,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (imagePath == null) SizedBox(height: 4.h),
            if (imagePath == null)
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class _ShopTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShopTypeCard({
    required this.title,
    required this.subtitle,
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primary : AppTheme.inactive,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
