import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/flash_drop_cubit.dart';
import '../widgets/flash_drop_card.dart';

/// Browseable list of active flash drops.
class FlashDropsPage extends StatelessWidget {
  const FlashDropsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlashDropCubit>(
      create: (_) => getIt<FlashDropCubit>()..fetchActive(),
      child: const _FlashDropsView(),
    );
  }
}

class _FlashDropsView extends StatelessWidget {
  const _FlashDropsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F8),
        appBar: AppBar(
          title: Text(
            'حار ومكسب',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocConsumer<FlashDropCubit, FlashDropState>(
          listener: (context, state) {
            if (state is FlashDropPurchaseSuccess) {
              // Navigate to order confirmation or show success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم الشراء بنجاح! رقم الطلب: ${state.orderId}',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFF059669),
                  duration: const Duration(seconds: 3),
                ),
              );
              // Navigate to order details
              context.push('/activity');
            } else if (state is FlashDropPurchaseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'فشل الشراء: ${state.message}',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading for initial load or purchase in progress
            if (state is FlashDropLoading || state is FlashDropInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show loading overlay when purchasing
            if (state is FlashDropPurchasing) {
              return Stack(
                children: [
                  _buildError(context, 'جارٍ معالجة الشراء...'),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            }

            // Handle error states
            if (state is FlashDropError) {
              return _buildError(context, state.message);
            }

            // Main grid view when loaded
            if (state is FlashDropsLoaded) {
              if (state.drops.isEmpty) {
                return _buildEmpty();
              }
              return _buildGrid(context, state);
            }

            // After purchase success/error, re-fetch to show updated state
            if (state is FlashDropPurchaseSuccess ||
                state is FlashDropPurchaseError) {
              // Trigger re-fetch
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<FlashDropCubit>().fetchActive();
              });
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, FlashDropsLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<FlashDropCubit>().fetchActive(),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.65,
        ),
        itemCount: state.drops.length,
        itemBuilder: (context, index) {
          final drop = state.drops[index];
          return FlashDropCard(
            drop: drop,
            onBuyTap: () {
              // Dispatch purchase action via cubit
              context.read<FlashDropCubit>().purchaseFlashDrop(drop.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 64.sp,
            color: AppTheme.inactive,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عروض نشطة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تحقق لاحقاً للحصول على عروض حصرية',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 12.h),
          Text(
            'فشل تحميل العروض',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () => context.read<FlashDropCubit>().fetchActive(),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
