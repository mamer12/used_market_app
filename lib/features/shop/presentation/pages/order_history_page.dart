import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final mockOrders = [
      {
        'id': 'ORD-8921',
        'date': '24 Feb 2026',
        'status': 'DELIVERED',
        'total': '145,000 IQD',
        'items': 2,
      },
      {
        'id': 'ORD-7743',
        'date': '20 Feb 2026',
        'status': 'PENDING_PAYMENT',
        'total': '32,000 IQD',
        'items': 1,
      },
      {
        'id': 'ORD-5190',
        'date': '10 Feb 2026',
        'status': 'CANCELLED',
        'total': '80,000 IQD',
        'items': 1,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Order History',
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
      body: mockOrders.isEmpty
          ? Center(
              child: Text(
                'No orders yet.',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: AppTheme.inactive,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: mockOrders.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final order = mockOrders[index];
                return _OrderCard(
                  id: order['id'] as String,
                  date: order['date'] as String,
                  status: order['status'] as String,
                  total: order['total'] as String,
                  itemsCount: order['items'] as int,
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String id;
  final String date;
  final String status;
  final String total;
  final int itemsCount;

  const _OrderCard({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.itemsCount,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'DELIVERED':
        statusColor = const Color(0xFF4CAF50); // Green
        break;
      case 'PENDING_PAYMENT':
        statusColor = AppTheme.primary; // Orange
        break;
      case 'CANCELLED':
        statusColor = AppTheme.error; // Red
        break;
      default:
        statusColor = AppTheme.textSecondary;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$id',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status.replaceAll('_', ' '),
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                date,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$itemsCount item${itemsCount > 1 ? 's' : ''}',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                total,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
