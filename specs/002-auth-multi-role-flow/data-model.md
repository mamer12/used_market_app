# Data Model Update: Multi-Role Auth

## RegisterRequest
Updated `lib/features/auth/data/models/auth_models.dart`:
- `fullName`: `String` (Required)
- `phoneNumber`: `String` (Required - E.164)
- `otp`: `String` (Required - 6 digits)
- **`role`**: `String` (Required - `user` | `merchant` | `auctioneer`)

## UserModel
Already handled in `lib/features/auth/data/models/auth_models.dart`:
- `id`: `String?`
- `fullName`: `@JsonKey(name: 'full_name') String?`
- `role`: `String` (Default: `user`)
- `isVerified`: `bool`

## AuthStatus (Enum)
Updated `lib/features/auth/domain/entities/auth_status.dart`:
- `initial`: Checking storage
- `onboarding`: First launch
- `unauthenticated`: Needs login
- `otpSent`: Waiting for verify
- `registrationRequired`: New user, needs name + role
- `authenticated`: Full session
