import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/log_service.dart';
import '../../data/models/auth_models.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Manages the full authentication lifecycle.
///
/// Mandatory auth: users must be authenticated to use the app.
/// The [AuthStatus.unauthenticated] state triggers a router redirect to /login.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;
  static const _onboardedKey = 'has_onboarded';

  AuthBloc(this._authRepository, {@factoryParam FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthRegistrationNameSubmitted>(_onRegistrationNameSubmitted);
    on<AuthOtpCancelled>(_onOtpCancelled);
    on<AuthLogoutRequested>(_onLogout);
  }

  // iOS Keychain: always specify accessibility to avoid deadlocks when
  // the Keychain is locked (cold boot / background fetch).
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// Helper to check onboarding status safely.
  Future<bool> hasOnboarded() async {
    try {
      final value = await _storage.read(
        key: _onboardedKey,
        iOptions: _iosOptions,
      );
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboarded() async {
    await _storage.write(
      key: _onboardedKey,
      value: 'true',
      iOptions: _iosOptions,
    );
  }

  // ── Event Handlers ──────────────────────────────────────

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    LogService().info('🔑 Checking for existing session...');

    try {
      // Run sequentially to avoid concurrent iOS Keychain access which
      // can cause both reads to deadlock each other.
      final isLoggedIn = await _authRepository.isLoggedIn().timeout(
        const Duration(seconds: 5),
      );
      LogService().info('🔑 isLoggedIn check: $isLoggedIn');

      final onboarded = await hasOnboarded().timeout(
        const Duration(seconds: 3),
      );
      LogService().info('🔑 hasOnboarded check: $onboarded');

      if (isLoggedIn) {
        LogService().info(
          '🔑 Session found — authenticating & fetching user...',
        );
        final user = await _authRepository.getUser();
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            hasOnboarded: onboarded,
            user: user,
            displayName: user?.fullName ?? state.displayName,
            phoneNumber: user?.phoneNumber ?? state.phoneNumber,
          ),
        );
      } else {
        LogService().info(
          '🔑 No session — unauthenticated (onboarded: $onboarded)',
        );
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            hasOnboarded: onboarded,
          ),
        );
      }
    } catch (e, stack) {
      LogService().error('Fatal: Auth check failed', e, stack);
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, hasOnboarded: false),
      );
    }
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _authRepository.sendOtp(
        SendOtpRequest(phoneNumber: event.phoneNumber),
      );
      LogService().info('📱 OTP Sent to ${event.phoneNumber}');
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          phoneNumber: event.phoneNumber,
          isLoading: false,
        ),
      );
    } catch (e, stack) {
      LogService().error('OTP request failed', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to send code. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.phoneNumber == null) {
        throw Exception('Phone number missing');
      }

      LogService().info('Attempting login with OTP...');
      await _authRepository.login(
        LoginRequest(phoneNumber: state.phoneNumber!, otp: event.otp),
      );

      LogService().info('✅ Login successful, fetching user...');
      final user = await _authRepository.getUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          user: user,
          displayName: user?.fullName ?? state.displayName,
          phoneNumber: user?.phoneNumber ?? state.phoneNumber,
        ),
      );
    } on DioException catch (e) {
      LogService().error('API Login failed', e, StackTrace.current);

      String errorMessage = 'Login failed';
      int? statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiErr = e.error as ApiException;
        errorMessage = apiErr.message;
        statusCode = apiErr.statusCode ?? statusCode;
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }

      // If the user doesn't exist, redirect to registration
      if (errorMessage.toLowerCase().contains('not found') ||
          statusCode == 404 ||
          statusCode == 401) {
        LogService().info('Account not found. Prompting for Name + Role...');
        emit(
          state.copyWith(
            status: AuthStatus.registrationRequired,
            isLoading: false,
            otpCode: event.otp,
          ),
        );
        return;
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    } catch (e, stack) {
      LogService().error('OTP submission failed', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRegistrationNameSubmitted(
    AuthRegistrationNameSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.phoneNumber == null || state.otpCode == null) {
        throw Exception('Missing phone number or OTP code');
      }

      LogService().info('Attempting registration with role: ${event.role}...');
      await _authRepository.register(
        RegisterRequest(
          fullName: event.fullName,
          phoneNumber: state.phoneNumber!,
          otp: state.otpCode!,
        ),
      );

      // Update role via profile update after registration if backend doesn't
      // support role in /auth/otp/register yet.
      LogService().info('✅ Registration successful, fetching user...');
      final user = await _authRepository.getUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          user: user,
          displayName: user?.fullName ?? state.displayName,
          phoneNumber: user?.phoneNumber ?? state.phoneNumber,
        ),
      );
    } on DioException catch (e) {
      LogService().error('Registration failed (Dio)', e, StackTrace.current);
      String errorMessage = 'Registration failed';
      if (e.error is ApiException) {
        errorMessage = (e.error as ApiException).message;
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }
      emit(state.copyWith(isLoading: false, error: errorMessage));
    } catch (e, stack) {
      LogService().error('Registration failed unexpectedly', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpCancelled(
    AuthOtpCancelled event,
    Emitter<AuthState> emit,
  ) async {
    // Reset to unauthenticated so the login page shows phone input again
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearPhoneNumber: true,
        error: null,
        isLoading: false,
      ),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    LogService().info('👋 User logged out → unauthenticated');
    emit(const AuthState(status: AuthStatus.unauthenticated, user: null));
  }
}
