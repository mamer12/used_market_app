# Tasks: Mandatory Multi-Role Authentication Flow

**Input**: Design documents from `/specs/002-auth-multi-role-flow/`
**Branch**: `002-auth-multi-role-flow`
**Prerequisites**: plan.md ✅ · spec.md ✅ · research.md ✅ · data-model.md ✅ · contracts/ui-contracts.md ✅ · quickstart.md ✅

**Organization**: Tasks grouped by User Story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] [Type] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label — [US1], [US2], [US3], [US4]
- **[BLoC]**: BLoC/Cubit class or state definition
- **[RTL]**: RTL layout, ARB localisation string
- **[DI]**: DI registration / build_runner re-generation
- **[PERF]**: Performance concern

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Clean up deprecated patterns and scaffold the new auth routing structure.

- [x] T001 Remove `AuthStatus.guest` from `lib/features/auth/domain/entities/auth_status.dart` and rename `registrationNameRequired` → `registrationRequired`; add `unauthenticated` status
- [x] T002 Remove `AuthGuestModeEntered` event and its handler `_onGuestMode` from `lib/features/auth/presentation/bloc/auth_event.dart` and `lib/features/auth/presentation/bloc/auth_bloc.dart`
- [x] T003 [P] Create the directory `lib/features/auth/presentation/pages/` (ensure it exists for new page files)
- [x] T004 [P] Create placeholder page files: `lib/features/auth/presentation/pages/login_page.dart`, `verify_otp_page.dart`, `registration_page.dart` (stub `Scaffold` widgets)

**Checkpoint**: Old guest mode code is gone; new page stubs exist. `flutter analyze` passes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core domain/data layer and router guard must be complete before UI work.

⚠️ **CRITICAL**: No User Story UI work can begin until this phase is complete.

- [x] T005 [BLoC] Update `AuthBloc._onCheckRequested` in `lib/features/auth/presentation/bloc/auth_bloc.dart` to emit `AuthStatus.unauthenticated` (not `guest`) when no session is found
- [x] T006 [BLoC] Update `AuthBloc._onLogout` in `lib/features/auth/presentation/bloc/auth_bloc.dart` to emit `AuthStatus.unauthenticated` (not `guest`)
- [x] T007 Add `role` field (`required String role`) to `RegisterRequest` in `lib/features/auth/data/models/auth_models.dart`
- [x] T008 [DI] Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate `auth_models.freezed.dart` and `auth_models.g.dart`
- [x] T009 Update `AuthRepository.register()` interface in `lib/features/auth/domain/repositories/auth_repository.dart` to pass the updated `RegisterRequest` (no signature change needed — model carries `role`)
- [x] T010 Update `AuthRemoteDataSource.register()` in `lib/features/auth/data/datasources/auth_remote_data_source.dart` — confirm `role` is serialized in `request.toJson()` (auto-generated, verify output)
- [x] T011 Add `role` parameter to `AuthRegistrationNameSubmitted` event in `lib/features/auth/presentation/bloc/auth_event.dart`
- [x] T012 [BLoC] Update `AuthBloc._onRegistrationNameSubmitted` in `lib/features/auth/presentation/bloc/auth_bloc.dart` to pass `event.role` into the `RegisterRequest`
- [x] T013 Add global `redirect` handler to `appRouter` in `lib/core/router/app_router.dart`:
  - If `status == initial` → return `null` (let app decide after check)
  - If `status == unauthenticated` and not already on `/login`, `/verify-otp`, `/register`, `/onboarding` → redirect to `/login`
  - If `status == authenticated` and on `/login` or `/register` → redirect to `/`
- [x] T014 Register new routes in `lib/core/router/app_router.dart`:
  - `GoRoute(path: '/login', builder: LoginPage)`
  - `GoRoute(path: '/verify-otp', builder: VerifyOtpPage)`
  - `GoRoute(path: '/register', builder: RegistrationPage)`
- [x] T015 [RTL] Add new ARB localisation keys to `lib/l10n/arb/app_ar.arb` and `app_en.arb`:
  - `loginTitle`, `loginSubtitle`, `loginPhoneHint`
  - `verifyOtpTitle`, `verifyOtpSubtitle`, `verifyOtpResend`
  - `registerTitle`, `registerFullNameHint`, `registerRoleTitle`
  - `roleUser`, `roleMerchant`, `roleAuctioneer`
  - `roleUserDesc`, `roleMerchantDesc`, `roleAuctioneerDesc`

**Checkpoint**: Router guard is live, new ARB keys exist, BLoC emits correct states. `flutter analyze` passes.

---

## Phase 3: User Story 1 — Login (Phone + OTP) (Priority: P1) 🎯 MVP

**Goal**: A user can enter their phone number, receive an OTP, and log in to an existing account.

**Independent Test**: Launch app → redirected to `/login` → enter valid Iraqi phone number → OTP verification screen appears → enter correct OTP → lands on Home Portal (`/`).

### Implementation for User Story 1

