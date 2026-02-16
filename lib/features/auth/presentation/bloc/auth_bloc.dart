import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/log_service.dart';
import '../../domain/entities/auth_status.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Manages the full authentication lifecycle for "Lazy Auth".
///
/// The user starts as a guest and can browse freely.
/// Login is triggered contextually via [AuthGuard] → Bottom Sheet.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';
  static const _onboardedKey = 'has_onboarded';

  AuthBloc({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGuestModeEntered>(_onGuestMode);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthOtpCancelled>(_onOtpCancelled);
    on<AuthLogoutRequested>(_onLogout);
  }

  /// Helper to check onboarding status safely.
  Future<bool> hasOnboarded() async {
    try {
      final value = await _storage.read(key: _onboardedKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboarded() async {
    await _storage.write(key: _onboardedKey, value: 'true');
  }

  // ── Event Handlers ──────────────────────────────────────

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    LogService().info('🔑 Checking for existing session...');

    try {
      // Safety timeout: don't hang the app if storage is unresponsive
      final results = await Future.wait([
        _storage.read(key: _tokenKey),
        hasOnboarded(),
      ]).timeout(const Duration(seconds: 2));

      final token = results[0] as String?;
      final onboarded = results[1] as bool;

      if (token != null && token.isNotEmpty) {
        LogService().info('🔑 Session found — authenticating');
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            hasOnboarded: onboarded,
          ),
        );
      } else {
        LogService().info('🔑 No session — guest mode (onboarded: $onboarded)');
        emit(state.copyWith(status: AuthStatus.guest, hasOnboarded: onboarded));
      }
    } catch (e, stack) {
      LogService().error('Fatal: Auth check failed', e, stack);
      // Fail gracefully to guest mode so app doesn't hang
      emit(state.copyWith(status: AuthStatus.guest, hasOnboarded: false));
    }
  }

  Future<void> _onGuestMode(
    AuthGuestModeEntered event,
    Emitter<AuthState> emit,
  ) async {
    await setOnboarded();
    emit(state.copyWith(status: AuthStatus.guest, hasOnboarded: true));
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // TODO: Replace with actual API call to send OTP
      await Future<void>.delayed(const Duration(seconds: 1));

      LogService().info('📱 OTP sent to ${event.phoneNumber}');
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
          error: 'Failed to send OTP. Please try again.',
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
      // TODO: Replace with actual OTP verification API call
      await Future<void>.delayed(const Duration(seconds: 1));

      // Mock: any 4-digit code is "correct"
      if (event.otp.length == 4) {
        // Persist token
        await _storage.write(key: _tokenKey, value: 'mock_token_${event.otp}');

        LogService().info('✅ OTP verified — user authenticated');
        emit(
          state.copyWith(status: AuthStatus.authenticated, isLoading: false),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Invalid code. Please try again.',
          ),
        );
      }
    } catch (e, stack) {
      LogService().error('OTP verification failed', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Verification failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // TODO: Replace with actual Google Sign-In
      await Future<void>.delayed(const Duration(seconds: 1));

      await _storage.write(key: _tokenKey, value: 'google_mock_token');

      LogService().info('✅ Google Sign-In — user authenticated');
      emit(state.copyWith(status: AuthStatus.authenticated, isLoading: false));
    } catch (e, stack) {
      LogService().error('Google Sign-In failed', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Google Sign-In failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpCancelled(
    AuthOtpCancelled event,
    Emitter<AuthState> emit,
  ) async {
    // Reset to guest so the sheet shows phone input again
    emit(
      state.copyWith(
        status: AuthStatus.guest,
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
    await _storage.delete(key: _tokenKey);
    LogService().info('👋 User logged out → guest mode');
    emit(const AuthState(status: AuthStatus.guest));
  }
}
