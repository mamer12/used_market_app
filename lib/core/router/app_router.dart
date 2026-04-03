import 'dart:async';

import '../cubit/sooq_config_cubit.dart';
import '../pages/coming_soon_page.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Sooq native pages removed - now using WebView
// import '../../features/auction/presentation/pages/mazadat_shell_page.dart';
import '../../features/auth/domain/entities/auth_status.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
// Cart/Checkout pages removed - now in WebView
// import '../../features/cart/presentation/cubit/balla_cart_cubit.dart';
// import '../../features/cart/presentation/cubit/matajir_cart_cubit.dart';
// Sooq creation pages removed - now in WebView
// import '../../features/home/presentation/pages/add_balla_page.dart';
// import '../../features/home/presentation/pages/create_mustamal_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
// Messages pages removed - now in WebView
// import '../../features/messages/presentation/pages/chat_page.dart';
// import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/pages/activity_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/shop/presentation/pages/favorites_page.dart';
import '../../features/shop/presentation/pages/shipping_address_page.dart';
// Sooq shop pages removed - now in WebView
// import '../../features/shop/presentation/pages/balla_page.dart';
// import '../../features/shop/presentation/pages/matajir_shell_page.dart';
// import '../../features/shop/presentation/pages/mustamal_page.dart';
import '../../features/map/presentation/pages/mahallati_page.dart';
// Flash Drops pages removed - now in WebView
// import '../../features/flash_drops/presentation/pages/flash_drops_page.dart';
import '../../features/group_buy/presentation/pages/create_group_buy_page.dart';
import '../../features/group_buy/presentation/pages/group_buy_list_page.dart';
import '../../features/group_buy/presentation/pages/group_buy_page.dart';
import '../../features/negotiation/presentation/pages/my_negotiations_page.dart';
import '../../features/stories/presentation/pages/create_story_page.dart';
import '../../features/stories/presentation/pages/story_viewer_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/seller/presentation/pages/seller_dashboard_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
// import '../di/injection.dart'; // Not currently used
import '../widgets/main_shell.dart';
import '../widgets/sooq_webview.dart';

