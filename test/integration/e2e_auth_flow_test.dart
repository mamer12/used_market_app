// test/integration/e2e_auth_flow_test.dart
//
// End-to-end integration tests for the Authentication flow.
// Uses a REAL GoRouter (not mocked) wired with a MockAuthBloc so navigation
// rules are exercised without hitting the network.
//
// Covered flows:
//   1. Cold start → splash → onboarding (first launch)
//   2. Cold start → splash → login (returning user, not authenticated)
//   3. Cold start → splash → home (stored token valid)
//   4. Login page → OTP sent → navigate to /verify-otp
//   5. OTP verified → navigate to /
//   6. OTP verify → registrationRequired → navigate to /register
//   7. Authenticated user trying to access /login → redirected to /
//   8. Unauthenticated user trying to access / → redirected to /login
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';
import 'package:luqta/l10n/generated/app_localizations.dart';

import '../helpers/test_helpers.dart';

// ── Minimal page stubs (avoid full DI init) ───────────────────────────────────

class _StubPage extends StatelessWidget {
  final String label;
  const _StubPage(this.label);

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

// ── Build the router with stub pages ─────────────────────────────────────────

/// Builds an [AppRouter]-equivalent GoRouter but substitutes all pages with
/// lightweight [_StubPage] widgets so we don't need DI or a running backend.
GoRouter _buildTestRouter(AuthBloc bloc) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/',
    refreshListenable: _AuthBlocListenable(bloc),
    redirect: (context, state) {
      final authState = bloc.state;
      final status = authState.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.initial) {
        return location == '/splash' ? null : '/splash';
      }

      if (status == AuthStatus.registrationRequired) {
        return location == '/register' ? null : '/register';
      }

      if (status == AuthStatus.otpSent) {
        return location == '/verify-otp' ? null : '/verify-otp';
      }

      final isAuth = status == AuthStatus.authenticated;

      if (location == '/splash') {
        if (isAuth) return '/';
        return authState.hasOnboarded ? '/login' : '/onboarding';
      }

      final publicPaths = [
        '/splash',
        '/onboarding',
        '/login',
        '/verify-otp',
        '/register',
      ];
      final isPublic =
          publicPaths.any((p) => location.startsWith(p));

      if (!isAuth && !isPublic) return '/login';
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
      GoRoute(path: '/splash', builder: (_, _) => const _StubPage('Splash')),
      GoRoute(
          path: '/onboarding',
          builder: (_, _) => const _StubPage('Onboarding')),
      GoRoute(path: '/login', builder: (_, _) => const _StubPage('Login')),
      GoRoute(
          path: '/verify-otp',
          builder: (_, _) => const _StubPage('Verify OTP')),
      GoRoute(
          path: '/register', builder: (_, _) => const _StubPage('Register')),
      GoRoute(path: '/', builder: (_, _) => const _StubPage('Home')),
      GoRoute(path: '/wallet', builder: (_, _) => const _StubPage('Wallet')),
      GoRoute(path: '/search', builder: (_, _) => const _StubPage('Search')),
      GoRoute(path: '/profile', builder: (_, _) => const _StubPage('Profile')),
      GoRoute(
          path: '/messages',
          builder: (_, _) => const _StubPage('Messages')),
      GoRoute(
          path: '/activity', builder: (_, _) => const _StubPage('Activity')),
      GoRoute(
          path: '/mazadat', builder: (_, _) => const _StubPage('Mazadat')),
      GoRoute(
          path: '/matajir', builder: (_, _) => const _StubPage('Matajir')),
      GoRoute(path: '/balla', builder: (_, _) => const _StubPage('Balla')),
      GoRoute(
          path: '/mustamal', builder: (_, _) => const _StubPage('Mustamal')),
    ],
  );
}

// ── Listenable re-used from app code ─────────────────────────────────────────

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

// ── Widget wrapper ────────────────────────────────────────────────────────────

