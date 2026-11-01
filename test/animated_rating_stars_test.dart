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
const Color kHalfFilledColor = Color(0xFF00FF00);

void main() {
  /// Pumps an [AnimatedRatingStars] inside a minimal material app.
  ///
  /// Ratings reported through `onChanged` are appended to the returned list,
  /// so a test can assert on the whole sequence of callbacks.
  Future<List<double>> pumpStars(
    WidgetTester tester, {
    double initialRating = 0.0,
    double minRating = 0.0,
    double maxRating = 5.0,
    bool interactiveTooltips = false,
    bool readOnly = false,
    bool displayRatingValue = true,
    TextStyle? ratingValueStyle,
    Color filledColor = Colors.amber,
    Color? halfFilledColor,
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
            minRating: minRating,
            maxRating: maxRating,
            interactiveTooltips: interactiveTooltips,
            readOnly: readOnly,
            displayRatingValue: displayRatingValue,
            ratingValueStyle: ratingValueStyle,
            filledColor: filledColor,
            halfFilledColor: halfFilledColor,
            emptyColor: emptyColor,
            starSize: starSize,
            animationDuration: animationDuration,
            filledIcon: kFilled,
            halfFilledIcon: kHalfFilled,
            emptyIcon: kEmpty,
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

    testWidgets('uses the icons it was given rather than the defaults',
        (tester) async {
      await pumpStars(tester, initialRating: 1.0);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
      expect(find.byIcon(kFilled), findsNWidgets(1));
    });

    testWidgets('falls back to star icons when none are given', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedRatingStars(initialRating: 1.0, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border), findsNWidgets(4));
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

  group('minRating', () {
    testWidgets('raises an initial rating that sits below it', (tester) async {
      await pumpStars(tester, initialRating: 0.0, minRating: 2.0);
      await tester.pumpAndSettle();

      expect(find.byIcon(kFilled), findsNWidgets(2));
      expect(find.text('2.0'), findsOneWidget);
    });

    testWidgets('raises a tap that lands below it', (tester) async {
      final changes = await pumpStars(tester, minRating: 3.0);

      await tester.tap(find.byType(AnimatedStar).at(0));
      await tester.pumpAndSettle();

      // The tap asked for 1.0; the floor reports 3.0 instead.
      expect(changes, <double>[3.0]);
      expect(find.byIcon(kFilled), findsNWidgets(3));
    });

    testWidgets('stops the half-star toggle from dropping below it',
        (tester) async {
      final changes = await pumpStars(
        tester,
        initialRating: 3.0,
        minRating: 3.0,
        interactiveTooltips: true,
      );

      // Would toggle down to 2.5, but the floor holds it at 3.0.
      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[3.0]);
      expect(iconAt(tester, 2).icon, kFilled);
    });

    testWidgets('allows a half-star toggle that stays above it',
        (tester) async {
      final changes = await pumpStars(
        tester,
        initialRating: 3.0,
        minRating: 2.0,
        interactiveTooltips: true,
      );

      await tester.tap(find.byType(AnimatedStar).at(2));
      await tester.pumpAndSettle();

      expect(changes, <double>[2.5]);
      expect(iconAt(tester, 2).icon, kHalfFilled);
    });

    testWidgets('a zero floor leaves taps untouched', (tester) async {
      final changes = await pumpStars(tester, minRating: 0.0);

      await tester.tap(find.byType(AnimatedStar).at(0));
      await tester.pumpAndSettle();

      expect(changes, <double>[1.0]);
    });

    testWidgets('re-clamps the current rating when the floor rises',
        (tester) async {
      await pumpStars(tester, minRating: 0.0);
      await tester.tap(find.byType(AnimatedStar).at(0));
      await tester.pumpAndSettle();
      expect(find.byIcon(kFilled), findsNWidgets(1));

      // Same widget position, so the state is kept and updated in place.
      await pumpStars(tester, minRating: 4.0);
      await tester.pumpAndSettle();
      expect(find.byIcon(kFilled), findsNWidgets(4));
    });

    testWidgets('re-clamps the current rating when the ceiling drops',
        (tester) async {
      await pumpStars(tester, maxRating: 5.0);
      await tester.tap(find.byType(AnimatedStar).at(4));
      await tester.pumpAndSettle();
      expect(find.byIcon(kFilled), findsNWidgets(5));

      await pumpStars(tester, maxRating: 3.0);
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedStar), findsNWidgets(3));
      expect(find.byIcon(kFilled), findsNWidgets(3));
    });
  });

  group('displayRatingValue', () {
    testWidgets('draws the current rating when set', (tester) async {
      await pumpStars(tester, initialRating: 3.0, displayRatingValue: true);
      await tester.pumpAndSettle();
      expect(find.text('3.0'), findsOneWidget);
    });

    testWidgets('draws nothing when unset', (tester) async {
      await pumpStars(tester, initialRating: 3.0, displayRatingValue: false);
      await tester.pumpAndSettle();
      expect(find.text('3.0'), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('follows the rating as it changes', (tester) async {
      await pumpStars(tester, initialRating: 1.0);
      await tester.pumpAndSettle();
      expect(find.text('1.0'), findsOneWidget);

      await tester.tap(find.byType(AnimatedStar).at(3));
      await tester.pumpAndSettle();

      expect(find.text('4.0'), findsOneWidget);
      expect(find.text('1.0'), findsNothing);
    });

    testWidgets('shows a half rating to one decimal place', (tester) async {
      await pumpStars(tester, initialRating: 2.5, interactiveTooltips: true);
      await tester.pumpAndSettle();
      expect(find.text('2.5'), findsOneWidget);
    });

    testWidgets('tints the value with filledColor by default', (tester) async {
      await pumpStars(tester, initialRating: 3.0, filledColor: kFilledColor);
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.text('3.0')).style?.color, kFilledColor);
    });

    testWidgets('uses ratingValueStyle when one is given', (tester) async {
      await pumpStars(
        tester,
        initialRating: 3.0,
        filledColor: kFilledColor,
        ratingValueStyle: const TextStyle(
          fontSize: 11.0,
          color: kHalfFilledColor,
          fontWeight: FontWeight.bold,
        ),
      );
      await tester.pumpAndSettle();

      final style = tester.widget<Text>(find.text('3.0')).style;
      expect(style?.fontSize, 11.0);
      expect(style?.color, kHalfFilledColor);
      expect(style?.fontWeight, FontWeight.bold);
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

  group('colors', () {
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

    testWidgets('paints the half star with halfFilledColor', (tester) async {
      await pumpStars(
        tester,
        initialRating: 2.5,
        interactiveTooltips: true,
        filledColor: kFilledColor,
        halfFilledColor: kHalfFilledColor,
        emptyColor: kEmptyColor,
      );
      await tester.pumpAndSettle();

      expect(iconAt(tester, 1).color, kFilledColor);
      expect(iconAt(tester, 2).color, kHalfFilledColor);
      expect(iconAt(tester, 3).color, kEmptyColor);
    });

    testWidgets('falls back to filledColor when halfFilledColor is absent',
        (tester) async {
      await pumpStars(
        tester,
        initialRating: 2.5,
        interactiveTooltips: true,
        filledColor: kFilledColor,
        emptyColor: kEmptyColor,
      );
      await tester.pumpAndSettle();

      expect(iconAt(tester, 2).color, kFilledColor);
    });

    testWidgets('keeps all three colors independent', (tester) async {
      await pumpStars(
        tester,
        initialRating: 1.5,
        interactiveTooltips: true,
        filledColor: kFilledColor,
        halfFilledColor: kHalfFilledColor,
        emptyColor: kEmptyColor,
      );
      await tester.pumpAndSettle();

      expect(iconAt(tester, 0).color, kFilledColor);
      expect(iconAt(tester, 1).color, kHalfFilledColor);
      expect(iconAt(tester, 2).color, kEmptyColor);
      expect(iconAt(tester, 3).color, kEmptyColor);
      expect(iconAt(tester, 4).color, kEmptyColor);
    });
  });

  group('sizing', () {
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
