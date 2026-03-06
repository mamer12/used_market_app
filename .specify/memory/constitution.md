<!--
SYNC IMPACT REPORT
==================
Version change: [TEMPLATE / unversioned] → 1.0.0
Bump rationale: MINOR — initial ratification; all placeholders replaced with concrete values,
  8 principles defined (5 architectural + 3 quality), 2 additional sections added.

Modified principles (template → concrete):
  [PRINCIPLE_1_NAME] → I. Clean Architecture (NON-NEGOTIABLE)
  [PRINCIPLE_2_NAME] → II. State Management: BLoC / Cubit Only (NON-NEGOTIABLE)
  [PRINCIPLE_3_NAME] → III. Dependency Injection & Routing
  [PRINCIPLE_4_NAME] → IV. Mini-App State Isolation (NON-NEGOTIABLE)
  [PRINCIPLE_5_NAME] → V. Code Quality
  (expanded template to 8 principles)
  Added: VI. Testing Standards
  Added: VII. UI/UX Consistency (RTL, Arabic, IQD)
  Added: VIII. Performance Requirements

[SECTION_2_NAME] → Technology Stack & Constraints
[SECTION_3_NAME] → Development Workflow & Quality Gates

Templates requiring updates:
  ✅ .specify/memory/constitution.md       — this file (overwritten)
  ⚠  .specify/templates/plan-template.md  — Constitution Check section references generic gates;
                                            update to reference Luqta principles by name.
  ⚠  .specify/templates/spec-template.md  — Add Luqta-specific FR constraints (RTL, BLoC, IQD).
  ⚠  .specify/templates/tasks-template.md — Add BLoC task type and RTL/a11y task type categories.

Deferred TODOs:
  None — all fields resolved from user input and repo context.
-->

# Luqta (لكطة) Constitution

## Core Principles

### I. Clean Architecture (NON-NEGOTIABLE)

Every feature MUST be structured into exactly three layers in this order:
**Data → Domain → Presentation**. No layer may depend on a layer above it.

- **Domain layer** MUST contain only pure Dart: entities, repository interfaces, and use-cases.
  It MUST NOT import Flutter, BLoC, or any third-party packages except `equatable` and
  `dartz` (or equivalent functional types).
- **Data layer** MUST contain models (which extend/map to domain entities), remote data
  sources, local data sources, and repository implementations. It MUST NOT import
  presentation-layer widgets or BLoC classes.
- **Presentation layer** MUST contain pages, widgets, BLoC/Cubit classes, and nothing else.
  Business logic MUST live in use-cases, not in Cubits or widgets.
- Directory structure MUST follow:
  `lib/features/<feature>/{data,domain,presentation}/`
- Cross-feature shared code MUST live in `lib/core/` — never copy-pasted between features.

**Rationale**: Enforces testability, replaceability of infrastructure, and prevents
business logic from leaking into the UI layer — critical for a multi-mini-app super-app.

### II. State Management: BLoC / Cubit Only (NON-NEGOTIABLE)

All application state MUST be managed exclusively using `flutter_bloc` (BLoC or Cubit).

- `Provider`, `Riverpod`, `ChangeNotifier`, `ValueNotifier`, or any other state-management
  solution are **PROHIBITED** — even for "simple" local state where a Cubit would suffice.
- Use **Cubit** for simple, linear state transitions (no complex event streams).
- Use **BLoC** for complex event-driven flows (e.g., WebSocket bids, multi-step auth).
- BLoC/Cubit classes MUST live in `presentation/bloc/` and MUST call use-cases — never
  repositories or data sources directly.
- State classes MUST be immutable and extend `Equatable`.

**Rationale**: Consistency across the entire codebase enables predictable debugging,
clear audit trails for state changes, and standardised tooling (flutter_devtools BLoC
observer).

### III. Dependency Injection & Routing

- **Dependency Injection**: MUST use `get_it` as the service locator and `injectable`
  for code-gen registration. Every injectable class MUST be annotated
  (`@injectable`, `@singleton`, `@lazySingleton`). Manual `GetIt.instance.registerFactory`
  calls outside of generated code are **PROHIBITED**.
- **Routing**: MUST use `go_router`. `Navigator.push/pop` direct calls and `MaterialPageRoute`
  instantiation are **PROHIBITED** in feature code. All route declarations MUST reside in
  `lib/core/router/`.
- New features MUST register their DI module in `lib/core/di/` via an `@module`-annotated
  class and re-run `flutter pub run build_runner build` before opening a PR.