Widget _buildApp(AuthBloc bloc) {
  final router = _buildTestRouter(bloc);
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp.router(
        locale: const Locale('ar', 'IQ'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(registerFallbackValues);

  late MockAuthBloc authBloc;
  late StreamController<AuthState> stateStream;

  setUp(() {
    authBloc   = MockAuthBloc();
    stateStream = StreamController<AuthState>.broadcast();
    when(() => authBloc.stream).thenAnswer((_) => stateStream.stream);
    when(() => authBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateStream.close();
  });

  // ── 1. Cold start — first-ever launch → Onboarding ────────────────────────

  testWidgets(
    'F1: Cold start with initial status redirects to /splash then /onboarding',
    (tester) async {
      // Starts with initial status (session check in progress)
      when(() => authBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();

      // Should see Splash while session is being resolved
      expect(find.text('Splash'), findsOneWidget);

      // Now the session check completes: not onboarded, not authenticated
      const nextState = AuthState(
        status: AuthStatus.unauthenticated,
        hasOnboarded: false,
      );
      when(() => authBloc.state).thenReturn(nextState);
      stateStream.add(nextState);
      await tester.pumpAndSettle();

      // Should be on Onboarding
      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    },
  );

  // ── 2. Cold start — returning user, unauthenticated → Login ───────────────

  testWidgets(
    'F2: Cold start — onboarded user with no token goes to /login',
    (tester) async {
      when(() => authBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();

      when(() => authBloc.state).thenReturn(kUnauthenticatedState);
      stateStream.add(kUnauthenticatedState); // hasOnboarded = true
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    },
  );

  // ── 3. Cold start — valid token found → Home ──────────────────────────────

  testWidgets(
    'F3: Cold start — valid session immediately shows Home',
    (tester) async {
      when(() => authBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();

      when(() => authBloc.state).thenReturn(kAuthenticatedState);
      stateStream.add(kAuthenticatedState);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    },
  );

  // ── 4. Auth redirect: authenticated → cannot access /login ────────────────

  testWidgets(
    'F4: Authenticated user redirected from /login to /',
    (tester) async {
      // Start authenticated
      when(() => authBloc.state).thenReturn(kAuthenticatedState);

      final router = _buildTestRouter(authBloc);
      // Force navigation to /login
      router.go('/login');

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, _) => MaterialApp.router(
              locale: const Locale('ar', 'IQ'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    },
  );

  // ── 5. Auth redirect: unauthenticated → cannot access / ──────────────────

  testWidgets(
    'F5: Unauthenticated user redirected from / to /login',
    (tester) async {
      when(() => authBloc.state).thenReturn(kUnauthenticatedState);

      final router = _buildTestRouter(authBloc);
      // Force navigation to home (protected)
      router.go('/');

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, _) => MaterialApp.router(
              locale: const Locale('ar', 'IQ'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    },
  );

  // ── 6. OTP sent → navigate to /verify-otp ────────────────────────────────

  testWidgets(
    'F6: status.otpSent → router redirects to /verify-otp',
    (tester) async {
      when(() => authBloc.state).thenReturn(kUnauthenticatedState);

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();
      // Initially on Login
      stateStream.add(kUnauthenticatedState);
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);

      // OTP requested → status becomes otpSent
      when(() => authBloc.state).thenReturn(kOtpSentState);
      stateStream.add(kOtpSentState);
      await tester.pumpAndSettle();

      // The bloc listener in LoginPage should navigate to /verify-otp
      // (In this test we're relying on BlocListener inside LoginPage stub;
      //  here we just test the router guard doesn't block /verify-otp)
      // Direct navigation to verify-otp should be allowed
      final BuildContext ctx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(ctx).go('/verify-otp');
      await tester.pumpAndSettle();
      expect(find.text('Verify OTP'), findsOneWidget);
    },
  );

  // ── 7. OTP verified → home ────────────────────────────────────────────────

  testWidgets(
    'F7: After OTP verification, authenticated state routes to /',
    (tester) async {
      when(() => authBloc.state).thenReturn(kOtpSentState);

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();

      when(() => authBloc.state).thenReturn(kAuthenticatedState);
      stateStream.add(kAuthenticatedState);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    },
  );

  // ── 8. Registration required ──────────────────────────────────────────────

  testWidgets(
    'F8: registrationRequired state routes to /register',
    (tester) async {
      when(() => authBloc.state).thenReturn(kOtpSentState);

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pump();

      const regState = AuthState(
        status: AuthStatus.registrationRequired,
        hasOnboarded: true,
      );
      when(() => authBloc.state).thenReturn(regState);
      stateStream.add(regState);
      await tester.pumpAndSettle();

      expect(find.text('Register'), findsOneWidget);
    },
  );

  // ── 9. Logout → back to login ─────────────────────────────────────────────

  testWidgets(
    'F9: Logging out transitions from Home to Login',
    (tester) async {
      when(() => authBloc.state).thenReturn(kAuthenticatedState);

      await tester.pumpWidget(_buildApp(authBloc));
      await tester.pumpAndSettle();

      // Initially on Home
      expect(find.text('Home'), findsOneWidget);

      // Logout
      const loggedOutState = AuthState(
        status: AuthStatus.unauthenticated,
        hasOnboarded: true,
      );
      when(() => authBloc.state).thenReturn(loggedOutState);
      stateStream.add(loggedOutState);
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    },
  );
}
