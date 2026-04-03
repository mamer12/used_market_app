// test/unit/auth/auth_bloc_test.dart
//
// Unit tests for AuthBloc — covers the full OTP-based login flow:
//   1. Session check on app start
//   2. OTP request (phone submit)
//   3. OTP submission (login)
//   4. Registration required path (404 from backend)
//   5. Logout
//   6. OTP cancelled (edit number)
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luqta/features/auth/data/models/auth_models.dart';
import 'package:luqta/features/auth/domain/entities/auth_status.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_event.dart';
import 'package:luqta/features/auth/presentation/bloc/auth_state.dart';

import '../../helpers/test_helpers.dart';

// ── Additional mocks ──────────────────────────────────────────────────────────
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// Register fallback values so Mocktail doesn't complain about any() matchers
class FakeSendOtpRequest extends Fake implements SendOtpRequest {}
class FakeLoginRequest extends Fake implements LoginRequest {}
class FakeRegisterRequest extends Fake implements RegisterRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSendOtpRequest());
    registerFallbackValue(FakeLoginRequest());
    registerFallbackValue(FakeRegisterRequest());
  });

  late MockAuthRepository repo;
  late MockFlutterSecureStorage storage;

  setUp(() {
    repo = MockAuthRepository();
    storage = MockFlutterSecureStorage();

    // Default: no stored key → not onboarded, not logged-in
    when(
      () => storage.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')),
    ).thenAnswer((_) async => null);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
        iOptions: any(named: 'iOptions'),
      ),
    ).thenAnswer((_) async {});
  });

  AuthBloc buildBloc() => AuthBloc(repo, storage: storage);

  // ── 1. Session check ────────────────────────────────────────────────────────

  group('AuthCheckRequested', () {
    test('emits authenticated when token is valid', () async {
      when(() => repo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => repo.getUser()).thenAnswer((_) async => kTestUser);
      // Simulate user has completed onboarding
      when(
        () => storage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
        ),
      ).thenAnswer((_) async => 'true');

      final bloc = buildBloc();
      bloc.add(const AuthCheckRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) =>
                s.status == AuthStatus.authenticated &&
                s.user?.id == kTestUser.id &&
                s.hasOnboarded == true,
            'authenticated with user and hasOnboarded=true',
          ),
        ),
      );
      await bloc.close();
    });

    test('emits unauthenticated when no token stored', () async {
      when(() => repo.isLoggedIn()).thenAnswer((_) async => false);

      final bloc = buildBloc();
      bloc.add(const AuthCheckRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.unauthenticated,
            'unauthenticated',
          ),
        ),
      );
      await bloc.close();
    });

    test('emits unauthenticated on repository exception', () async {
      when(() => repo.isLoggedIn()).thenThrow(Exception('storage error'));

      final bloc = buildBloc();
      bloc.add(const AuthCheckRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.unauthenticated,
            'falls back to unauthenticated on error',
          ),
        ),
      );
      await bloc.close();
    });
  });

  // ── 2. OTP Request ──────────────────────────────────────────────────────────

  group('AuthOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, otpSent] on success',
      build: buildBloc,
      setUp: () {
        when(() => repo.sendOtp(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthOtpRequested(kTestPhone)),
      expect: () => [
        const AuthState(isLoading: true, error: null),
        const AuthState(
          status: AuthStatus.otpSent,
          phoneNumber: kTestPhone,
          isLoading: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when sendOtp throws',
      build: buildBloc,
      setUp: () {
        when(() => repo.sendOtp(any())).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const AuthOtpRequested(kTestPhone)),
      expect: () => [
        const AuthState(isLoading: true, error: null),
        predicate<AuthState>(
          (s) => !s.isLoading && s.error != null,
          'has error, not loading',
        ),
      ],
    );
  });

  // ── 3. OTP Submission (Login) ───────────────────────────────────────────────

  group('AuthOtpSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when OTP is correct',
      build: buildBloc,
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        phoneNumber: kTestPhone,
      ),
      setUp: () {
        when(() => repo.login(any())).thenAnswer((_) async {});
        when(() => repo.getUser()).thenAnswer((_) async => kTestUser);
      },
      act: (bloc) => bloc.add(const AuthOtpSubmitted(kTestOtp)),
      expect: () => [
        const AuthState(
          status: AuthStatus.otpSent,
          phoneNumber: kTestPhone,
          isLoading: true,
          error: null,
        ),
        predicate<AuthState>(
          (s) =>
              s.status == AuthStatus.authenticated &&
              s.user?.fullName == kTestUser.fullName &&
              !s.isLoading,
          'authenticated with fetched user',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits registrationRequired on 404 response',
      build: buildBloc,
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        phoneNumber: kTestPhone,
      ),
      setUp: () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
          message: 'User not found',
        );
        when(() => repo.login(any())).thenThrow(dioEx);
      },
      act: (bloc) => bloc.add(const AuthOtpSubmitted(kTestOtp)),
      expect: () => [
        predicate<AuthState>((s) => s.isLoading, 'loading'),
        predicate<AuthState>(
          (s) => s.status == AuthStatus.registrationRequired && !s.isLoading,
          'registrationRequired',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error when phone number is missing from state',
      build: buildBloc,
      // No phoneNumber in seed state
      seed: () => const AuthState(status: AuthStatus.otpSent),
      act: (bloc) => bloc.add(const AuthOtpSubmitted(kTestOtp)),
      expect: () => [
        predicate<AuthState>((s) => s.isLoading, 'loading'),
        predicate<AuthState>(
          (s) => s.error != null && !s.isLoading,
          'error: phone number missing',
        ),
      ],
    );
  });

  // ── 4. OTP Cancelled ────────────────────────────────────────────────────────

  blocTest<AuthBloc, AuthState>(
    'AuthOtpCancelled clears phone and resets to unauthenticated',
    build: buildBloc,
    seed: () => const AuthState(
      status: AuthStatus.otpSent,
      phoneNumber: kTestPhone,
    ),
    act: (bloc) => bloc.add(const AuthOtpCancelled()),
    expect: () => [
      predicate<AuthState>(
        (s) =>
            s.status == AuthStatus.unauthenticated && s.phoneNumber == null,
        'unauthenticated, phone cleared',
      ),
    ],
  );

  // ── 5. Logout ───────────────────────────────────────────────────────────────

  blocTest<AuthBloc, AuthState>(
    'AuthLogoutRequested emits unauthenticated and clears user',
    build: buildBloc,
    seed: () => kAuthenticatedState,
    setUp: () {
      when(() => repo.logout()).thenAnswer((_) async {});
    },
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [
      predicate<AuthState>(
        (s) => s.status == AuthStatus.unauthenticated && s.user == null,
        'unauthenticated, no user',
      ),
    ],
  );

  // ── 6. Registration ─────────────────────────────────────────────────────────

  group('AuthRegistrationNameSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated after successful registration',
      build: buildBloc,
      seed: () => const AuthState(
        status: AuthStatus.registrationRequired,
        phoneNumber: kTestPhone,
        otpCode: kTestOtp,
      ),
      setUp: () {
        when(() => repo.register(any())).thenAnswer((_) async {});
        when(() => repo.getUser()).thenAnswer((_) async => kTestUser);
      },
      act: (bloc) => bloc.add(
        const AuthRegistrationNameSubmitted(
          fullName: 'أحمد محمد',
          role: 'user',
        ),
      ),
      expect: () => [
        predicate<AuthState>((s) => s.isLoading, 'loading'),
        predicate<AuthState>(
          (s) =>
              s.status == AuthStatus.authenticated &&
              s.user?.fullName == 'أحمد محمد',
          'authenticated after registration',
        ),
      ],
    );
  });
}
