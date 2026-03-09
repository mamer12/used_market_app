import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../auction/data/models/auction_models.dart';
import '../../../home/data/models/portal_models.dart';
import '../../../shop/data/models/shop_models.dart';
import '../bloc/search_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field on entry as per plan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (val) => context.read<SearchCubit>().onQueryChanged(val),
          decoration: InputDecoration(
            hintText: 'Search for anything...',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF94A3B8),
              fontSize: 16.sp,
            ),
            border: InputBorder.none,
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return state.when(
            initial: () => _buildEmptyState('Start typing to find results'),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (results) {
              if (results.isEmpty) {
                return _buildEmptyState(
                  'No results found for "${_searchController.text}"',
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    if (item is AuctionModel)
                      return _SearchAuctionCard(auction: item);
                    if (item is ProductModel)
                      return _SearchProductCard(product: item);
                    if (item is ShopModel) return _SearchShopCard(shop: item);
                    if (item is ItemModel)
                      return _SearchMustamalCard(item: item);
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
            error: (msg) => Center(child: Text(msg)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAuctionCard extends StatelessWidget {
  final AuctionModel auction;
  const _SearchAuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (auction.images.isNotEmpty)
            Image.network(
              auction.images.first,
              fit: BoxFit.cover,
              height: 120.h,
              width: double.infinity,
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format((auction.currentPrice ?? 0).toDouble()),
                  style: GoogleFonts.cairo(
                    color: AppTheme.mazadRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final ProductModel product;
  const _SearchProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final themeColor = product.isBalla
        ? AppTheme.ballaPurple
        : AppTheme.matajirBlue;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (product.images.isNotEmpty)
            Image.network(
              product.images.first,
              fit: BoxFit.cover,
              height: 120.h,
              width: double.infinity,
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format(product.price),
                  style: GoogleFonts.cairo(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchShopCard extends StatelessWidget {
  final ShopModel shop;
  const _SearchShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: shop.imageUrl != null
                ? NetworkImage(shop.imageUrl!)
                : null,
            backgroundColor: const Color(0xFFF1F5F9),
            child: shop.imageUrl == null
                ? const Icon(Icons.storefront_rounded)
                : null,
          ),
          SizedBox(height: 8.h),
          Text(
            shop.name,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            shop.category ?? 'Shop',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchMustamalCard extends StatelessWidget {
  final ItemModel item;
  const _SearchMustamalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (item.images.isNotEmpty)
            Image.network(
              item.images.first,
              fit: BoxFit.cover,
              height: 120.h,
              width: double.infinity,
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format(item.price.toDouble()),
                  style: GoogleFonts.cairo(
                    color: AppTheme.mustamalOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
