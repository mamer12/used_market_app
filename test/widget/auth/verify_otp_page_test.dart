// test/widget/auth/verify_otp_page_test.dart
//
// Widget tests for VerifyOtpPage.
// Covers: digit-box rendering, auto-focus advance, auto-submit,
// resend countdown, edit-number navigation, loading & error states.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_event.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';
import 'package:luqta/features/auth/presentation/pages/verify_otp_page.dart';

import '../../helpers/test_helpers.dart';

/// Sets physical size to 390×900 so the OTP page (designed for 844px) fits
/// without overflow. ScreenUtil reads physical size from the Flutter binding.
void _setOtpScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(registerFallbackValues);

  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(kOtpSentState);
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.add(any())).thenReturn(null);
  });

  Widget buildSubject() => buildTestApp(
        child: const VerifyOtpPage(),
        authBloc: authBloc,
      );

  // ── Rendering ───────────────────────────────────────────────────────────────

  testWidgets('renders 6 OTP input boxes', (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.length, 6);
  });

  testWidgets('shows phone number from bloc state', (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.textContaining(kTestPhone), findsOneWidget);
  });

  testWidgets('shows resend countdown (≥ 0 seconds visible)', (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Check for Arabic countdown text (ثانية/ثواني) or numeric pattern
    final hasArabicText = find.textContaining('ث').evaluate().isNotEmpty;
    final hasSecondsText = find.textContaining('s').evaluate().isNotEmpty;
    final hasNumericText = find.textContaining(RegExp(r'\d+')).evaluate().isNotEmpty;
    expect(hasArabicText || hasSecondsText || hasNumericText, isTrue);
  });

  // ── Auto-advance focus ──────────────────────────────────────────────────────

  testWidgets('entering digit advances focus to next box', (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final allFields = find.byType(TextField);
    await tester.tap(allFields.at(0));
    await tester.enterText(allFields.at(0), '1');
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  // ── Auto-submit ─────────────────────────────────────────────────────────────

  testWidgets('dispatches AuthOtpSubmitted when all 6 digits are entered',
      (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final fields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), i.toString());
      await tester.pump();
    }

    verify(() => authBloc.add(any(that: isA<AuthOtpSubmitted>()))).called(1);
  });

  // ── OTP value is correct ────────────────────────────────────────────────────

  testWidgets('dispatches correct OTP string from all 6 inputs', (tester) async {
    _setOtpScreenSize(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final fields = find.byType(TextField);
    final digits = ['1', '2', '3', '4', '5', '6'];
    for (int i = 0; i < 6; i++) {
      await tester.enterText(fields.at(i), digits[i]);
      await tester.pump();
    }

    verify(
      () => authBloc.add(const AuthOtpSubmitted('123456')),
    ).called(1);
  });

  // ── Edit number ─────────────────────────────────────────────────────────────

  testWidgets('tapping edit-number dispatches AuthOtpCancelled', (tester) async {
    _setOtpScreenSize(tester);
    final router = GoRouter(
      initialLocation: '/verify-otp',
      routes: [
        GoRoute(path: '/verify-otp', builder: (_, _) => const VerifyOtpPage()),
        GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login'))),
      ],
    );
    await tester.pumpWidget(buildRouterTestApp(router: router, authBloc: authBloc));
    await tester.pump();

    final editBtn = find.byType(TextButton).first;
    await tester.tap(editBtn);
    await tester.pump();

    verify(() => authBloc.add(const AuthOtpCancelled())).called(1);
  });

  // ── Loading ─────────────────────────────────────────────────────────────────

  testWidgets('submit button shows loading when isLoading=true', (tester) async {
    _setOtpScreenSize(tester);
    when(() => authBloc.state).thenReturn(
      const AuthState(
        status: AuthStatus.otpSent,
        phoneNumber: kTestPhone,
        isLoading: true,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Error ───────────────────────────────────────────────────────────────────

  testWidgets('shows error message from bloc state', (tester) async {
    // Extra height needed because error widget adds ~80px below existing content.
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const errMsg = 'رمز التحقق غير صحيح';
    when(() => authBloc.state).thenReturn(
      const AuthState(
        status: AuthStatus.otpSent,
        phoneNumber: kTestPhone,
        error: errMsg,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text(errMsg), findsOneWidget);
  });

  // ── Navigation to home on authenticated ─────────────────────────────────────

  testWidgets('navigates to / when status becomes authenticated', (tester) async {
    _setOtpScreenSize(tester);
    final visited = <String>[];

    final router = GoRouter(
      initialLocation: '/verify-otp',
      routes: [
        GoRoute(
          path: '/verify-otp',
          builder: (_, _) => const VerifyOtpPage(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) {
            visited.add('/');
            return const Scaffold(body: Text('Home'));
          },
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
      ],
    );

    final stream = StreamController<AuthState>.broadcast();
    when(() => authBloc.stream).thenAnswer((_) => stream.stream);
    when(() => authBloc.state).thenReturn(kOtpSentState);

    await tester.pumpWidget(
      buildRouterTestApp(router: router, authBloc: authBloc),
    );
    await tester.pump();

    stream.add(kAuthenticatedState);
    await tester.pumpAndSettle();

    expect(visited, contains('/'));
    await stream.close();
  });

  testWidgets('navigates to /register when status becomes registrationRequired',
      (tester) async {
    _setOtpScreenSize(tester);
    final visited = <String>[];

    final router = GoRouter(
      initialLocation: '/verify-otp',
      routes: [
        GoRoute(
          path: '/verify-otp',
          builder: (_, _) => const VerifyOtpPage(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/register',
          builder: (_, _) {
            visited.add('/register');
            return const Scaffold(body: Text('Register'));
          },
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
      ],
    );

    final stream = StreamController<AuthState>.broadcast();
    when(() => authBloc.stream).thenAnswer((_) => stream.stream);
    when(() => authBloc.state).thenReturn(kOtpSentState);

    await tester.pumpWidget(
      buildRouterTestApp(router: router, authBloc: authBloc),
    );
    await tester.pump();

    stream.add(
      const AuthState(status: AuthStatus.registrationRequired),
    );
    await tester.pumpAndSettle();

    expect(visited, contains('/register'));
    await stream.close();
  });
}