**Rationale**: Centralised DI and routing prevent spaghetti wiring and enable zero-friction
feature isolation for the mini-app architecture.

### IV. Mini-App State Isolation (NON-NEGOTIABLE)

Global app state and per-mini-app state MUST NEVER be mixed.

- Each mini-app (e.g., Matajir shop, Balla auction) owns its BLoC/Cubit subtree and
  provides it via its own `MultiBlocProvider` at the mini-app's root route.
- Global state (auth, user profile, notifications) MUST be provided at the app root in
  `bootstrap.dart` and accessed read-only by mini-apps via `context.read<>()` — never
  mutated from within a mini-app.
- Cart state is **scoped per mini-app** (use `ScopedCartCubit`). A single shared
  `CartCubit` for the whole app is **PROHIBITED**.
- Mini-apps MUST communicate cross-boundary only through domain events / use-case outputs —
  never by directly reading another mini-app's Cubit.

**Rationale**: Isolation prevents checkout flow contamination between Matajir and Balla,
enables independent testing, and is the contract underpinning the super-app architecture.

### V. Code Quality

- All Dart code MUST pass `flutter analyze` with zero errors and zero warnings before merge.
  Suppression annotations (`// ignore:`) MUST include a clear justification comment;
  blanket suppressions are **PROHIBITED**.
- Public APIs (use-cases, repository interfaces, model factories) MUST have Dart doc
  comments (`///`).
- File length MUST NOT exceed 300 lines. Files exceeding this MUST be split. Exceptions
  require a justification comment at the top of the file.
- Naming MUST follow Dart conventions: `snake_case` for files and folders,
  `PascalCase` for types, `camelCase` for variables/methods, `SCREAMING_SNAKE_CASE`
  for top-level constants.
- No dead code, commented-out code blocks, or debug `print()` statements in committed
  files. Logging MUST use the project's structured logger (`lib/core/utils/logger.dart`).

**Rationale**: Consistent, clean code reduces cognitive load and onboarding time in a
codebase that spans 10+ mini-app features.

### VI. Testing Standards

- Every use-case MUST have at least one unit test covering the happy path and one covering
  the primary failure path, placed in `test/features/<feature>/domain/`.
- Repository implementations MUST have unit tests with mocked data sources
  (use `mocktail`). No real network or file-system I/O is permitted in unit tests.
- Widget tests MUST be written for any screen that contains conditional rendering logic
  (loading / error / data states). Place in `test/features/<feature>/presentation/`.
- BLoC/Cubit classes MUST be tested with `bloc_test`. Each meaningful state transition
  MUST have a corresponding `blocTest` case.
- Test coverage for `lib/core/` MUST remain ≥ 80 % (enforced via CI).
- Tests MUST be run and pass before a PR is opened (`flutter test`). Flaky tests MUST be
  fixed or quarantined within one sprint of detection.

**Rationale**: A marketplace app handles money and user trust; regressions in cart,
checkout, or auth flows are unacceptable without a safety net.

### VII. UI/UX Consistency (RTL · Arabic · IQD)

- The app's primary language is **Arabic**. All layouts MUST be Right-to-Left (RTL) first.
  `Directionality` MUST be set to `TextDirection.rtl` at the app root.
- Typography MUST use the **Cairo** Google Font family (`google_fonts` package) at all
  text hierarchy levels. Custom fonts other than Cairo are **PROHIBITED** unless a brand
  exception is documented in `lib/core/theme/`.
- All monetary values MUST be formatted as Iraqi Dinar using the pattern:
  `###,### د.ع` (e.g., `150,000 د.ع`). Raw integer/string rendering of currency amounts
  is **PROHIBITED**. Use the shared `IqdFormatter` utility in `lib/core/utils/`.
- All user-facing strings MUST be externalised via Flutter's `l10n` / ARB system
  (`lib/l10n/`). Hard-coded Arabic or English strings inside widget files are **PROHIBITED**.
- Theme tokens (colours, spacing, border radii, shadows) MUST be sourced from
  `AppTheme` in `lib/core/theme/`. Inline `Color(0xFF...)` literals in widget files
  are **PROHIBITED**.
- Every interactive element MUST meet WCAG AA contrast requirements and carry a
  `Semantics` label for screen-reader support.

**Rationale**: Luqta's audience is Iraqi users. RTL consistency, localisation, and correct
currency formatting are not polish — they are correctness requirements.

