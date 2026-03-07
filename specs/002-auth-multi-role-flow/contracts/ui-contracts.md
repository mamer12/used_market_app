## UI Contracts: Auth Flow Screens
### `/login` — LoginPage
**Route**: `go_router` path `/login`
**Access**: Public (redirected here if unauthenticated)
**Inputs**: Phone number (string, E.164 prefix `+964`)
**Outputs**: Fires `AuthOtpRequested(phoneNumber)` event on BLoC
**Navigation**: On `AuthStatus.otpSent` → go_router redirects to `/verify-otp`

---

### `/verify-otp` — VerifyOtpPage
**Route**: `go_router` path `/verify-otp`
**Access**: Public (only valid when `AuthStatus == otpSent`)
**Inputs**: 6-digit OTP code
**Outputs**: Fires `AuthOtpSubmitted(otp)` event on BLoC
**Navigation**:
- On `AuthStatus.authenticated` → go_router redirects to `/`
- On `AuthStatus.registrationRequired` → go_router redirects to `/register`

---

### `/register` — RegistrationPage
**Route**: `go_router` path `/register`
**Access**: Public (only valid when `AuthStatus == registrationRequired`)
**Inputs**:
  - `fullName`: `String` (free text, required, min 2 chars)
  - `role`: `String` — one of `user`, `merchant`, `auctioneer` (selected via card)
**Outputs**: Fires `AuthRegistrationNameSubmitted(fullName, role)` event on BLoC
**Navigation**: On `AuthStatus.authenticated` → go_router redirects to `/`

---

## BLoC API Contracts

### Events (new/modified)
| Event | Fields | Description |
|---|---|---|
| `AuthOtpRequested` | `phoneNumber: String` | Sends OTP to backend |
| `AuthOtpSubmitted` | `otp: String` | Attempts OTP login |
| `AuthRegistrationNameSubmitted` | `fullName: String`, **`role: String`** | Registers new user with role |
| `AuthLogoutRequested` | - | Clears session |
| ~~`AuthGuestModeEntered`~~ | - | **REMOVED** — guest mode disabled |

### States
| State | Description |
|---|---|
| `initial` | App launched, checking storage |
| `unauthenticated` | No session, redirect to `/login` |
| `otpSent` | OTP sent, show `/verify-otp` |
| `registrationRequired` | New user, show `/register` |
| `authenticated` | Valid session, allow Home Portal |
| ~~`guest`~~ | **REMOVED** |

---

## Backend API Contracts (from Lugta API v1)

### POST /auth/otp/send
```json
{ "phone_number": "+96477XXXXXXXX" }
```

### POST /auth/otp/login (existing user)
```json
{ "phone_number": "+96477XXXXXXXX", "otp": "123456" }
```

### POST /auth/otp/register (new user)
```json
{ "full_name": "Ahmed Ali", "phone_number": "+96477XXXXXXXX", "otp": "123456", "role": "merchant" }
```
> **Note**: `role` field to be confirmed with backend team; may use PATCH /users/me if not supported in register.
