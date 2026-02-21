/// Server-side models for Cart and Wishlist (Saved Items).
///
/// These are plain Dart classes (no freezed) used purely for
/// serialising requests and deserialising API responses.
library;

// ── Cart Item ─────────────────────────────────────────────────────────────

/// A cart item as returned by GET /cart or POST /cart.
class CartItemServerModel {
  final String id;
  final String userId;

  /// "shop_product" | "auction"
  final String itemType;

  /// UUID of the product or auction
  final String referenceId;
  final int quantity;
  final String? createdAt;
  final String? updatedAt;

  const CartItemServerModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.referenceId,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItemServerModel.fromJson(Map<String, dynamic> json) {
    return CartItemServerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? 'shop_product',
      referenceId: json['reference_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

// ── Add / Update Requests ────────────────────────────────────────────────

class AddToCartRequest {
  final String itemType;
  final String referenceId;
  final int quantity;

  const AddToCartRequest({
    required this.itemType,
    required this.referenceId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'item_type': itemType,
        'reference_id': referenceId,
        'quantity': quantity,
      };
}

class UpdateCartQuantityRequest {
  final int quantity;

  const UpdateCartQuantityRequest({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity};
}

// ── Saved Items (Wishlist) ────────────────────────────────────────────────

/// A saved item as returned by GET /saved-items or POST /saved-items.
class SavedItemServerModel {
  final String id;
  final String userId;

  /// "shop_product" | "auction"
  final String itemType;

  /// UUID of the product or auction
  final String referenceId;
  final String? createdAt;

  const SavedItemServerModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.referenceId,
    this.createdAt,
  });

  factory SavedItemServerModel.fromJson(Map<String, dynamic> json) {
    return SavedItemServerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? 'shop_product',
      referenceId: json['reference_id'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }
}

class AddSavedItemRequest {
  final String itemType;
  final String referenceId;

  const AddSavedItemRequest({
    required this.itemType,
    required this.referenceId,
  });

  Map<String, dynamic> toJson() => {
        'item_type': itemType,
        'reference_id': referenceId,
      };
}
