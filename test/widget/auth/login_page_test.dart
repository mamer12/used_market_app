// test/widget/auth/login_page_test.dart
//
// Widget tests for LoginPage.
// Verifies UI interactions without hitting the real network.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_event.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';
import 'package:luqta/features/auth/presentation/pages/login_page.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(kUnauthenticatedState);
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject() => buildTestApp(
        child: const LoginPage(),
        authBloc: authBloc,
      );

  // ── Rendering ───────────────────────────────────────────────────────────────

  testWidgets('renders phone input and continue button', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(TextFormField), findsOneWidget);
    // Continue button exists (ElevatedButton from PrimaryButton)
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows +964 prefix in the input decoration', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('+964'), findsOneWidget);
  });

  // ── Validation ──────────────────────────────────────────────────────────────

  testWidgets('does not dispatch event when phone field is empty on submit',
      (tester) async {
    when(() => authBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('does not dispatch event when phone is shorter than 10 chars',
      (tester) async {
    when(() => authBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), '750');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verifyNever(() => authBloc.add(any()));
  });

  // ── Happy Path ──────────────────────────────────────────────────────────────

  testWidgets('dispatches AuthOtpRequested with +964 prefix on valid input',
      (tester) async {
    when(() => authBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), kTestPhoneInput);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthOtpRequested('+964$kTestPhoneInput'),
      ),
    ).called(1);
  });

  // ── Loading State ───────────────────────────────────────────────────────────

  testWidgets('button shows loading indicator when isLoading=true',
      (tester) async {
    when(() => authBloc.state).thenReturn(
      const AuthState(
        isLoading: true,
        status: AuthStatus.unauthenticated,
      ),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Error State ─────────────────────────────────────────────────────────────

  testWidgets('displays API error message from bloc state', (tester) async {
    const errorMsg = 'Failed to send code. Please try again.';
    when(() => authBloc.state).thenReturn(
      const AuthState(
        status: AuthStatus.unauthenticated,
        error: errorMsg,
      ),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text(errorMsg), findsOneWidget);
  });

  // ── Navigation on otpSent ───────────────────────────────────────────────────

  testWidgets('navigates to /verify-otp when status becomes otpSent',
      (tester) async {
    final visited = <String>[];

    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (_, _) {
            visited.add('/verify-otp');
            return const Scaffold(body: Text('OTP Page'));
          },
        ),
      ],
    );

    final stateStream = StreamController<AuthState>.broadcast();
    when(() => authBloc.stream).thenAnswer((_) => stateStream.stream);
    when(() => authBloc.state).thenReturn(kUnauthenticatedState);

    await tester.pumpWidget(
      buildRouterTestApp(router: router, authBloc: authBloc),
    );
    await tester.pump();

    stateStream.add(kOtpSentState);
    await tester.pumpAndSettle();

    expect(visited, contains('/verify-otp'));

    await stateStream.close();
  });
}