### VIII. Performance Requirements

- Initial route (home/portal screen) MUST reach First Meaningful Paint in ≤ 2 seconds on
  a mid-range Android device (equivalent to Snapdragon 665, 4 GB RAM) on a 4G connection.
- List views containing remote data MUST implement pagination (≤ 20 items per page).
  Loading all records into memory is **PROHIBITED**.
- Image assets MUST be served via cached network image (`cached_network_image`).
  Uncached `Image.network()` calls are **PROHIBITED** in production code.
- Expensive computations (JSON parsing of large payloads, image decoding) MUST be
  offloaded to an `Isolate` or performed outside the main thread.
- Widget rebuilds MUST be minimised: use `const` constructors wherever possible, and
  scope BLoC listeners (`BlocBuilder`/`BlocListener`) to the smallest subtree that needs
  the state.
- WebSocket connections (live auction bidding) MUST be gracefully reconnected on
  disconnection and MUST be closed when the relevant screen is disposed.

**Rationale**: A marketplace super-app targeting Iraqi consumers on heterogeneous hardware
must be performant to retain users and reduce churn at critical purchase funnel steps.

## Technology Stack & Constraints

| Concern              | Mandated Solution                         | Prohibited Alternatives                     |
|----------------------|-------------------------------------------|---------------------------------------------|
| State management     | `flutter_bloc` (BLoC + Cubit)             | Provider, Riverpod, ChangeNotifier, signals |
| Dependency injection | `get_it` + `injectable`                   | Manual registration, `provider` DI          |
| Routing              | `go_router`                               | `Navigator.push`, `auto_route`, `fluro`     |
| Fonts                | Cairo (Google Fonts)                      | Any other typeface without brand approval   |
| Currency display     | `IqdFormatter` (د.ع)                      | Raw `toString()` on monetary values         |
| Network images       | `cached_network_image`                    | `Image.network()` without cache             |
| Mocking in tests     | `mocktail`                                | `mockito` (requires code-gen per mock)      |
| Structured logging   | `lib/core/utils/logger.dart`              | `print()`, `debugPrint()` in committed code |
| Backend protocol     | REST/JSON + WebSocket (per Lugta API v1)  | GraphQL, gRPC (without architecture update) |

**Flutter SDK**: stable channel, minimum version declared in `pubspec.yaml`.
**Dart SDK**: follows Flutter stable's bundled Dart version.
**Target platforms**: iOS 15+, Android API 26+ (Oreo).

## Development Workflow & Quality Gates

All contributions MUST clear these gates in order before merging:

1. **Analyze**: `flutter analyze` — zero errors, zero warnings.
2. **Format**: `dart format --set-exit-if-changed .` — no unformatted files.
3. **Test**: `flutter test --coverage` — all tests pass; `lib/core/` coverage ≥ 80 %.
4. **Build**: `flutter build apk --debug` (or iOS equivalent) — no build errors.
5. **Constitution Check**: Reviewer verifies the PR does not violate any principle in this
   document. Violations block merge regardless of CI status.

Code reviews MUST check:
- Layer boundary compliance (no upward dependency violations).
- BLoC/Cubit-only state management.
- RTL layout correctness and ARB localisation for any new string.
- Correct IQD formatting for any new monetary display.
- DI registration re-generated if new injectable classes were added.

## Governance

This constitution supersedes all other development practices, README guidance, and
verbal agreements. Conflicts are resolved in favour of the constitution.

**Amendment Procedure**: Any principle change MUST be proposed as a dedicated PR against
this file, with a written rationale. The PR MUST receive approval from the project lead
before merge. Breaking changes (MAJOR version bump) additionally require a migration
plan documenting how existing code will be brought into compliance.

**Versioning Policy**: This document follows Semantic Versioning:
- **MAJOR** — principle removed, fundamentally redefined, or mandatory technology
  replaced (e.g., moving away from BLoC, adopting a different architecture).
- **MINOR** — new principle or mandatory section added; existing principle materially
  expanded with new hard rules.
- **PATCH** — clarifications, wording corrections, example additions, typo fixes;
  no change to the normative requirements.

**Compliance Review**: Constitution compliance MUST be reviewed as part of every
sprint retrospective. Any detected violation MUST be logged as a tech-debt ticket and
resolved within two sprints.

**Version**: 1.0.0 | **Ratified**: 2026-03-06 | **Last Amended**: 2026-03-06
