# Research: Mandatory Multi-Role Auth Flow

## 1. Backend Integration (Roles)
- **Problem**: Current `RegisterRequest` does not include a `role` field.
- **Decision**: Update `RegisterRequest` and `AuthRemoteDataSource` to include a `role` string.
- **Rationale**: Lugta API v1 supports `role` in the `user` object. Passing it during registration is the standard way to initialize user permissions (Merchant vs Consumer).
- **Alternatives**: Assign roles later via a profile update, but this complicates the "Merchant Onboarding" flow.

## 2. Authentication Guarding (go_router)
- **Problem**: Guests can currently browse the `HomePage`.
- **Decision**: Implement a `redirect` handler in `appRouter` that checks `AuthBloc.state.status`.
- **Rational**: `go_router` is the mandated routing library. A top-level redirect is the most secure way to enforce app-wide authentication.
- **Pattern**:
  ```dart
  redirect: (context, state) {
    final status = context.read<AuthBloc>().state.status;
    final isAuth = status == AuthStatus.authenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    // ... logic to redirect to /login or /onboarding
  }
  ```

## 3. UI/UX: Full-Page Auth vs Bottom Sheet
- **Problem**: Existing auth is in a bottom sheet (`AuthBottomSheet`).
- **Decision**: Migrate to dedicated pages: `LoginPage`, `VerifyOtpPage`, `RegistrationPage`.
- **Rationale**: Full-page flows feel more "premium" and secure for a mandatory auth step. It also provides more screen real-estate for the "User Role Selection" feature.

## 4. Multiple User Types
- **Defined Types**:
  1. `user`: Standard shopper for Mustamal/Matajir.
  2. `merchant`: Sellers who want to manage a shop in Matajir.
  3. `auctioneer`: Users focused on Balla auctions.
- **UI Element**: Three large vertical cards in the Registration step with icons and descriptive text (Arabic).

---
**Status**: Research complete. Proceeding to Phase 1 Design.
