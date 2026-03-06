# Feature Specification: Super App Portal Home Screen & Mini-App Cart Isolation

**Branch**: `1-home-portal-cart-isolation`
**Created**: 2026-03-06
**Status**: Draft — Ready for Planning

---

## 1. Overview

### Problem Statement
The application is a super-app shell that hosts four distinct Mini-Apps: **Mazad** (Auctions), **Mustamal** (Used C2C), **Matajir** (Retail), and **Balla** (Bulk). Currently, there is no unified entry point to help users discover and navigate these Mini-Apps. Additionally, the global cart state is shared across all Mini-Apps, which risks users inadvertently mixing items from incompatible commerce contexts (e.g., Retail and Bulk) in the same checkout flow.

### Goal
1. Deliver a **central Home Screen** (Super App Portal) that serves as the user's primary navigation hub across all four Mini-Apps.
2. **Isolate cart state** per Mini-App so that a user can never mix items from different commerce contexts in a single checkout session.

### Actors
- **Authenticated User** – any logged-in user browsing or shopping across Mini-Apps.
- **Guest User** – unauthenticated visitor browsing content (cart interactions require login).

---

## 2. User Scenarios & Acceptance Tests

### Scenario 1 – Discovering Mini-Apps from the Home Screen
**Given** a user opens the app,
**When** they land on the Home Screen,
**Then** they see a grid of four clearly labelled cards (Mazad, Mustamal, Matajir, Balla) and can tap any card to enter the corresponding Mini-App.

**Acceptance**:
- All four Mini-App entry cards are visible on a single scroll without needing to swipe horizontally.
- Tapping each card navigates the user into the correct Mini-App context.

### Scenario 2 – Viewing Announcements
**Given** a user is on the Home Screen,
**When** the screen loads,
**Then** a horizontally-scrollable announcements carousel is displayed at the top with promotional content.

**Acceptance**:
- The carousel auto-advances and is touch-scrollable.
- Content is globally scoped (not Mini-App specific).

### Scenario 3 – Discovering Curated Content
**Given** a user is on the Home Screen,
**When** they scroll below the Bento Grid,
**Then** they see at least two horizontal scrolling lists: "Trending Auctions" (Mazad content) and "New Retail" (Matajir content), each showing item cards linking to the relevant Mini-App.

**Acceptance**:
- Lists display a minimum of 3 items each.
- Tapping an item navigates to the item detail page within the correct Mini-App.

### Scenario 4 – Escrow Wallet Balance Visibility
**Given** an authenticated user is on the Home Screen,
**When** the screen loads,
**Then** the app bar prominently shows the user's current Escrow Wallet balance.

**Acceptance**:
- Balance is currency-formatted and reflects the user's real balance.
- Unauthenticated users see a prompt to log in instead of a balance.

### Scenario 5 – Omnibox Search
**Given** a user is on the Home Screen,
**When** they tap the search bar (Omnibox),
**Then** they can enter a query and receive results spanning all four Mini-Apps.

**Acceptance**:
- Search results are labelled by their source Mini-App.
- Tapping a result navigates to the correct Mini-App item detail.

### Scenario 6 – Adding to a Mini-App Cart (Happy Path)
**Given** a user is browsing the Matajir (Retail) Mini-App,
**When** they add an item to their cart,
**Then** the item is added to the **Matajir cart only**, tagged with `appContext: 'matajir'`.

**Acceptance**:
- The Matajir cart badge increments.
- No other Mini-App cart is affected.
- The item's cart record includes the `appContext` tag.

### Scenario 7 – Cart Isolation Enforcement
**Given** a user already has items in their Matajir (Retail) cart,
**When** they attempt to add an item from the Balla (Bulk) Mini-App,
**Then** the system informs the user that they cannot mix Retail and Bulk items and offers to either keep the existing cart or clear it and start fresh.

**Acceptance**:
- A clear, user-friendly message is shown explaining the restriction.
- The user can choose to keep their existing Matajir cart (cancel the Balla addition) or clear it and add the Balla item.
- No silent merging of items across cart contexts occurs.

### Scenario 8 – Independent Checkout Flows
**Given** a user has items only in their Matajir cart,
**When** they proceed to checkout,
**Then** only the Matajir checkout flow is triggered, and the backend receives the `appContext: 'matajir'` tag to process the order under the correct commerce pipeline.

**Acceptance**:
- The checkout API payload contains `appContext: 'matajir'`.
- Mazad and Balla checkout flows are unaffected and unmodified.

---

## 3. Functional Requirements

### FR-01: Home Screen – App Bar
- The Home Screen app bar must display the authenticated user's Escrow Wallet balance.
- The app bar must contain a persistent global search input (Omnibox).
- For guest users, the wallet area must show a login prompt.

### FR-02: Home Screen – Announcements Carousel
- A carousel of promotional banners must appear at the top of the scrollable screen body.
- The carousel must auto-advance on a timer and be manually swipeable.
- Carousel data is fetched from a global announcements feed (not Mini-App specific).

### FR-03: Home Screen – Bento Grid (Mini-App Entry Points)
- A grid of exactly four cards must serve as entry points to Mazad, Mustamal, Matajir, and Balla.
- Each card must show the Mini-App name, a representative icon/image, and a short tagline.
- Tapping a card navigates the user to the respective Mini-App's primary screen.

