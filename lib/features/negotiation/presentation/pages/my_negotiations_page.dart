import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/negotiation_model.dart';
import '../cubit/negotiation_cubit.dart';

class MyNegotiationsPage extends StatelessWidget {
  const MyNegotiationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NegotiationCubit>()..fetchMyNegotiations(),
      child: const _MyNegotiationsView(),
    );
  }
}

class _MyNegotiationsView extends StatelessWidget {
  const _MyNegotiationsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'عروضي',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        backgroundColor: const Color(0xFFF6F6F8),
        body: BlocBuilder<NegotiationCubit, NegotiationState>(
          builder: (context, state) {
            if (state is NegotiationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NegotiationError) {
              return _buildError(context, state.message);
            }
            if (state is NegotiationLoaded) {
              if (state.negotiations.isEmpty) {
                return _buildEmpty();
              }
              return _buildList(state.negotiations);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildList(List<NegotiationModel> negotiations) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: negotiations.length,
      itemBuilder: (context, index) =>
          _NegotiationCard(negotiation: negotiations[index]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عروض نشطة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ابدأ التفاوض على منتج يعجبك',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
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
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
          SizedBox(height: 12.h),
          Text(
            message,
            style: GoogleFonts.cairo(
                fontSize: 14.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () =>
                context.read<NegotiationCubit>().fetchMyNegotiations(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Negotiation Card ──────────────────────────────────────────────────────────

class _NegotiationCard extends StatelessWidget {
  final NegotiationModel negotiation;

  const _NegotiationCard({required this.negotiation});

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(negotiation.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title + badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  negotiation.productTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: badge.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge.label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: badge.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Price row
          _PriceRow(
            label: 'عرضك',
            value: negotiation.formattedOfferedPrice,
            color: const Color(0xFFEA580C),
          ),
          if (negotiation.counterPrice != null) ...[
            SizedBox(height: 4.h),
            _PriceRow(
              label: 'عرض البائع',
              value: negotiation.formattedCounterPrice!,
              color: Colors.blue.shade700,
            ),
          ],

          // Pay now button for accepted
          if (negotiation.status == 'accepted') ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: navigate to payment page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'ادفع الآن',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BadgeData _statusBadge(String status) {
    switch (status) {
      case 'pending':
        return _BadgeData(
            label: 'بانتظار رد البائع ⏳', color: Colors.orange.shade700);
      case 'countered':
        return _BadgeData(
            label: 'البائع عرض مضاداً ↔', color: Colors.blue.shade700);
      case 'accepted':
        return _BadgeData(
            label: '✅ تم الاتفاق — ادفع الآن',
            color: Colors.green.shade700);
      case 'rejected':
        return _BadgeData(label: '❌ مرفوض', color: Colors.red.shade700);
      case 'expired':
        return _BadgeData(label: 'انتهت المدة', color: Colors.grey.shade600);
      default:
        return _BadgeData(label: status, color: Colors.grey.shade600);
    }
  }
}

class _BadgeData {
  final String label;
  final Color color;

  _BadgeData({required this.label, required this.color});
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
