import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../data/models/search_models.dart';

/// Federated search page — queries GET /search?q= and shows three result
/// buckets (new auctions, used auctions, shop products) across tabs.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _queryController = TextEditingController();
  final _ds = getIt<SearchRemoteDataSource>();
  final _fmt = NumberFormat('#,###');

  late TabController _tabController;
  Timer? _debounce;

  String _query = '';
  bool _loading = false;
  String? _error;
  SearchResponse? _result;

  static const _minChars = 2;
  static const _debounceMs = 400;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _queryController.text.trim();
    if (q == _query) return;
    setState(() => _query = q);

    _debounce?.cancel();
    if (q.length < _minChars) {
      setState(() {
        _result = null;
        _error = null;
        _loading = false;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _search(q),
    );
  }

  Future<void> _search(String q) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _ds.search(q);
      if (!mounted) return;
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _iqd(int fils) => '${_fmt.format(fils)} د.ع';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final allItems = _result == null
        ? <_SearchItem>[]
        : [
            ..._result!.auctions.map(_SearchItem.fromAuction),
            ..._result!.used.map(_SearchItem.fromUsed),
            ..._result!.shops.map(_SearchItem.fromShop),
          ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(l10n),
            if (_result != null && !_loading) _buildTabBar(l10n),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _error != null
                  ? _buildError(_error!)
                  : _result == null
                  ? _buildIdle(l10n)
                  : _result!.totalCount == 0
                  ? _buildNoResults(l10n)
                  : _buildResults(l10n, allItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _queryController,
          autofocus: true,
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textSecondary,
              size: 22.sp,
            ),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _queryController.clear();
                      setState(() {
                        _query = '';
                        _result = null;
                        _error = null;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    final aCount = _result?.auctions.length ?? 0;
    final uCount = _result?.used.length ?? 0;
    final sCount = _result?.shops.length ?? 0;
    final total = aCount + uCount + sCount;

    String tab(String label, int count) =>
        count > 0 ? '$label ($count)' : label;

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppTheme.primary,
      unselectedLabelColor: AppTheme.textSecondary,
      indicatorColor: AppTheme.primary,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: tab(l10n.searchTabAll, total)),
        Tab(text: tab(l10n.searchTabAuctions, aCount)),
        Tab(text: tab(l10n.searchTabUsed, uCount)),
        Tab(text: tab(l10n.searchTabShops, sCount)),
      ],
    );
  }

  Widget _buildIdle(AppLocalizations l10n) {
    return _CenteredState(
      icon: Icons.search_rounded,
      iconColor: AppTheme.inactive,
      title: l10n.searchEmpty,
      subtitle: _query.length == 1 ? l10n.searchMinChars : l10n.searchEmptySub,
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    return _CenteredState(
      icon: Icons.inbox_rounded,
      iconColor: AppTheme.inactive,
      title: l10n.searchNoResults,
      subtitle: l10n.searchNoResultsSub(_query),
    );
  }

  Widget _buildError(String msg) {
    return _CenteredState(
      icon: Icons.wifi_off_rounded,
      iconColor: AppTheme.liveBadge,
      title: 'خطأ في الاتصال',
      subtitle: msg,
    );
  }

  Widget _buildResults(AppLocalizations l10n, List<_SearchItem> all) {
    final auctions = _result!.auctions.map(_SearchItem.fromAuction).toList();
    final used = _result!.used.map(_SearchItem.fromUsed).toList();
    final shops = _result!.shops.map(_SearchItem.fromShop).toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _ItemList(items: all, iqd: _iqd),
        _ItemList(items: auctions, iqd: _iqd),
        _ItemList(items: used, iqd: _iqd),
        _ItemList(items: shops, iqd: _iqd),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Unified search item
// ═══════════════════════════════════════════════════════════════

enum _SearchItemKind { auction, used, shop }

class _SearchItem {
  final _SearchItemKind kind;
  final String title;
  final String? subtitle;
  final int price;
  final List<String> images;
  final DateTime? endTime;

  const _SearchItem({
    required this.kind,
    required this.title,
    this.subtitle,
    required this.price,
    required this.images,
    this.endTime,
  });

  static _SearchItem fromAuction(SearchAuctionResult r) => _SearchItem(
    kind: _SearchItemKind.auction,
    title: r.title,
    subtitle: r.category,
    price: r.currentPrice,
    images: r.images,
    endTime: r.endTime,
  );

  static _SearchItem fromUsed(SearchAuctionResult r) => _SearchItem(
    kind: _SearchItemKind.used,
    title: r.title,
    subtitle: r.category,
    price: r.currentPrice,
    images: r.images,
    endTime: r.endTime,
  );

  static _SearchItem fromShop(SearchShopProductResult r) => _SearchItem(
    kind: _SearchItemKind.shop,
    title: r.name,
    subtitle: r.category,
    price: r.price,
    images: r.images,
  );
}

// ═══════════════════════════════════════════════════════════════
// Scrollable list of result cards
// ═══════════════════════════════════════════════════════════════

class _ItemList extends StatelessWidget {
  final List<_SearchItem> items;
  final String Function(int) iqd;

  const _ItemList({required this.items, required this.iqd});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Icon(Icons.inbox_rounded, size: 48.sp, color: AppTheme.inactive),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _SearchCard(item: items[i], iqd: iqd),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Single result card
// ═══════════════════════════════════════════════════════════════

class _SearchCard extends StatelessWidget {
  final _SearchItem item;
  final String Function(int) iqd;

  const _SearchCard({required this.item, required this.iqd});

  @override
  Widget build(BuildContext context) {
    final thumb = item.images.isNotEmpty ? item.images.first : null;

    final (badgeLabel, badgeColor) = switch (item.kind) {
      _SearchItemKind.auction => ('مزاد جديد', AppTheme.liveBadge),
      _SearchItemKind.used => ('مستعمل', AppTheme.secondary),
      _SearchItemKind.shop => ('متجر', AppTheme.primary),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(14.r)),
            child: SizedBox(
              width: 90.w,
              height: 90.w,
              child: thumb != null
                  ? Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12.h,
              ).copyWith(left: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      child: Text(
                        badgeLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle!,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    iqd(item.price),
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: AppTheme.surface,
    child: const Icon(Icons.image_outlined, color: AppTheme.inactive, size: 28),
  );
}

// ═══════════════════════════════════════════════════════════════
// Reusable centered-state widget
// ═══════════════════════════════════════════════════════════════

class _CenteredState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _CenteredState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.sp, color: iconColor),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