/// Global navigator key to access top-level context anywhere if needed.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Nested shell navigator keys
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _messagesNavKey = GlobalKey<NavigatorState>(debugLabel: 'messagesNav');
final _activityNavKey = GlobalKey<NavigatorState>(debugLabel: 'activityNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// Routes that are accessible without authentication.
const _publicPaths = [
  '/splash',
  '/onboarding',
  '/login',
  '/verify-otp',
  '/register',
];

/// The main router for the application.
///
/// Uses go_router's `redirect` to enforce mandatory authentication.
/// Users must be [AuthStatus.authenticated] to access any route outside
/// of [_publicPaths].
GoRouter buildAppRouter(AuthBloc authBloc, SooqConfigCubit sooqConfigCubit) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final status = authState.status;
      final location = state.matchedLocation;

      // 1. While checking session → show splash
      if (status == AuthStatus.initial) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuth = status == AuthStatus.authenticated;

      // 2. The session check finished, and the user is on the splash screen.
      // We must explicitly return a new path so they don't get stuck here.
      if (location == '/splash') {
        if (isAuth) return '/';
        return authState.hasOnboarded ? '/login' : '/onboarding';
      }

      final isPublic = _publicPaths.any((p) => location.startsWith(p));

      // 3. Unauthenticated + not on a public path → /login
      if (!isAuth && !isPublic) {
        if (!authState.hasOnboarded && location == '/') {
          return '/onboarding';
        }
        return '/login';
      }

      // 4. Already authenticated + trying to access logged-out pages → /
      if (isAuth &&
          (location == '/login' ||
              location == '/register' ||
              location == '/verify-otp' ||
              location == '/onboarding')) {
        return '/';
      }

      // 5. Sooq gate: inactive Sooqs redirect to coming-soon
      const sooqPaths = {
        '/matajir': 'matajir',
        '/balla': 'balla',
        '/mustamal': 'mustamal',
        '/mazadat': 'mazadat',
      };
      for (final entry in sooqPaths.entries) {
        if (location.startsWith(entry.key)) {
          if (!sooqConfigCubit.isSooqActive(entry.value)) {
            return '/coming-soon/${entry.value}';
          }
          break;
        }
      }

      return null;
    },
    routes: [
      // ── Public auth routes ──────────────────────────────────────────────
      GoRoute(
        path: '/coming-soon/:sooqId',
        builder: (context, state) => ComingSoonPage(sooqId: state.pathParameters['sooqId'] ?? ''),
      ),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletPage()),
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/verify-otp', builder: (_, _) => const VerifyOtpPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegistrationPage()),

      // ── Protected routes ────────────────────────────────────────────────
      GoRoute(path: '/favorites', builder: (_, _) => const FavoritesPage()),
      GoRoute(path: '/shipping-address', builder: (_, _) => const ShippingAddressPage()),

      // ── Stories ────────────────────────────────────────────────────────
      GoRoute(
        path: '/stories/create',
        builder: (_, _) => const CreateStoryPage(),
      ),
      GoRoute(
        path: '/stories/view/:shopId',
        builder: (context, state) => StoryViewerPage(
          shopId: state.pathParameters['shopId'] ?? '',
        ),
      ),

      // ── Flash Drops ─────────────────────────────────────────────────────
      // NOTE: Flash Drops now rendered via WebView - native pages removed
      // GoRoute(
      //   path: '/flash-drops',
      //   builder: (_, _) => const FlashDropsPage(),
      // ),
      // GoRoute(
      //   path: '/flash-drops/create',
      //   builder: (_, _) => const CreateFlashDropPage(),
      // ),

      // ── Group Buys ──────────────────────────────────────────────────────
      GoRoute(
        path: '/group-buys',
        builder: (_, _) => const GroupBuyListPage(),
      ),
      GoRoute(
        path: '/group-buys/create',
        builder: (_, _) => const CreateGroupBuyPage(),
      ),
      GoRoute(
        path: '/group/:id',
        builder: (context, state) => GroupBuyPage(
          groupBuyId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ── My Negotiations ────────────────────────────────────────────────
      GoRoute(
        path: '/negotiations',
        builder: (_, _) => const MyNegotiationsPage(),
      ),

      // ── Conversations (in-app chat) ─────────────────────────────────────
      // NOTE: Chat now rendered via WebView - native pages removed
      // GoRoute(
      //   path: '/conversations',
      //   builder: (_, _) => const ConversationsPage(),
      // ),
      // GoRoute(
      //   path: '/conversations/:id',
      //   builder: (context, state) => ChatRoomPage(
      //     conversationId: state.pathParameters['id'] ?? '',
      //     recipientName: state.uri.queryParameters['name'] ?? '',
      //   ),
      // ),

      // ── Mahallati (hyperlocal map) ───────────────────────────────
      GoRoute(
        path: '/mahallati',
        builder: (context, state) {
          final contextFilter = state.uri.queryParameters['context'];
          return MahallatiPage(contextFilter: contextFilter);
        },
      ),

      // ── Seller Dashboard ───────────────────────────────────────────────
      GoRoute(
        path: '/seller-dashboard',
        builder: (_, _) => const SellerDashboardPage(),
      ),
      // NOTE: These routes now rendered via WebView
      // GoRoute(
      //   path: '/orders/:id/dispute',
      //   builder: (context, state) =>
      //       DisputePage(orderId: state.pathParameters['id'] ?? ''),
      // ),
      // GoRoute(
      //   path: '/mustamal/:id',
      //   builder: (context, state) =>
      //       MustamalDetailPage(item: state.extra! as ItemModel),
      // ),
      // GoRoute(
      //   path: '/search',
      //   builder: (context, state) => BlocProvider<SearchCubit>(
      //     create: (context) => getIt<SearchCubit>(),
      //     child: const SearchPage(),
      //   ),
      // ),

      // Matajir Mini-App (WebView)
      GoRoute(
        path: '/matajir',
        builder: (_, _) => const SooqWebView(sooq: 'matajir'),
      ),

      // Balla Mini-App (WebView)
      GoRoute(
        path: '/balla',
        builder: (_, _) => const SooqWebView(sooq: 'balla'),
      ),

      // Mustamal Mini-App (WebView)
      GoRoute(
        path: '/mustamal',
        builder: (_, _) => const SooqWebView(sooq: 'mustamal'),
      ),

      // Mazadat Mini-App (WebView)
      GoRoute(
        path: '/mazadat',
        builder: (_, _) => const SooqWebView(sooq: 'mazadat'),
      ),

      // ── Main tabbed shell ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Branch 0: Home ─────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'feed',
                    builder: (_, state) => const FeedPage(),
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 1: Messages ─────────────────────────────────────────
          // NOTE: Messages now rendered via WebView
          StatefulShellBranch(
            navigatorKey: _messagesNavKey,
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const SooqWebView(sooq: 'chat'),
              ),
            ],
          ),

          // ── Branch 2: Activity ─────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _activityNavKey,
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ActivityPage(),
              ),
            ],
          ),

          // ── Branch 3: Profile ──────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ── Listenable wrapper for AuthBloc ──────────────────────────────────────────

/// Bridges [AuthBloc] stream to [ChangeNotifier] so go_router can react
/// to auth state changes for automatic redirect evaluation.
class _AuthBlocListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _AuthBlocListenable(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