### FR-04: Home Screen – Curated Horizontal Lists
- At least two curated horizontal-scroll lists must appear below the Bento Grid.
- List 1: "Trending Auctions" — powered by live Mazad data.
- List 2: "New Retail" — powered by new Matajir listings.
- Each list must be independently scrollable.
- Item cards link to the corresponding Mini-App detail page.

### FR-05: Cart Scoping – Per-Mini-App Cart State
- Cart state must be split into independent, isolated units per commerce-capable Mini-App (Matajir and Balla).
- Mazad and Mustamal do not have shopping carts (Mazad uses bidding; Mustamal uses direct negotiation).
- Each scoped cart manages its own item list, total, and badge count independently.

### FR-06: Cart Scoping – appContext Tagging
- Every item added to any cart must be tagged with a strict `appContext` identifier ('matajir' or 'balla').
- This tag must be preserved through the entire lifecycle: cart state → checkout API request.

### FR-07: Cart Scoping – Cross-Context Conflict Resolution
- Attempting to add an item with a different `appContext` than the currently populated cart must trigger a conflict resolution flow.
- The conflict resolution UI must offer the user two explicit choices: retain the existing cart (cancel the new item) or clear the existing cart and add the new item.
- Silent merging of cross-context items is strictly prohibited.

### FR-08: Checkout API – appContext Propagation
- The checkout API request payload must include the `appContext` field for every order originating from a cart.
- The backend must process orders through the pipeline corresponding to the submitted `appContext`.

---

## 4. Non-Functional Requirements

- **Performance**: The Home Screen must reach a visually complete state (above-the-fold content rendered) within 2 seconds on a standard mobile connection.
- **Reliability**: Cart state must survive app backgrounding and foreground restoration without data loss.
- **Consistency**: The cart conflict resolution flow must behave identically regardless of which Mini-App the user is currently in.
- **Accessibility**: All interactive elements (carousel controls, Bento Grid cards, search bar) must have sufficient contrast ratios and touch target sizes.

---

## 5. Out of Scope

- Cart isolation for Mazad (Auctions) and Mustamal (Used C2C) — these Mini-Apps do not have traditional shopping carts.
- Omnibox search result ranking or advanced search features.
- Personalisation of the announcements carousel or curated lists (content is global/static for this feature).
- Push notifications for cart items or promotions.
- Guest checkout flows.

---

## 6. Key Entities

| Entity | Description |
|---|---|
| `MiniApp` | Enumerated type: `mazad`, `mustamal`, `matajir`, `balla` |
| `CartItem` | A product line item belonging to a specific `appContext` |
| `AppContext` | Strict identifier attached to every cart item: `'matajir'` or `'balla'` |
| `ScopedCart` | An isolated cart state managed per `appContext` |
| `Announcement` | A promotional banner entry for the global announcements carousel |
| `EscrowWallet` | User's in-app wallet showing a spendable balance |
| `CuratedList` | A named, ordered list of items from a specific Mini-App feed |

---

## 7. Assumptions

1. **Mazad and Mustamal** do not require cart isolation because they use non-cart commerce models (bidding and direct negotiation, respectively). Only Matajir and Balla need scoped carts.
2. **Omnibox search** calls a unified backend search endpoint that aggregates results across Mini-Apps; the design of that endpoint is out of scope for this feature.
3. **Announcements carousel** content is served by an existing or new global content endpoint; content authoring/CMS is out of scope.
4. **Escrow Wallet balance** is already available from an authenticated session or existing API; no new wallet API needs to be built as part of this feature.
5. The four **Bento Grid cards** use static or remotely-configurable assets (icons/images); dynamic card ordering or A/B testing is out of scope.
6. **Cart persistence** across app restarts relies on existing local storage mechanisms; no new persistence layer is introduced.
7. The backend already supports or will be updated (in parallel) to accept and route by `appContext`; the frontend feature does not block on backend readiness for initial development.

---

## 8. Dependencies

- Backend BFF endpoint for the Home Screen feed (announcements, curated lists, wallet balance).
- Backend search endpoint for Omnibox multi-Mini-App queries.
- Backend cart & checkout API accepting `appContext` field.
- Existing `CartCubit` (or equivalent) as the starting point for refactoring into scoped carts.
- Design assets for the four Bento Grid cards and Home Screen branding.

---

## 9. Success Criteria

| # | Criterion | Measure |
|---|---|---|
| SC-01 | Users can navigate to any Mini-App from the Home Screen | 100% of Mini-App entry cards are reachable and functional |
| SC-02 | The Home Screen loads above-the-fold content quickly | Visually complete in ≤ 2 seconds on standard mobile conditions |
| SC-03 | Cart isolation prevents cross-context mixing | 0 checkout orders contain items from more than one `appContext` |
| SC-04 | Users understand the cart conflict and can resolve it without confusion | Conflict resolution task completion rate ≥ 90% in user testing |
| SC-05 | Curated content drives Mini-App discovery | Tap-through rate on curated list items ≥ 15% (baseline metric) |
| SC-06 | Escrow Wallet balance is always accurate on the Home Screen | Balance displayed matches account record with ≤ 1 second staleness after an update |
| SC-07 | No existing Mini-App checkout flow is broken by the cart refactor | 0 regressions in Matajir and Balla checkout end-to-end tests |
