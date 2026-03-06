import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/cart/presentation/cubit/balla_cart_cubit.dart';
import '../../features/cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/pages/activity_page.dart';
import '../../features/shop/presentation/pages/balla_page.dart';
import '../../features/shop/presentation/pages/matajir_page.dart';
import '../../features/shop/presentation/pages/mustamal_page.dart';
import '../../features/shop/presentation/pages/shop_products_page.dart';
import '../di/injection.dart';
import '../widgets/main_shell.dart';

/// Global navigator key to access top-level context anywhere if needed.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Nested shell navigator keys
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _messagesNavKey = GlobalKey<NavigatorState>(debugLabel: 'messagesNav');
final _activityNavKey = GlobalKey<NavigatorState>(debugLabel: 'activityNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// The main router for the application, enforcing go_router usage per the constitution.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  // Used to manage authentication redirects
  // redirect: (context, state) { ... } could be added here
  routes: [
    // Top-level independent routes
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const Placeholder(
        child: Text('Onboarding'),
      ), // TODO: import real OnboardingPage
    ),
    GoRoute(
      path: '/mazadat',
      builder: (_, _) => const Placeholder(
        child: Text('Auctions'),
      ), // TODO: import real AuctionsPage
    ),
    GoRoute(
      path: '/search',
      builder: (_, _) => const Placeholder(child: Text('Search')),
    ),

    // Matajir Mini-App (Isolated Cart)
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider<MatajirCartCubit>(
          create: (context) => getIt<MatajirCartCubit>(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/matajir',
          builder: (context, state) => const MatajirPage(),
          routes: [
            GoRoute(
              path: 'cart',
              builder: (context, state) =>
                  CartPage(cartCubit: context.read<MatajirCartCubit>()),
            ),
            GoRoute(
              path: 'shop/:slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug'] ?? '';
                final shopName = state.uri.queryParameters['name'] ?? 'Shop';
                return ShopProductsPage(shopSlug: slug, shopName: shopName);
              },
            ),
          ],
        ),
      ],
    ),

    // Balla Mini-App (Isolated Cart)
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider<BallaCartCubit>(
          create: (context) => getIt<BallaCartCubit>(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/balla',
          builder: (context, state) => const BallaPage(),
          routes: [
            GoRoute(
              path: 'cart',
              builder: (context, state) =>
                  CartPage(cartCubit: context.read<BallaCartCubit>()),
            ),
          ],
        ),
      ],
    ),

    // Mustamal Mini-App
    GoRoute(path: '/mustamal', builder: (_, _) => const MustamalPage()),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Here we return our custom MainShell which expects the navigationShell
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // ── Branch 0: Home ─────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomePage()),
          ],
        ),

        // ── Branch 1: Messages ─────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _messagesNavKey,
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesPage(),
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
