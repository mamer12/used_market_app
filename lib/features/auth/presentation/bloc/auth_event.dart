import 'package:equatable/equatable.dart';

/// Events for the [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check for existing session on app startup.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User chose "Start Browsing" — enter guest mode.
class AuthGuestModeEntered extends AuthEvent {
  const AuthGuestModeEntered();
}

/// User submitted their phone number to request an OTP.
class AuthOtpRequested extends AuthEvent {
  final String phoneNumber;
  const AuthOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// User submitted the OTP code for verification.
class AuthOtpSubmitted extends AuthEvent {
  final String otp;
  const AuthOtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// User tapped "Sign in with Google".
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// User tapped "Change number" — go back to phone input.
class AuthOtpCancelled extends AuthEvent {
  const AuthOtpCancelled();
}

/// User explicitly logged out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
