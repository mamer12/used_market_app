/// Models for GET /search?q= response.
///
/// The API returns three buckets:
///   - [SearchAuctionResult]  → `auctions` (condition = new) + `used` (condition = used_*)
///   - [SearchShopProductResult] → `shops`
library;

// ── Money helper ──────────────────────────────────────────────────────────

int _parseMoney(Object? v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

// ── Auction / Used result ─────────────────────────────────────────────────

class SearchAuctionResult {
  final String auctionId;
  final String? itemId;
  final String title;
  final String? description;
  final String? category;

  /// "new" | "used_good" | "used_fair"
  final String? condition;
  final int currentPrice;
  final DateTime? endTime;
  final List<String> images;

  /// "active" | "ended"
  final String status;

  const SearchAuctionResult({
    required this.auctionId,
    this.itemId,
    required this.title,
    this.description,
    this.category,
    this.condition,
    required this.currentPrice,
    this.endTime,
    required this.images,
    required this.status,
  });

  factory SearchAuctionResult.fromJson(Map<String, dynamic> json) {
    final rawEnd = json['end_time'] as String?;
    return SearchAuctionResult(
      auctionId: json['auction_id'] as String? ?? '',
      itemId: json['item_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      condition: json['condition'] as String?,
      currentPrice: _parseMoney(json['current_price']),
      endTime: rawEnd == null ? null : DateTime.tryParse(rawEnd),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
    );
  }
}

// ── Shop product result ───────────────────────────────────────────────────

class SearchShopProductResult {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final String? category;
  final int price;
  final List<String> images;

  const SearchShopProductResult({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    this.category,
    required this.price,
    required this.images,
  });

  factory SearchShopProductResult.fromJson(Map<String, dynamic> json) {
    return SearchShopProductResult(
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      price: _parseMoney(json['price']),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

// ── Unified response ──────────────────────────────────────────────────────

class SearchResponse {
  final String query;

  /// Active auctions with condition = "new"
  final List<SearchAuctionResult> auctions;

  /// Active auctions with condition = "used_good" | "used_fair"
  final List<SearchAuctionResult> used;

  /// Shop products matching the query
  final List<SearchShopProductResult> shops;

  const SearchResponse({
    required this.query,
    required this.auctions,
    required this.used,
    required this.shops,
  });

  int get totalCount => auctions.length + used.length + shops.length;

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fn) {
      return ((json[key] as List<dynamic>?) ?? [])
          .map((e) => fn(e as Map<String, dynamic>))
          .toList();
    }

    return SearchResponse(
      query: json['query'] as String? ?? '',
      auctions: parseList('auctions', SearchAuctionResult.fromJson),
      used: parseList('used', SearchAuctionResult.fromJson),
      shops: parseList('shops', SearchShopProductResult.fromJson),
    );
  }

  static SearchResponse empty(String query) => SearchResponse(
    query: query,
    auctions: const [],
    used: const [],
    shops: const [],
  );
}
