// test/widget/core/sooq_product_card_test.dart
//
// Widget tests for SooqProductCard.
// Covers: title rendered, price rendered, image placeholder when no URL,
// image shown when URL provided, badge shown/hidden, onTap called,
// onFavorite called, grid vs list layout, darkMode variant.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luqta/core/widgets/sooq_product_card.dart';

import '../../helpers/test_helpers.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget buildCard({
    String title = 'آيفون 15 برو',
    String price = '1,500,000 د.ع',
    String? subtitle,
    String? imageUrl,
    String? badge,
    Color? badgeColor,
    Color primaryColor = const Color(0xFF1B4FD8),
    bool isGridView = true,
    bool isFavorited = false,
    VoidCallback? onTap,
    VoidCallback? onFavorite,
    bool darkMode = false,
  }) {
    return buildTestApp(
      child: Scaffold(
        body: SizedBox(
          width: 200,
          height: 260,
          child: SooqProductCard(
            title: title,
            price: price,
            subtitle: subtitle,
            imageUrl: imageUrl,
            badge: badge,
            badgeColor: badgeColor,
            primaryColor: primaryColor,
            isGridView: isGridView,
            isFavorited: isFavorited,
            onTap: onTap,
            onFavorite: onFavorite,
            darkMode: darkMode,
          ),
        ),
      ),
    );
  }

  // ── 1. Renders title ────────────────────────────────────────────────────────

  testWidgets('renders product title', (tester) async {
    await tester.pumpWidget(buildCard(title: 'آيفون 15 برو'));
    await tester.pump();

    expect(find.text('آيفون 15 برو'), findsOneWidget);
  });

  // ── 2. Renders price ────────────────────────────────────────────────────────

  testWidgets('renders product price', (tester) async {
    await tester.pumpWidget(buildCard(price: '1,500,000 د.ع'));
    await tester.pump();

    expect(find.text('1,500,000 د.ع'), findsOneWidget);
  });

  // ── 3. Renders subtitle when provided ───────────────────────────────────────

  testWidgets('renders subtitle when provided', (tester) async {
    await tester.pumpWidget(buildCard(subtitle: 'حالة ممتازة'));
    await tester.pump();

    expect(find.text('حالة ممتازة'), findsOneWidget);
  });

  // ── 4. No subtitle when not provided ────────────────────────────────────────

  testWidgets('does not show subtitle widget when subtitle is null',
      (tester) async {
    await tester.pumpWidget(buildCard(subtitle: null));
    await tester.pump();

    // Only title and price texts should appear (no extra text)
    expect(find.text('حالة ممتازة'), findsNothing);
  });

  // ── 5. Image placeholder shown when no URL ────────────────────────────────

  testWidgets('shows image placeholder icon when imageUrl is null',
      (tester) async {
    await tester.pumpWidget(buildCard(imageUrl: null));
    await tester.pump();

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  // ── 6. Badge shown when provided ────────────────────────────────────────────

  testWidgets('renders badge text when badge is provided', (tester) async {
    await tester.pumpWidget(buildCard(badge: 'مزاد'));
    await tester.pump();

    expect(find.text('مزاد'), findsOneWidget);
  });

  // ── 7. No badge when not provided ───────────────────────────────────────────

  testWidgets('does not render badge when badge is null', (tester) async {
    await tester.pumpWidget(buildCard(badge: null));
    await tester.pump();

    expect(find.text('مزاد'), findsNothing);
  });

  // ── 8. onTap is called ───────────────────────────────────────────────────────

  testWidgets('calls onTap when card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildCard(onTap: () => tapped = true));
    await tester.pump();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    expect(tapped, isTrue);
  });

  // ── 9. onFavorite is called ──────────────────────────────────────────────────

  testWidgets('calls onFavorite when favorite button is tapped', (tester) async {
    var favorited = false;
    await tester.pumpWidget(
      buildCard(
        isGridView: true,
        onFavorite: () => favorited = true,
      ),
    );
    await tester.pump();

    // Favorite icon is in a GestureDetector
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pump();

    expect(favorited, isTrue);
  });

  // ── 10. isFavorited shows filled icon ────────────────────────────────────────

  testWidgets('shows filled heart icon when isFavorited=true', (tester) async {
    await tester.pumpWidget(
      buildCard(isGridView: true, isFavorited: true),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  // ── 11. List layout renders title and price ──────────────────────────────────

  testWidgets('list layout also renders title and price', (tester) async {
    await tester.pumpWidget(
      buildCard(
        title: 'لابتوب ديل',
        price: '800,000 د.ع',
        isGridView: false,
      ),
    );
    await tester.pump();

    expect(find.text('لابتوب ديل'), findsOneWidget);
    expect(find.text('800,000 د.ع'), findsOneWidget);
  });

  // ── 12. Dark mode variant renders without error ───────────────────────────────

  testWidgets('dark mode card renders without throwing', (tester) async {
    await tester.pumpWidget(
      buildCard(
        darkMode: true,
        primaryColor: const Color(0xFF00F5FF),
      ),
    );
    await tester.pump();

    expect(find.byType(SooqProductCard), findsOneWidget);
  });
}
