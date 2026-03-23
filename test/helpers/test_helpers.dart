/// Shared test helpers, mock definitions, and fixture builders.
///
/// Import this file from every test to get a consistent set of mocks
/// and convenience utilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auth/data/models/auth_models.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_event.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';
import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/l10n/generated/app_localizations.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthBloc extends Mock implements AuthBloc {}

// ── Fallback registrations (call once before any test using any()) ─────────────

void registerFallbackValues() {
  registerFallbackValue(const AuthOtpRequested(phoneNumber: ''));
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

/// A valid Iraqi phone number (10 digits after +964 prefix).
const kTestPhone = '+9647501234567';

/// A stripped phone number as the user enters it (without +964).
const kTestPhoneInput = '7501234567';

/// A valid 6-digit OTP.
const kTestOtp = '123456';

/// A sample authenticated user.
final kTestUser = const UserModel(
  id: 'user-001',
  fullName: 'أحمد محمد',
  phoneNumber: kTestPhone,
  role: 'user',
  isVerified: true,
  walletBalance: '150000',
);

/// An [AuthState] that represents a freshly-authenticated user.
final kAuthenticatedState = AuthState(
  status: AuthStatus.authenticated,
  user: kTestUser,
  hasOnboarded: true,
  phoneNumber: kTestPhone,
  displayName: kTestUser.fullName,
);

/// An [AuthState] that represents an unauthenticated user who has onboarded.
const kUnauthenticatedState = AuthState(
  status: AuthStatus.unauthenticated,
  hasOnboarded: true,
);

/// An [AuthState] with OTP sent (waiting for code).
const kOtpSentState = AuthState(
  status: AuthStatus.otpSent,
  phoneNumber: kTestPhone,
  hasOnboarded: true,
);

// ── Widget Wrapper ─────────────────────────────────────────────────────────────

/// Wraps [child] in all the providers + localizations required by Luqta pages.
Widget buildTestApp({
  required Widget child,
  AuthBloc? authBloc,
  GoRouter? router,
  List<BlocProvider> extraProviders = const [],
}) {
  final bloc = authBloc ?? MockAuthBloc();

  // Provide sensible defaults so BlocBuilder / BlocListener won't crash.
  if (authBloc == null) {
    when(() => bloc.state).thenReturn(kUnauthenticatedState);
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  }

  final Widget app = MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: bloc),
      ...extraProviders,
    ],
    child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        locale: const Locale('ar', 'IQ'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );

  return app;
}

/// Wraps [child] using a real [GoRouter] (for navigation integration tests).
Widget buildRouterTestApp({
  required GoRouter router,
  AuthBloc? authBloc,
  List<BlocProvider> extraProviders = const [],
}) {
  final bloc = authBloc ?? MockAuthBloc();

  if (authBloc == null) {
    when(() => bloc.state).thenReturn(kUnauthenticatedState);
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  }

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: bloc),
      ...extraProviders,
    ],
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
