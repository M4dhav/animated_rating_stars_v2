// Widget tests for the example app.
//
// These cover the wiring between the demo app and the rating widget: that the
// app renders a rating bar, and that tapping a star updates the label the app
// draws above it.

import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animated_rating_stars_example/main.dart';

void main() {
  testWidgets('shows a rating bar and its current value', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedRatingStars), findsOneWidget);
    expect(find.byType(AnimatedStar), findsNWidgets(5));
    expect(find.text('Rating: 2.5'), findsOneWidget);
  });

  testWidgets('updates the label when a star is tapped', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AnimatedStar).at(3));
    await tester.pumpAndSettle();

    expect(find.text('Rating: 4.0'), findsOneWidget);
    expect(find.text('Rating: 2.5'), findsNothing);
  });

  testWidgets('toggles a half star when the same star is tapped twice',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The example enables interactiveTooltips, so a second tap halves it.
    await tester.tap(find.byType(AnimatedStar).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Rating: 4.0'), findsOneWidget);

    await tester.tap(find.byType(AnimatedStar).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Rating: 3.5'), findsOneWidget);
  });
}