- [x] T016 [US1] [RTL] Build `LoginPage` in `lib/features/auth/presentation/pages/login_page.dart`:
  - Full-page `Scaffold` with `AppTheme.background`
  - Luqta logo / icon at top (use `AppTheme` primary colour)
  - Arabic title from `l10n.loginTitle` (Cairo, 24sp, bold)
  - Phone input widget with Iraqi `+964` country prefix (RTL-aware `Row`)
  - "Get Code" `PrimaryButton` that fires `AuthOtpRequested('+964$phone')`
  - `BlocBuilder` for loading state on button and error display
- [x] T017 [US1] [RTL] Build `VerifyOtpPage` in `lib/features/auth/presentation/pages/verify_otp_page.dart`:
  - 6-digit OTP boxes (extract `_OtpInputRow` widget, ≤ 100 lines)
  - Auto-focus on first box; auto-advance on digit entry; auto-submit on 6th digit
  - "Edit number" back link fires `AuthOtpCancelled` → pops to `/login`
  - 30-second resend countdown timer with `StatefulWidget`
  - `BlocListener` for `authenticated` → `context.go('/')`, `registrationRequired` → `context.go('/register')`
  - Error text in `AppTheme.liveBadge` colour
- [x] T018 [US1] [BLoC] Update `OnboardingPage` in `lib/features/onboarding/presentation/pages/onboarding_page.dart`:
  - Change "Get Started" (`_startBrowsing`) from `AuthGuestModeEntered` + `context.go('/')` to `context.go('/login')`
  - Change "Skip" button similarly → `context.go('/login')`
  - Remove any `AuthBloc` dependency from `OnboardingPage` if no longer needed

**Checkpoint**: User can complete a full login cycle from `/login` → OTP → Home. Guest route is completely blocked.

---

## Phase 4: User Story 2 — Registration with Role Selection (Priority: P2)

**Goal**: A new user can complete registration by entering their full name and selecting a user type (Shopper, Merchant, Auctioneer), then lands on the Home Portal.

**Independent Test**: Enter a phone number not registered → OTP screen → enter OTP → redirected to `/register` → enter name and tap "Merchant" role card → "Complete Registration" → lands on `/`.

### Implementation for User Story 2

- [x] T019 [US2] [RTL] Build `RegistrationPage` in `lib/features/auth/presentation/pages/registration_page.dart`:
  - Full-page `Scaffold` with step indicator ("الخطوة 3 من 3")
  - Full name `TextFormField` with label from `l10n.registerFullNameHint` (RTL)
  - "Who are you?" role selection section using `_RoleCard` widgets (see T020)
  - "Complete Registration" `PrimaryButton` — disabled until both name and role are selected
  - Button fires `AuthRegistrationNameSubmitted(fullName: name, role: selectedRole)`
  - `BlocListener` for `authenticated` → `context.go('/')`
  - Error text display from `state.error`
- [x] T020 [US2] [P] [RTL] Build `_RoleCard` private widget inside or alongside `registration_page.dart`:
  - Three cards displayed vertically: Shopper (`user`), Merchant (`merchant`), Auctioneer (`auctioneer`)
  - Each card: Icon + Arabic title (from ARB) + Arabic description, bordered container
  - Selected card: `AppTheme.primary` border highlight + checkmark icon
  - Tapping updates local `selectedRole` state variable in `RegistrationPage`
- [x] T021 [US2] [BLoC] Ensure `AuthBloc._onRegistrationNameSubmitted` correctly routes to `AuthStatus.authenticated` after a successful register → `getUser()` call (already done in T012 — verify end-to-end)

**Checkpoint**: New user can self-register with a role. Returning to app after registration shows Home Portal (not `/register`).

---

## Phase 5: User Story 3 — Persistent Session & Deep Link Guard (Priority: P3)

**Goal**: A user who has previously authenticated is taken directly to the Home Portal on re-launch. Unauthenticated deep links to internal routes are intercepted and redirected to `/login`, then resume original destination after login.

**Independent Test**:
- Kill and relaunch app → still authenticated → Home Portal appears (no login screen).
- Force logout → relaunch → `/login` screen appears.
- Deep link to `/matajir` while logged out → `/login` → authenticate → lands on `/matajir`.

### Implementation for User Story 3

- [x] T022 [US3] Verify `AuthBloc._onCheckRequested` in `lib/features/auth/presentation/bloc/auth_bloc.dart` handles the `initial` status splash correctly — app waits for check before routing (add `SplashPage` or `CircularProgressIndicator` at root if needed)
- [x] T023 [US3] Implement redirect target preservation in `lib/core/router/app_router.dart`:
  - When redirecting unauthenticated user, store `state.matchedLocation` as a query param: `/login?redirect=/matajir`
  - After successful auth in `LoginPage`/`VerifyOtpPage`, read `redirect` query param and `context.go(redirect ?? '/')`
- [x] T024 [US3] [RTL] Add a minimal `SplashPage` (or loading overlay) in `lib/features/auth/presentation/pages/splash_page.dart` shown while `AuthStatus == initial`:
  - Luqta logo centred, `CircularProgressIndicator` below
  - Route `/` shows splash until auth check completes, then router redirects

