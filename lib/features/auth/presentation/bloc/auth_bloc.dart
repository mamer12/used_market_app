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

/// Manages the full authentication lifecycle for "Lazy Auth".
///
/// The user starts as a guest and can browse freely.
/// Login is triggered contextually via [AuthGuard] → Bottom Sheet.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;
  static const _onboardedKey = 'has_onboarded';

  AuthBloc(this._authRepository, {@factoryParam FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGuestModeEntered>(_onGuestMode);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthRegistrationNameSubmitted>(_onRegistrationNameSubmitted);
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
      final results = await Future.wait([
        _authRepository.isLoggedIn(),
        hasOnboarded(),
      ]).timeout(const Duration(seconds: 2));

      final isLoggedIn = results[0];
      final onboarded = results[1];

      if (isLoggedIn) {
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
      // In a real app, we would send the OTP request to the backend.
      // Lugta relies on OTPs now. Sending request:
      await _authRepository.sendOtp(
        SendOtpRequest(phoneNumber: event.phoneNumber),
      );
      LogService().info('📱 OTP Sent to ${event.phoneNumber}');
      emit(
        state.copyWith(
          status:
              AuthStatus.otpSent, // Repurposing as "password requested" state
          phoneNumber: event.phoneNumber,
          isLoading: false,
        ),
      );
    } catch (e, stack) {
      LogService().error('Request failed', e, stack);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to process request. Please try again.',
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
        throw Exception("Phone number missing");
      }

      LogService().info('Attempting login with API...');
      // We pass the OTP code as the password for the login endpoint
      await _authRepository.login(
        LoginRequest(phoneNumber: state.phoneNumber!, otp: event.otp),
      );

      LogService().info('✅ Login successful');
      emit(state.copyWith(status: AuthStatus.authenticated, isLoading: false));
    } on DioException catch (e) {
      LogService().error('API Login failed', e, StackTrace.current);

      String errorMessage = "Login failed";
      int? statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiErr = e.error as ApiException;
        errorMessage = apiErr.message;
        statusCode = apiErr.statusCode ?? statusCode;
      } else {
        errorMessage = e.message ?? "Unknown error";
      }

      // If the user doesn't exist, we fallback to requesting their name for registration
      // The backend returns 401 "user not found" when logging in with an unregistered phone
      if (errorMessage.toLowerCase().contains("not found") ||
          statusCode == 404 ||
          statusCode == 401) {
        LogService().info('Account not found. Prompting for Name...');
        emit(
          state.copyWith(
            status: AuthStatus.registrationNameRequired,
            isLoading: false,
            otpCode: event.otp,
          ),
        );
        return;
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    } catch (e, stack) {
      LogService().error('Login/OTP failed', e, stack);
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
        throw Exception("Missing phone number or OTP code");
      }

      LogService().info('Attempting registration...');
      await _authRepository.register(
        RegisterRequest(
          fullName: event.fullName,
          phoneNumber: state.phoneNumber!,
          otp: state.otpCode!,
        ),
      );

      LogService().info('✅ Registration successful');
      emit(state.copyWith(status: AuthStatus.authenticated, isLoading: false));
    } on DioException catch (e) {
      LogService().error('Registration failed (Dio)', e, StackTrace.current);
      String errorMessage = "Registration failed";
      if (e.error is ApiException) {
        errorMessage = (e.error as ApiException).message;
      } else {
        errorMessage = e.message ?? "Unknown error";
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

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // TODO: Replace with actual Google Sign-In
      await Future<void>.delayed(const Duration(seconds: 1));

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
    await _authRepository.logout();
    LogService().info('👋 User logged out → guest mode');
    emit(const AuthState(status: AuthStatus.guest));
  }
}
