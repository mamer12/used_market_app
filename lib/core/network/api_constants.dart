import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Resolved host for all API calls.
  ///
  /// - Debug builds  → LAN IP of the dev machine (works for both iOS
  ///   Simulator and a physical device on the same WiFi).
  ///   Update [_devHost] whenever your Mac's IP changes.
  /// - Android emulator always routes to the host machine via 10.0.2.2.
  /// - Release builds → use the [_prodHost] constant.
  ///
  /// Override at any time with --dart-define=DEV_HOST=YOUR_IP.
  static const String _devHost =
      '192.168.68.109'; // <-- localhost for iOS Simulator
  static const String _prodHost = 'api.mustamal.com'; // <-- your prod domain

  static String get _host {
    // Explicit override wins (useful for CI or a different dev machine).
    const override = String.fromEnvironment('DEV_HOST');
    if (override.isNotEmpty) return override;

    if (kReleaseMode) return _prodHost;

    // Debug / profile
    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator loopback
    return _devHost; // iOS Simulator + physical iPhone on same LAN
  }

  /// REST API Base URL
  static String get baseUrl => 'http://$_host:8080/api/v1/';

  /// WebSocket Base URL
  static String get wsBaseUrl => 'ws://$_host:8080/ws';

  /// Media Server Base URL
  static String get mediaBaseUrl => 'http://$_host:9000/lugta-media';

  // --- Auth Endpoints ---
  static const String sendOtp = 'auth/otp/send';
  static const String register = 'auth/otp/register';
  static const String login = 'auth/otp/login';

  // --- Media Endpoints ---
  static const String mediaUpload = 'media';

  // --- Auction Endpoints ---
  static const String auctions =
      'auctions'; // GET (list/details), POST (create)

  // --- Listing Endpoints (C2C) ---
  static const String listingsMustamal = 'listings/mustamal'; // POST

  // --- Shop Endpoints ---
  static const String shops = 'shops'; // GET (list)
  static const String shopsApply = 'shops/apply'; // POST (create)

  // --- Cart Endpoints ---
  static const String cart = 'cart'; // GET (list), POST (add), DELETE (clear)

  // --- Saved Items / Wishlist ---
  static const String savedItems = 'saved-items'; // GET, POST, DELETE

  // --- Order Endpoints ---
  static const String ordersShop = 'orders/shop'; // POST (buy)
  static const String ordersMe = 'orders/me'; // GET (my orders)
  static const String ordersStatus = 'orders'; // PATCH /:id/status

  // --- User Endpoints ---
  static const String usersMe =
      'users/me'; // GET (current user), PATCH (update profile)

  // --- Invoices ---
  static const String invoicesMe = 'invoices/me'; // GET (my invoices)

  // --- Categories ---
  static const String categories = 'categories'; // GET ?app_context=&parent_id=

  // --- Portal / BFF ---
  static const String mobileHome = 'mobile/home'; // GET (super-app home screen)

  // --- Second Chance ---
  /// POST /auctions/{id}/second-chance/accept
  static String secondChanceAccept(String auctionId) =>
      'auctions/$auctionId/second-chance/accept';

  // --- Auth (password-based) ---
  static const String authRegisterPassword = 'auth/register';
  static const String authLoginPassword = 'auth/login';

  // --- Search ---
  static const String search = 'search'; // GET ?q=
}
