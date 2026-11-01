import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Icons that are easy to tell apart from the widget defaults, so a test that
/// asserts on them cannot pass by accident.
const IconData kFilled = Icons.favorite;
const IconData kHalfFilled = Icons.heart_broken;
const IconData kEmpty = Icons.favorite_border;

/// Plain colours rather than the `Colors.*` swatches: the widget blends with
/// [Color.lerp], which yields a plain [Color], so a `MaterialColor` would
/// compare unequal on type even when every channel matches.
const Color kEmptyColor = Color(0xFF0000FF);
const Color kFilledColor = Color(0xFFFF0000);

void main() {
  /// Pumps an [AnimatedRatingStars] inside a minimal material app.
  ///
  /// Ratings reported through `onChanged` are appended to the returned list,
  /// so a test can assert on the whole sequence of callbacks.
  Future<List<double>> pumpStars(
    WidgetTester tester, {
    double initialRating = 0.0,
    double maxRating = 5.0,
    bool interactiveTooltips = false,
    bool readOnly = false,
    Color filledColor = Colors.amber,
    Color emptyColor = Colors.grey,
    double starSize = 30.0,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) async {
    final changes = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedRatingStars(
            initialRating: initialRating,
            maxRating: maxRating,
            interactiveTooltips: interactiveTooltips,
            readOnly: readOnly,
            filledColor: filledColor,
            emptyColor: emptyColor,
            starSize: starSize,
            animationDuration: animationDuration,
            customFilledIcon: kFilled,
            customHalfFilledIcon: kHalfFilled,
            customEmptyIcon: kEmpty,
            onChanged: changes.add,
          ),
        ),
      ),
    );
    return changes;
  }

  /// The [Icon] rendered by the star at [index], counting from the left.
  Icon iconAt(WidgetTester tester, int index) =>
      tester.widget<Icon>(find.byType(Icon).at(index));

  group('rendering', () {
    testWidgets('renders one star per whole unit of maxRating', (tester) async {
      await pumpStars(tester, maxRating: 5.0);
      expect(find.byType(AnimatedStar), findsNWidgets(5));
    });

    testWidgets('honours a non-default maxRating', (tester) async {
      await pumpStars(tester, maxRating: 3.0);
      expect(find.byType(AnimatedStar), findsNWidgets(3));
    });

    testWidgets('truncates a fractional maxRating toward zero', (tester) async {
      await pumpStars(tester, maxRating: 4.9);
      expect(find.byType(AnimatedStar), findsNWidgets(4));
    });

    testWidgets('renders every star empty at a zero initial rating',
        (tester) async {
      await pumpStars(tester);
      await tester.pumpAndSettle();
      expect(find.byIcon(kEmpty), findsNWidgets(5));
      expect(find.byIcon(kFilled), findsNothing);
    });

    testWidgets('fills exactly as many stars as the initial rating',
        (tester) async {
      await pumpStars(tester, initialRating: 3.0);
      await tester.pumpAndSettle();
      expect(find.byIcon(kFilled), findsNWidgets(3));
      expect(find.byIcon(kEmpty), findsNWidgets(2));
    });

    testWidgets('does not report a rating merely for being built',
        (tester) async {
      final changes = await pumpStars(tester, initialRating: 3.0);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('uses the custom icons rather than the star defaults',
        (tester) async {
      await pumpStars(tester, initialRating: 1.0);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
      expect(find.byIcon(kFilled), findsNWidgets(1));
    });
  });

  group('half stars', () {
    testWidgets('shows a half star for a .5 rating when tooltips are on',
        (tester) async {
      await pumpStars(tester, initialRating: 2.5, interactiveTooltips: true);
      await tester.pumpAndSettle();

      expect(find.byIcon(kFilled), findsNWidgets(2));
      expect(find.byIcon(kHalfFilled), findsNWidgets(1));
      expect(find.byIcon(kEmpty), findsNWidgets(2));
      // The half star is the third one.
      expect(iconAt(tester, 2).icon, kHalfFilled);
    });

    testWidgets('renders no half star when tooltips are off', (tester) async {
      await pumpStars(tester, initialRating: 2.5, interactiveTooltips: false);
      await tester.pumpAndSettle();

      expect(find.byIcon(kHalfFilled), findsNothing);
      expect(find.byIcon(kFilled), findsNWidgets(2));
      expect(find.byIcon(kEmpty), findsNWidgets(3));
    });
  });

  group('tapping', () {
    testWidgets('reports the tapped star position as the rating',
        (tester) async {
      final changes = await pumpStars(tester);

      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[3.0]);
    });

    testWidgets('fills the stars up to the tapped one', (tester) async {
      await pumpStars(tester);

      await tester.tap(find.byType(AnimatedStar).at(3));
      await tester.pumpAndSettle();

      expect(find.byIcon(kFilled), findsNWidgets(4));
      expect(find.byIcon(kEmpty), findsNWidgets(1));
    });

    testWidgets('reports the maximum when the last star is tapped',
        (tester) async {
      final changes = await pumpStars(tester, maxRating: 5.0);

      await tester.tap(find.byType(AnimatedStar).at(4));
      await tester.pumpAndSettle();

      expect(changes, <double>[5.0]);
      expect(find.byIcon(kFilled), findsNWidgets(5));
    });

    testWidgets('lowers the rating when an earlier star is tapped',
        (tester) async {
      final changes = await pumpStars(tester, initialRating: 5.0);

      await tester.tap(find.byType(AnimatedStar).at(1));
      await tester.pumpAndSettle();

      expect(changes, <double>[2.0]);
      expect(find.byIcon(kFilled), findsNWidgets(2));
      expect(find.byIcon(kEmpty), findsNWidgets(3));
    });

    testWidgets('reports each tap in a sequence', (tester) async {
      final changes = await pumpStars(tester);

      await tester.tap(find.byType(AnimatedStar).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AnimatedStar).at(4));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[1.0, 5.0, 3.0]);
    });
  });

  group('tapping the star that is already selected', () {
    testWidgets('drops to a half star when tooltips are on', (tester) async {
      final changes = await pumpStars(tester, interactiveTooltips: true);

      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[3.0, 2.5]);
      expect(iconAt(tester, 2).icon, kHalfFilled);
    });

    testWidgets('returns to a whole star on a third tap', (tester) async {
      final changes = await pumpStars(tester, interactiveTooltips: true);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(AnimatedStar).at(2));
        await tester.pumpAndSettle();
      }

      expect(changes, <double>[3.0, 2.5, 3.0]);
      expect(iconAt(tester, 2).icon, kFilled);
    });

    testWidgets('keeps the whole star when tooltips are off', (tester) async {
      final changes = await pumpStars(tester, interactiveTooltips: false);

      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[3.0, 3.0]);
      expect(iconAt(tester, 2).icon, kFilled);
    });
  });

  group('readOnly', () {
    testWidgets('ignores taps', (tester) async {
      final changes = await pumpStars(tester, readOnly: true);

      await tester.tap(find.byType(AnimatedStar).at(3));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });

    testWidgets('still displays the initial rating', (tester) async {
      await pumpStars(tester, initialRating: 4.0, readOnly: true);
      await tester.pumpAndSettle();

      expect(find.byIcon(kFilled), findsNWidgets(4));

      await tester.tap(find.byType(AnimatedStar).at(0));
      await tester.pumpAndSettle();

      // Unchanged by the tap.
      expect(find.byIcon(kFilled), findsNWidgets(4));
    });
  });

  group('styling', () {
    testWidgets('paints empty stars with emptyColor', (tester) async {
      await pumpStars(tester, emptyColor: kEmptyColor);
      await tester.pumpAndSettle();
      expect(iconAt(tester, 0).color, kEmptyColor);
    });

    testWidgets('paints filled stars with filledColor', (tester) async {
      await pumpStars(tester, initialRating: 1.0, filledColor: kFilledColor);
      await tester.pumpAndSettle();
      expect(iconAt(tester, 0).color, kFilledColor);
    });

    testWidgets('renders an empty star at exactly starSize', (tester) async {
      await pumpStars(tester, starSize: 42.0);
      await tester.pumpAndSettle();
      expect(iconAt(tester, 0).size, 42.0);
    });

    testWidgets('grows a filled star above starSize', (tester) async {
      await pumpStars(tester, initialRating: 1.0, starSize: 42.0);
      await tester.pumpAndSettle();
      expect(iconAt(tester, 0).size, greaterThan(42.0));
    });
  });

  group('lifecycle', () {
    testWidgets('keeps the rating the user chose when rebuilt', (tester) async {
      await pumpStars(tester, initialRating: 1.0);
      await tester.tap(find.byType(AnimatedStar).at(3));
      await tester.pumpAndSettle();

      // A rebuild must not discard the choice the user already made.
      await tester.pump();
      expect(find.byIcon(kFilled), findsNWidgets(4));
    });

    testWidgets('disposes without error when removed from the tree',
        (tester) async {
      await pumpStars(tester, initialRating: 3.0);
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedStar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
