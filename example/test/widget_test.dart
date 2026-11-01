// Widget tests for the example app.
//
// These cover the wiring between the demo app and the rating widget: that the
// app renders both bars, and that tapping a star updates the label the app
// draws above them.

import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animated_rating_stars_example/main.dart';

void main() {
  /// The stars belonging to the rating bar at [barIndex].
  Finder starsOf(int barIndex) => find.descendant(
        of: find.byType(AnimatedRatingStars).at(barIndex),
        matching: find.byType(AnimatedStar),
      );

  testWidgets('shows both rating bars and the current value', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedRatingStars), findsNWidgets(2));
    expect(starsOf(0), findsNWidgets(5));
    expect(starsOf(1), findsNWidgets(5));

    // The app's own label, and the value the widget draws for itself.
    expect(find.text('Rating: 2.5'), findsOneWidget);
    expect(find.text('2.5'), findsOneWidget);
  });

  testWidgets('updates the label when a star is tapped', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(starsOf(0).at(3));
    await tester.pumpAndSettle();

    expect(find.text('Rating: 4.0'), findsOneWidget);
    expect(find.text('4.0'), findsOneWidget);
    expect(find.text('Rating: 2.5'), findsNothing);
  });

  testWidgets('toggles a half star when the same star is tapped twice',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The example enables interactiveTooltips, so a second tap halves it.
    await tester.tap(starsOf(0).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Rating: 4.0'), findsOneWidget);

    await tester.tap(starsOf(0).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Rating: 3.5'), findsOneWidget);
  });

  testWidgets('the read-only bar keeps its rating and hides its value',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsNWidgets(4));

    await tester.tap(starsOf(1).at(0));
    await tester.pumpAndSettle();

    // Read-only, so neither the bar nor the app's label moves.
    expect(find.byIcon(Icons.favorite), findsNWidgets(4));
    expect(find.text('Rating: 2.5'), findsOneWidget);
    expect(find.text('4.0'), findsNothing);
  });
}
