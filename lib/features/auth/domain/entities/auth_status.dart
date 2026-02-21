/// Authentication status throughout the app lifecycle.
enum AuthStatus {
  /// App just launched, haven't checked storage yet.
  initial,

  /// User explicitly chose to browse without logging in.
  guest,

  /// OTP has been sent, waiting for verification.
  otpSent,

  /// User not found. Registration flow requires full name.
  registrationNameRequired,

  /// User is fully authenticated with a valid session.
  authenticated,
}