**Checkpoint**: Session persistence verified on device restart. Deep links work after login.

---

## Phase 6: User Story 4 — Remove `AuthBottomSheet` & Cleanup (Priority: P4)

**Goal**: Remove the legacy "Lazy Auth" bottom-sheet trigger pattern from all screens that used it.

**Independent Test**: Search codebase for `AuthBottomSheet.show` and `AuthGuard` — zero results remain.

### Implementation for User Story 4

- [x] T025 [US4] [P] Search for all `AuthBottomSheet.show(` call sites with `grep -r "AuthBottomSheet.show" lib/` and replace each with a `context.go('/login')` redirect or a constitution-compliant guard
- [x] T026 [US4] [P] Search for and remove any `AuthGuard` widget usages with `grep -r "AuthGuard" lib/` — the global router redirect replaces per-screen guards
- [x] T027 [US4] Delete or archive `lib/features/auth/presentation/widgets/auth_bottom_sheet.dart` (move to a `_deprecated/` folder temporarily or delete after T025 confirms no remaining usages)
- [x] T028 [US4] Remove `clearPhoneNumber` workaround in `AuthState.copyWith` in `lib/features/auth/presentation/bloc/auth_state.dart` if it was only used for resetting to `guest` mode

**Checkpoint**: `grep -r "AuthBottomSheet\|AuthGuard\|AuthStatus.guest\|AuthGuestModeEntered" lib/` returns zero results.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [x] T029 [RTL] Audit all new pages with `flutter run` on a device in RTL mode — verify alignment, text direction, and padding are not mirrored incorrectly
- [x] T030 [PERF] Add `const` constructors to all stateless widgets in the new auth pages
- [x] T031 Run `flutter analyze` — resolve all warnings and errors to zero
- [x] T032 Run `dart format .` and confirm no formatting diffs
- [x] T033 Run `flutter pub run build_runner build --delete-conflicting-outputs` one final time to ensure generated files are up to date
- [x] T034 [DI] Verify `injectable` / `get_it` registration still compiles cleanly — `flutter pub get && flutter build apk --debug`
- [x] T035 [RTL] Verify all new ARB string keys are present in both `app_ar.arb` and `app_en.arb` — `flutter gen-l10n`
- [x] T036 Manual smoke test per `quickstart.md` run order — validate all 3 user stories end-to-end on device

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup) ──────────────────────────────▶ can start immediately
Phase 2 (Foundational) ◀── requires Phase 1 ──▶ BLOCKS all User Story phases
Phase 3 (US1 Login) ◀────── requires Phase 2
Phase 4 (US2 Register) ◀─── requires Phase 2  (can run in parallel with Phase 3)
Phase 5 (US3 Session) ◀──── requires Phase 2 + Phase 3
Phase 6 (US4 Cleanup) ◀──── requires Phase 3 + Phase 4
Phase 7 (Polish) ◀────────── requires all phases
```

### User Story Dependencies

- **US1 (Login)**: Depends on Phase 2 only — start first.
- **US2 (Registration)**: Depends on Phase 2 only — can start in parallel with US1.
- **US3 (Session)**: Depends on US1 being complete (needs the full login flow working).
- **US4 (Cleanup)**: Depends on US1 + US2 (bottom sheet replacement requires new pages to exist).

### Key Parallel Opportunities within Phases

```bash
# Phase 1 — run in parallel:
T003 Create pages directory
T004 Create page stubs

# Phase 2 — run in parallel after T007+T008:
T009 Verify repository interface
T010 Verify datasource serialization
T011 Update AuthEvent
T015 Add ARB keys

# Phase 3 + Phase 4 — run in parallel teams:
T016–T018 (Login flow)
T019–T021 (Registration flow)
```

---

## Implementation Strategy

### MVP (US1 Only)

1. ✅ Complete Phase 1: Setup — clear guest code
2. ✅ Complete Phase 2: Foundation — router guard + BLoC states + ARB keys
3. ✅ Complete Phase 3: US1 Login — phone + OTP pages wired up
4. **STOP and VALIDATE**: Full login cycle works end-to-end on device.

### Incremental Delivery

1. Setup + Foundation → Guard is live, app blocks unauthenticated users
2. Add US1 (Login) → MVP: users can log in
3. Add US2 (Registration) → New users can self-register with a role
4. Add US3 (Session) → Returning users skip login; deep links work
5. Add US4 (Cleanup) → Legacy bottom-sheet code removed

---

## Notes

- All new strings MUST be in both `app_ar.arb` and `app_en.arb` before `flutter gen-l10n`.
- The `role` field in `RegisterRequest` may need backend confirmation — if `POST /auth/otp/register` does not accept it yet, post-register with `PATCH /users/me` as a fallback (document in research.md).
- `AuthBottomSheet` (T027) should only be deleted AFTER T025 confirms zero remaining call sites.
- File length limit is 300 lines (Constitution §V) — split `registration_page.dart` if `_RoleCard` bloats it.
