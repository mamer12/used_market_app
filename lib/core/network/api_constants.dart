import 'dart:io';

class ApiConstants {
  // Returns the appropriate localhost IP depending on the platform
  static String get _localhost {
    if (Platform.isAndroid) {
      return '10.0.2.2'; // Android Emulator alias for host loopback
    } else {
      return 'localhost'; // iOS Simulator & others
    }
  }

  /// REST API Base URL
  static String get baseUrl => 'http://$_localhost:8080/api/v1';

  /// WebSocket Base URL
  static String get wsBaseUrl => 'ws://$_localhost:8080/ws';

  /// Media Server Base URL (Assuming it runs on port 9000 like in the docs)
  static String get mediaBaseUrl => 'http://$_localhost:9000/lugta-media';

  // --- Auth Endpoints ---
  static const String sendOtp = '/auth/otp/send';
  static const String register = '/auth/otp/register';
  static const String login = '/auth/otp/login';

  // --- Media Endpoints ---
  static const String mediaUpload = '/media';

  // --- Auction Endpoints ---
  static const String auctions =
      '/auctions'; // GET (list/details), POST (create)

  // --- Shop Endpoints ---
  static const String shops = '/shops'; // POST

  // --- Cart Endpoints ---
  static const String cart = '/cart'; // GET (list), POST (add), DELETE (clear)

  // --- Saved Items / Wishlist ---
  static const String savedItems = '/saved-items'; // GET, POST, DELETE

  // --- Order Endpoints ---
  static const String ordersShop = '/orders/shop'; // POST (buy)
  static const String ordersMe = '/orders/me'; // GET (my orders)

  // --- User Endpoints ---
  static const String usersMe = '/users/me'; // GET (current user)

  // --- Auth (password-based) ---
  static const String authRegisterPassword = '/auth/register';
  static const String authLoginPassword = '/auth/login';
}
