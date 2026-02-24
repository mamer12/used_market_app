import 'package:equatable/equatable.dart';

import '../../data/models/auth_models.dart';
import '../../domain/entities/auth_status.dart';

/// Immutable auth state.
class AuthState extends Equatable {
  final AuthStatus status;

  /// Phone number used for OTP, retained across the flow.
  final String? phoneNumber;

  /// Display name / nickname (progressive: collected after first action).
  final String? displayName;

  /// Retained OTP code needed for subsequent registration if login fails.
  final String? otpCode;

  /// Error message if something went wrong.
  final String? error;

  /// Whether an async operation is in progress (OTP send, verify, etc.).
  final bool isLoading;

  /// Whether the user has completed onboarding.
  final bool hasOnboarded;

  /// The fetched user profile data.
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.phoneNumber,
    this.displayName,
    this.otpCode,
    this.error,
    this.isLoading = false,
    this.hasOnboarded = false,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? displayName,
    String? otpCode,
    String? error,
    bool? isLoading,
    bool? hasOnboarded,
    UserModel? user,
    bool clearPhoneNumber = false,
    bool clearDisplayName = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      otpCode: otpCode ?? this.otpCode,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Quick check used by AuthGuard.
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest =>
      status == AuthStatus.guest || status == AuthStatus.initial;

  @override
  List<Object?> get props => [
    status,
    phoneNumber,
    displayName,
    otpCode,
    error,
    isLoading,
    hasOnboarded,
    user,
  ];
}
