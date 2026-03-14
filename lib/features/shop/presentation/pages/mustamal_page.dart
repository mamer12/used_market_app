import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

class MustamalPage extends StatefulWidget {
  const MustamalPage({super.key});

  @override
  State<MustamalPage> createState() => _MustamalPageState();
}

class _MustamalPageState extends State<MustamalPage> {
  late final HomeCubit _cubit;
  final String _location = 'بغداد';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit, // Provide HomeCubit to fetch mustamal
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA), // Off-white clean
        body: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.background,
                elevation: 0,
                pinned: true,
                centerTitle: false,
                iconTheme: const IconThemeData(color: AppTheme.textPrimary),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).homeSooqUsed,
                      style: GoogleFonts.cairo(
                        color: AppTheme.textPrimary,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.secondary,
                          size: 10.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _location,
                          style: GoogleFonts.cairo(
                            color: AppTheme.secondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: AppTheme.secondary,
                        size: 20.sp,
                      ),
                    ),
                    onPressed: () => context.push('/mustamal/create'),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).mustamalSearchHint,
                        hintStyle: GoogleFonts.cairo(
                          color: AppTheme.inactive,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.secondary,
                          size: 22.sp,
                        ),
                        suffixIcon: Icon(
                          Icons.tune_rounded,
                          color: AppTheme.textPrimary,
                          size: 22.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                    ),
                  ),
                ),
              ),

              // Grid
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoading && state.portal.mustamal.isEmpty) {
                    return const SliverProductGridSkeleton();
                  }

                  final items = state.portal.mustamal;
                  if (items.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).homeNoProducts,
                          style: GoogleFonts.cairo(fontSize: 16.sp),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _MustamalCard(item: items[index]);
                      }, childCount: items.length),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MustamalCard extends StatelessWidget {
  final dynamic item;

  const _MustamalCard({required this.item});


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.title ?? l10n.mustamalNoTitle;
    final price = item.price ?? 0;
    final images = item.images ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.inactive.withValues(alpha: 0.1),
                    ),
                  )
                else
                  Container(color: AppTheme.inactive.withValues(alpha: 0.1)),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.mustamalOrange,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      l10n.mustamalUsedBadge,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        IqdFormatter.format(price),
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.mustamalViewDetails,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        height: 36.h,
                        width: 36.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: const Color(0xFF25D366),
                          size: 18.sp,
                        ),
                      ),
                    ],
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
