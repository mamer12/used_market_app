# Feature Specification: Mandatory Multi-Role Authentication Flow

## 1. Vision & Goals
Transition Luqta from a "Lazy Auth" model (guest browsing) to a **Mandatory Authentication** model. This ensures higher user conversion, personalized experiences based on user roles, and secure access to the Super App's mini-apps (Matajir, Balla, Mustamal).

### Goals:
- **Zero Guest Access**: Users must authenticate to see the Home Portal.
- **Multi-Role Support**: Distinguish between Shoppers, Merchants, and Auctioneers during onboarding.
- **Premium UX**: Replace the current bottom-sheet login with a high-fidelity, full-page authentication flow.
- **RTL/Arabic First**: Full compliance with Luqta Constitution Principle VII.

---

## 2. Requirements

### 2.1 Navigation & Guards (FRs)
- **FR-1**: On app launch, if the user is not authenticated, they MUST be redirected to either `/onboarding` (first launch) or `/login`.
- **FR-2**: Deep links to any internal page (e.g., `/matajir/cart`) MUST trigger a redirect to `/login` if no valid session exists.
- **FR-3**: Guest browsing mode is explicitly disabled in the `AuthStatus` and `AuthBloc`.

### 2.2 User Roles & Types
- **FR-4**: The system MUST support at least three user roles:
  - `user` (Default Consumer)
  - `merchant` (Store Manager)
  - `auctioneer` (Auction Creator)
- **FR-5**: New users MUST select their primary role during the registration step.

### 2.3 The Authentication Flow (UX)
1. **Onboarding**: 3-slide introduction with a "Get Started" button leading to Login.
2. **Login (Step 1)**: Phone number input with Iraqi country code (+964) prefix.
3. **Verify OTP (Step 2)**: 6-digit code entry with auto-focus and 30s resend timer.
4. **Registration (Step 3 - New Users Only)**: 
   - Full Name input.
   - User Role Selection (Visual cards: "Looking to Buy" / "Looking to Sell / Shop" / "Auctioneer").
5. **App Entrance**: Redirect to the Home Portal (`/`) upon success.

---

## 3. Technical Constraints & Architecture

- **Routing**: Use `go_router`'s `redirect` property for global auth guarding (Constitution Principle III).
- **State Management**: Use `AuthBloc` to manage complex event-driven flow (Constitution Principle II).
- **UI System**: All components MUST use `AppTheme` and `Cairo` typography (Constitution Principle VII).
- **Layering**: Auth logic must be isolated in `lib/features/auth/` with clear Data/Domain/Presentation separation (Constitution Principle I).

---

## 4. Acceptance Criteria
- [ ] Unauthenticated users cannot view the `HomePage`.
- [ ] Users can register with a specific role.
- [ ] OTP flow works via real API integration (per Lugta API v1).
- [ ] UI is fully RTL and localized in Arabic.
- [ ] "Lazy Auth" code is removed or disabled.
