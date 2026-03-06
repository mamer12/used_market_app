import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'النشاطات والمحفظة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The Wallet Card
            _buildWalletCard(),
            SizedBox(height: 16.h),

            // TabBar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.inactive.withValues(alpha: 0.1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppTheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.normal,
                  fontSize: 13.sp,
                ),
                tabs: const [
                  Tab(text: 'طلباتي'),
                  Tab(text: 'مزايداتي'),
                  Tab(text: 'مبيعاتي'),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyOrdersTab(),
                  _buildMyBidsTab(),
                  _buildMySalesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ], // Premium Green Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رصيد المحفظة',
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white54,
                size: 28.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '150,000 د.ع',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildWalletCTA(
                  icon: Icons.upload_rounded,
                  label: 'سحب الرصيد',
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildWalletCTA(
                  icon: Icons.download_rounded,
                  label: 'إيداع',
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCTA({
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isPrimary ? const Color(0xFF1B5E20) : Colors.white,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: isPrimary ? const Color(0xFF1B5E20) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 60.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersTab() {
    // List of Matajir/Balla purchases
    // Currently UI mocked, should connect to OrderCubit
    return _buildEmptyState(
      message: 'ليس لديك طلبات سابقة',
      icon: Icons.local_shipping_outlined,
      color: Colors.blueAccent,
    );
  }

  Widget _buildMyBidsTab() {
    // List of active auctions user is in. Green (winning) / Red (outbid)
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 2,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final isWinning = index == 0;
        final color = isWinning ? Colors.green : Colors.red;
        final status = isWinning ? 'أنت الفائز محلياً' : 'تمت المزايدة عليك';

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: NetworkImage('https://placehold.co/400x400/png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أيفون 14 برو ماكس',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'مزايدتك: 1,200,000 د.ع',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMySalesTab() {
    // Sold mustamal items or running a shop
    return _buildEmptyState(
      message: 'لا توجد مبيعات في انتظار التسليم',
      icon: Icons.store_mall_directory_outlined,
      color: Colors.orangeAccent,
    );
  }
}
