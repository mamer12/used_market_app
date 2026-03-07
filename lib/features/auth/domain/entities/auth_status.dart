/// Authentication status throughout the app lifecycle.
enum AuthStatus {
  /// App just launched, haven't checked storage yet.
  initial,

  /// No valid session — user must authenticate.
  unauthenticated,

  /// OTP has been sent, waiting for verification.
  otpSent,

  /// User not found. Registration flow requires full name + role.
  registrationRequired,

  /// User is fully authenticated with a valid session.
  authenticated,
}
