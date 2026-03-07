# Quickstart: Mandatory Multi-Role Auth Flow

## Branch
`002-auth-multi-role-flow`

## What This Feature Does
Replaces the "Lazy Auth" (guest browsing) pattern with a mandatory, role-aware authentication flow. Users MUST log in before accessing any part of the Super App.

---

## Key Components to Build/Modify

### 1. `AuthStatus` (Domain)
- **File**: `lib/features/auth/domain/entities/auth_status.dart`
- **Change**: Remove `guest`, rename `registrationNameRequired` → `registrationRequired`, add `unauthenticated` (renamed from logic-less `initial` after check).

### 2. `AuthEvent` (Presentation/BLoC)
- **File**: `lib/features/auth/presentation/bloc/auth_event.dart`
- **Change**: Remove `AuthGuestModeEntered`. Add `role` parameter to `AuthRegistrationNameSubmitted`.

### 3. `AuthBloc` (Presentation/BLoC)
- **File**: `lib/features/auth/presentation/bloc/auth_bloc.dart`
- **Change**: Remove `_onGuestMode` handler. Update `_onCheckRequested` to emit `unauthenticated` instead of `guest`. Update `_onRegistrationNameSubmitted` to pass `role` to repository.

### 4. `RegisterRequest` (Data/Models)
- **File**: `lib/features/auth/data/models/auth_models.dart`
- **Change**: Add `role: String` field to `RegisterRequest`. Run `build_runner`.

### 5. `AuthRepository` + `AuthRepositoryImpl` (Data)
- **File**: `lib/features/auth/domain/repositories/auth_repository.dart` + `impl`
- **Change**: `register()` signature to accept new `RegisterRequest` with `role`.

### 6. `AppRouter` (Core/Router)
- **File**: `lib/core/router/app_router.dart`
- **Change**: Add `redirect` handler. Remove `/onboarding`'s guest path. Add:
  - `/login` → `LoginPage`
  - `/verify-otp` → `VerifyOtpPage`
  - `/register` → `RegistrationPage`

### 7. New Pages (Presentation)
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/verify_otp_page.dart`
- `lib/features/auth/presentation/pages/registration_page.dart`

### 8. `OnboardingPage` (Onboarding)
- **File**: `lib/features/onboarding/presentation/pages/onboarding_page.dart`
- **Change**: Change "Get Started" / "Skip" buttons to navigate to `/login` instead of calling `AuthGuestModeEntered`.

---

## Run Order
1. Update `AuthStatus` enum
2. Update `AuthEvent` / `AuthState`
3. Update `AuthBloc`
4. Update `RegisterRequest` + run `flutter pub run build_runner build --delete-conflicting-outputs`
5. Update `AuthRepository` interface and impl
6. Update `AppRouter` with redirect guard + new routes
7. Build new pages: `LoginPage`, `VerifyOtpPage`, `RegistrationPage`
8. Update `OnboardingPage`
9. Run `flutter analyze` — resolve all warnings
10. Run `flutter test`
