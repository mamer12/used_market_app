import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class ActiveBidsPage extends StatelessWidget {
  const ActiveBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final mockBids = [
      {
        'id': 'BID-102',
        'title': 'Vintage Leather Jacket',
        'currentBid': '45,000 IQD',
        'status': 'WINNING',
        'timeLeft': '2s',
      },
      {
        'id': 'BID-099',
        'title': 'iPhone 13 Pro',
        'currentBid': '650,000 IQD',
        'status': 'OUTBID',
        'timeLeft': 'Closed',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Active Bids',
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
      body: mockBids.isEmpty
          ? Center(
              child: Text(
                'No active bids.',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: AppTheme.inactive,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: mockBids.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final bid = mockBids[index];
                return _BidCard(
                  id: bid['id'] as String,
                  title: bid['title'] as String,
                  currentBid: bid['currentBid'] as String,
                  status: bid['status'] as String,
                  timeLeft: bid['timeLeft'] as String,
                );
              },
            ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final String id;
  final String title;
  final String currentBid;
  final String status;
  final String timeLeft;

  const _BidCard({
    required this.id,
    required this.title,
    required this.currentBid,
    required this.status,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'WINNING':
        statusColor = const Color(0xFF4CAF50); // Green
        break;
      case 'OUTBID':
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status,
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
                Icons.timer_outlined,
                size: 14.sp,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                timeLeft,
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
                'My Bid',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                currentBid,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.liveBadge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
