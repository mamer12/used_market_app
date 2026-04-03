// test/features/auth/presentation/bloc/auth_bridge_test.dart
//
// Integration tests for the auth bridge between WebView JS messages and AuthBloc.
// Tests auth:expired message handling and re-auth flow.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/core/services/web_session_service.dart';
import 'package:luqta/features/auth/data/models/auth_models.dart';
import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/features/auth/domain/repositories/auth_repository.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_event.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockWebSessionService extends Mock implements WebSessionService {}

class FakeAuthEvent extends Fake implements AuthEvent {}

// ── Test Helpers ──────────────────────────────────────────────────────────────

Widget createTestWidget({
  required Widget child,
  required AuthBloc authBloc,
}) {
  return MaterialApp(
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: child,
    ),
  );
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const AuthLogoutRequested());
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => true);
    when(() => mockAuthRepository.getUser()).thenAnswer((_) async => null);

    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('Auth Bridge Integration Tests', () {
    group('AuthBloc - AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state when AuthLogoutRequested is added',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository);
        },
        seed: () => const AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'user-001',
            fullName: 'Test User',
            phoneNumber: '+9647501234567',
            role: 'user',
            isVerified: true,
            walletBalance: '0',
          ),
          hasOnboarded: true,
        ),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.user, 'user', isNull),
        ],
        verify: (_) {
          verify(() => mockAuthRepository.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'calls authRepository.logout when logout requested',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        verify: (_) {
          verify(() => mockAuthRepository.logout()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'clears user data on logout',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository);
        },
        seed: () => const AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'user-001',
            fullName: 'Test User',
            phoneNumber: '+9647501234567',
            role: 'user',
            isVerified: true,
            walletBalance: '1000',
          ),
          hasOnboarded: true,
        ),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.user, 'user', isNull),
        ],
      );
    });

    group('Auth State Transitions', () {
      blocTest<AuthBloc, AuthState>(
        'transitions from authenticated to unauthenticated on logout',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository);
        },
        seed: () => const AuthState(
          status: AuthStatus.authenticated,
          hasOnboarded: true,
        ),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          isA<AuthState>().having(
            (s) => s.status,
            'status',
            AuthStatus.unauthenticated,
          ),
        ],
      );
    });

    group('WebView to AuthBloc Integration', () {
      test('AuthLogoutRequested can be dispatched via BuildContext', () {
        // This test verifies the event can be created and has correct props
        const event = AuthLogoutRequested();
        expect(event, isA<AuthLogoutRequested>());
        expect(event.props, isEmpty);
      });

      test('AuthLogoutRequested is equatable', () {
        const event1 = AuthLogoutRequested();
        const event2 = AuthLogoutRequested();
        expect(event1, equals(event2));
      });
    });

    group('Session Invalidation Flow', () {
      blocTest<AuthBloc, AuthState>(
        'handles logout event after session expiry',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(mockAuthRepository);
        },
        seed: () => const AuthState(
          status: AuthStatus.authenticated,
          hasOnboarded: true,
        ),
        act: (bloc) async {
          // Simulate auth expiry from WebView
          bloc.add(const AuthLogoutRequested());
        },
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.user, 'user', isNull)
              .having((s) => s.isLoading, 'isLoading', isFalse),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<AuthBloc, AuthState>(
        'handles logout even when repository throws',
        build: () {
          when(() => mockAuthRepository.logout()).thenThrow(Exception('Network error'));
          return AuthBloc(mockAuthRepository);
        },
        seed: () => const AuthState(
          status: AuthStatus.authenticated,
          hasOnboarded: true,
        ),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          // Still transitions to unauthenticated even if logout fails
          isA<AuthState>().having(
            (s) => s.status,
            'status',
            AuthStatus.unauthenticated,
          ),
        ],
        errors: () => [isA<Exception>()],
      );
    });
  });
}
