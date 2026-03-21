import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/shop_nearby_model.dart';
import '../cubit/map_cubit.dart';

/// محلتي — Hyperlocal Map page (list-based fallback, no map SDK needed).
///
/// Shows shops near the user's current location sorted by distance.
class MahallatiPage extends StatelessWidget {
  /// If provided, filter by sooq context (e.g. 'matajir', 'mustamal').
  final String? contextFilter;

  const MahallatiPage({super.key, this.contextFilter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MapCubit>()..loadNearbyShops(),
      child: _MahallatiView(contextFilter: contextFilter),
    );
  }
}

class _MahallatiView extends StatelessWidget {
  final String? contextFilter;
  const _MahallatiView({this.contextFilter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return _buildLoading();
        }
        if (state is MapError) {
          return _buildError(context, state.message);
        }
        if (state is MapLoaded) {
          var shops = state.shops;
          if (contextFilter != null) {
            shops = shops
                .where((s) => s.category == contextFilter)
                .toList();
          }
          if (shops.isEmpty) return _buildEmpty();
          return _buildList(context, shops);
        }
        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.matajirBlue),
          SizedBox(height: 16.h),
          Text(
            'جاري تحديد موقعك...',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                size: 56.sp, color: AppTheme.textSecondary),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<MapCubit>().loadNearbyShops(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.matajirBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined,
              size: 56.sp, color: AppTheme.textSecondary),
          SizedBox(height: 12.h),
          Text(
            'لا توجد محلات قريبة منك',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ShopNearbyModel> shops) {
    return Column(
      children: [
        // Map placeholder header
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFF9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.map_rounded,
                  size: 72.sp,
                  color: AppTheme.matajirBlue.withValues(alpha: 0.15)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_rounded,
                      size: 32.sp, color: AppTheme.matajirBlue),
                  SizedBox(height: 4.h),
                  Text(
                    'محلتي 📍',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.matajirBlue,
                    ),
                  ),
                  Text(
                    '${shops.length} محل قريب منك',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Shop list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
            itemCount: shops.length,
            separatorBuilder: (_, _) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return _ShopNearbyCard(shop: shop);
            },
          ),
        ),
      ],
    );
  }
}

class _ShopNearbyCard extends StatelessWidget {
  final ShopNearbyModel shop;
  const _ShopNearbyCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/matajir/shop/${shop.id}',
        extra: {'name': shop.name},
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Shop avatar
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppTheme.matajirBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        shop.name.isNotEmpty ? shop.name[0] : 'م',
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.matajirBlue,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 12.w),

            // Shop info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (shop.verificationStatus == 'verified')
                        Icon(Icons.verified_rounded,
                            color: AppTheme.success, size: 14.sp),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (shop.category != null)
                    Text(
                      shop.category!,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Distance badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.matajirBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_rounded,
                      size: 13.sp, color: AppTheme.matajirBlue),
                  SizedBox(width: 3.w),
                  Text(
                    shop.formattedDistance,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.matajirBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
