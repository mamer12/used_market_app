import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auction/presentation/pages/mazadat_page.dart';
import '../../features/auth/domain/entities/auth_status.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/cart/presentation/cubit/balla_cart_cubit.dart';
import '../../features/cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/pages/activity_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/shop/data/models/shop_models.dart';
import '../../features/shop/presentation/pages/balla_page.dart';
import '../../features/shop/presentation/pages/balla_product_details_page.dart';
import '../../features/shop/presentation/pages/matajir_page.dart';
import '../../features/shop/presentation/pages/mustamal_page.dart';
import '../../features/shop/presentation/pages/product_details_page.dart';
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
GoRouter buildAppRouter(AuthBloc authBloc) {
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

      return null;
    },
    routes: [
      // ── Public auth routes ──────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/verify-otp', builder: (_, _) => const VerifyOtpPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegistrationPage()),

      // ── Protected routes ────────────────────────────────────────────────
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
                path: 'checkout',
                builder: (context, state) =>
                    const CheckoutPage(appContext: 'matajir'),
              ),
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final product = state.extra as ProductModel;
                  return ProductDetailsPage(product: product);
                },
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
              GoRoute(
                path: 'checkout',
                builder: (context, state) =>
                    const CheckoutPage(appContext: 'balla'),
              ),
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final product = state.extra as ProductModel;
                  return BallaProductDetailsPage(product: product);
                },
              ),
            ],
          ),
        ],
      ),

      // Mustamal Mini-App
      GoRoute(path: '/mustamal', builder: (_, _) => const MustamalPage()),

      // Mazadat Mini-App
      GoRoute(path: '/mazadat', builder: (_, _) => const MazadatPage()),

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
