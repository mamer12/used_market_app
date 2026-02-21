import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shop/data/models/shop_models.dart';
import '../../../shop/presentation/bloc/shops_cubit.dart';
import '../../../shop/presentation/pages/shop_products_page.dart';

/// Search page — finds shops by name/slug and their products.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  late final ShopsCubit _shopsCubit;

  String _query = '';
  List<ShopModel> _filteredShops = [];

  @override
  void initState() {
    super.initState();
    _shopsCubit = getIt<ShopsCubit>()..loadShops();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _shopsCubit.close();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _queryController.text.trim().toLowerCase();
    setState(() {
      _query = q;
      _filteredShops = q.isEmpty
          ? _shopsCubit.state.shops
          : _shopsCubit.state.shops.where((s) {
              return s.name.toLowerCase().contains(q) ||
                  s.slug.toLowerCase().contains(q) ||
                  (s.description?.toLowerCase().contains(q) ?? false);
            }).toList();
    });
  }

  void _syncShops() {
    final q = _query;
    _filteredShops = q.isEmpty
        ? _shopsCubit.state.shops
        : _shopsCubit.state.shops.where((s) {
            return s.name.toLowerCase().contains(q) ||
                s.slug.toLowerCase().contains(q) ||
                (s.description?.toLowerCase().contains(q) ?? false);
          }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Sync filtered list on every build (after cubit emits)
    _syncShops();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Search',
            style: GoogleFonts.cairo(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(Icons.search, size: 24.sp, color: AppTheme.inactive),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _queryController,
                autofocus: false,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search shops & products…',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.inactive,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _queryController.clear();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppTheme.inactive,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_shopsCubit.state.isLoading && _shopsCubit.state.shops.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_query.isEmpty) {
      return _buildBrowseCategories();
    }

    if (_filteredShops.isEmpty) {
      return _buildNoResults();
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
      itemCount: _filteredShops.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, i) => _buildShopTile(_filteredShops[i]),
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      _Category('Electronics', Icons.devices, AppTheme.primary),
      _Category('Cars', Icons.directions_car, AppTheme.secondary),
      _Category('Furniture', Icons.chair_outlined, const Color(0xFF8BC34A)),
      _Category('Fashion', Icons.style_outlined, const Color(0xFFE91E63)),
      _Category('Services', Icons.handyman_outlined, const Color(0xFF00BCD4)),
      _Category('Books', Icons.menu_book_outlined, const Color(0xFF9C27B0)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Categories',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) => _buildCategoryTile(categories[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(_Category cat) {
    return GestureDetector(
      onTap: () {
        _queryController.text = cat.label;
      },
      child: Container(
        decoration: BoxDecoration(
          color: cat.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: cat.color.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat.icon, size: 28.sp, color: cat.color),
            SizedBox(height: 6.h),
            Text(
              cat.label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTile(ShopModel shop) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ShopProductsPage(
              shopSlug: shop.slug,
              shopName: shop.name,
            ),
          ),
        );
      },
      child: Container(
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shop.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '@${shop.slug}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: AppTheme.inactive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48.sp, color: AppTheme.inactive),
          SizedBox(height: 12.h),
          Text(
            'No results for "$_query"',
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
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;

  const _Category(this.label, this.icon, this.color);
}
