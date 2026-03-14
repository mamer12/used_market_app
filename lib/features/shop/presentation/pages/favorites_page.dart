import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

// ── In-memory favorites store (session-scoped; swap backing for persistence) ──

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  final List<FavoriteItem> _items = [];
  List<FavoriteItem> get items => List.unmodifiable(_items);

  Future<void> load() async {} // no-op; extend later with local storage

  bool isFavorite(String id) => _items.any((f) => f.id == id);

  void toggle(FavoriteItem item) {
    if (isFavorite(item.id)) {
      _items.removeWhere((f) => f.id == item.id);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}

class FavoriteItem {
  final String id;
  final String title;
  final String priceLabel;
  final String imageUrl;
  final String sooq; // matajir | balla | mustamal | mazadat

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.imageUrl,
    required this.sooq,
  });

  @override
  String toString() => '$id|||$title|||$priceLabel|||$imageUrl|||$sooq';

  static FavoriteItem? fromString(String s) {
    final parts = s.split('|||');
    if (parts.length != 5) return null;
    return FavoriteItem(
      id: parts[0],
      title: parts[1],
      priceLabel: parts[2],
      imageUrl: parts[3],
      sooq: parts[4],
    );
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _store = FavoritesStore.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
    _store.addListener(_rebuild);
  }

  Future<void> _init() async {
    await _store.load();
    if (mounted) setState(() => _loading = false);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_rebuild);
    super.dispose();
  }

  Color _sooqColor(String sooq) {
    switch (sooq) {
      case 'matajir':
        return AppTheme.matajirBlue;
      case 'balla':
        return AppTheme.ballaPurple;
      case 'mustamal':
        return const Color(0xFFEA580C);
      case 'mazadat':
        return const Color(0xFFFF3D5A);
      default:
        return AppTheme.textSecondary;
    }
  }

  String _sooqLabel(String sooq) {
    switch (sooq) {
      case 'matajir':
        return 'متاجر';
      case 'balla':
        return 'بلّع';
      case 'mustamal':
        return 'مستعمل';
      case 'mazadat':
        return 'مزادات';
      default:
        return sooq;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: AppTheme.textPrimary,
            onPressed: () => context.pop(),
          ),
          title: Text(
            'المفضلة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _store.items.isEmpty
                ? _buildEmpty()
                : _buildGrid(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 72.sp,
            color: AppTheme.inactive,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عناصر في المفضلة',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اضغط على ❤️ في أي منتج لإضافته هنا',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.inactive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.72,
        ),
        itemCount: _store.items.length,
        itemBuilder: (context, i) => _FavoriteCard(
          item: _store.items[i],
          sooqColor: _sooqColor(_store.items[i].sooq),
          sooqLabel: _sooqLabel(_store.items[i].sooq),
          onRemove: () => _store.remove(_store.items[i].id),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final Color sooqColor;
  final String sooqLabel;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.item,
    required this.sooqColor,
    required this.sooqLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx, err, st) => Container(
                      color: AppTheme.background,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppTheme.inactive,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
                // Sooq badge
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: sooqColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      sooqLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.priceLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: sooqColor,
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
