# Implementation Plan: Mandatory Multi-Role Authentication Flow

**Branch**: `002-auth-multi-role-flow` | **Date**: 2026-03-06 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-auth-multi-role-flow/spec.md`

## Summary

Implementation of a mandatory, multi-role authentication flow for Luqta. This involves replacing the current "Lazy Auth" (guest) model with a strict gatekeeper at the app root. The new flow includes a full-page UI overhaul (Login, OTP, Registration with role selection), global router guards using `go_router`, and integration with the Lugta API roles.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.29.0  
**Primary Dependencies**: `flutter_bloc`, `go_router`, `get_it`, `injectable`, `dio`, `freezed`  
**Storage**: `flutter_secure_storage` for JWT tokens  
**Testing**: `bloc_test`, `mocktail`, `flutter_test`  
**Target Platform**: iOS 15+, Android API 26+
**Project Type**: Mobile App (Super App Architecture)  
**Performance Goals**: First Meaningful Paint ≤ 2s; Auth redirect logic < 100ms.  
**Constraints**: Luqta Constitution v1.0.0 (RTL first, Cairo typography, Clean Architecture).  
**Scale/Scope**: 3 new screens, 1 global router guard, ~5 new BLoC events.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify compliance with the [Luqta Constitution](.specify/memory/constitution.md) v1.0.0:

- [x] **Principle I — Clean Architecture**: Feature directories follow
  `lib/features/auth/{data,domain,presentation}/`. Domain layer is pure Dart only.
- [x] **Principle II — BLoC/Cubit Only**: Current `AuthBloc` will be extended; no forbidden state management used.
- [x] **Principle III — DI & Routing**: New pages added to `AppRouter`; `injectable` for any new use-cases.
- [x] **Principle IV — Mini-App Isolation**: Auth is a global feature provided at app root (bootstrap).
- [x] **Principle V — Code Quality**: Analyzing for zero warnings; file lengths monitored.
- [x] **Principle VI — Testing**: `AuthBloc` tests updated; new page widget tests added.
- [x] **Principle VII — RTL/Arabic/IQD**: All strings in `AppLocalizations`; RTL layouts for all new screens.
- [x] **Principle VIII — Performance**: `const` constructors for all UI layout components.

## Project Structure

### Documentation (this feature)

```text
specs/002-auth-multi-role-flow/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # [WIP] Phase 0 output
├── data-model.md        # [WIP] Phase 1 output
├── quickstart.md        # [WIP] Phase 1 output
├── contracts/           # [WIP] Phase 1 output
└── tasks.md             # Phase 2 output (generated later)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── router/          # AppRouter updated with guards and new routes
│   └── theme/           # UI tokens for new screens
└── features/
    ├── auth/
    │   ├── data/        # AuthModels updated for multi-role
    │   ├── domain/      # New RegisterUseCase (if required)
    │   └── presentation/# LoginPage, VerifyOtpPage, RegistrationPage
    └── onboarding/
        └── presentation/# Updated OnboardingPage (no guest entry)
```

**Structure Decision**: Standard Flutter Clean Architecture as mandated by Luqta Constitution Principle I.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
