# Implementation Plan

## General Architecture
- Implement Activity and Wallet redesign over `lib/features/notifications/presentation/pages/activity_page.dart`.
- Fetch layouts for missing Stitch screens and convert them into Flutter widgets.

## Technical Context
- `flutter_bloc`
- `go_router` for deep linking and navigating.
- Clean Code, matching `AppTheme` colors, text styles.

## Phases
1. Redesign "النشاطات والمحفظة" (Activity & Wallet) using Stitch styles. Update `activity_page.dart`.
2. Implement Matajir Product Details & Checkout flow. Add add-to-cart mechanism connecting to `BallaCartCubit` / `GenericCartCubit`.
3. Implement Balla Bulk Shopping Cart & Product details.
4. Implement Mustamal Real-time Bidding & Auction Win flows.
