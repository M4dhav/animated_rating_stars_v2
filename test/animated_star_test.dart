import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  /// Pumps a single [AnimatedStar] inside a minimal material app.
  Future<void> pumpStar(
    WidgetTester tester, {
    bool filled = false,
    bool halfFilled = false,
    Color filledColor = Colors.amber,
    Color? halfFilledColor,
    Color emptyColor = Colors.grey,
    double starSize = 30.0,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedStar(
            filled: filled,
            halfFilled: halfFilled,
            filledColor: filledColor,
            halfFilledColor: halfFilledColor,
            emptyColor: emptyColor,
            filledIcon: kFilled,
            halfFilledIcon: kHalfFilled,
            emptyIcon: kEmpty,
            starSize: starSize,
            animationDuration: animationDuration,
          ),
        ),
      ),
    );
  }

  Icon theIcon(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon));

  group('icon selection', () {
    testWidgets('shows the empty icon when neither flag is set',
        (tester) async {
      await pumpStar(tester);
      await tester.pumpAndSettle();
      expect(theIcon(tester).icon, kEmpty);
    });

    testWidgets('shows the filled icon when filled', (tester) async {
      await pumpStar(tester, filled: true);
      await tester.pumpAndSettle();
      expect(theIcon(tester).icon, kFilled);
    });

    testWidgets('shows the half-filled icon when half filled', (tester) async {
      await pumpStar(tester, halfFilled: true);
      await tester.pumpAndSettle();
      expect(theIcon(tester).icon, kHalfFilled);
    });

    testWidgets('prefers filled over halfFilled when both are set',
        (tester) async {
      await pumpStar(tester, filled: true, halfFilled: true);
      await tester.pumpAndSettle();
      expect(theIcon(tester).icon, kFilled);
    });
  });

  group('animation', () {
    testWidgets('an empty star sits at its resting size and colour',
        (tester) async {
      await pumpStar(tester, starSize: 20.0, emptyColor: kEmptyColor);
      await tester.pumpAndSettle();

      expect(theIcon(tester).size, 20.0);
      expect(theIcon(tester).color, kEmptyColor);
    });

    testWidgets('a star built filled animates to its grown size',
        (tester) async {
      await pumpStar(tester, filled: true, starSize: 20.0);

      // The animation runs from the first frame, so the star starts small.
      await tester.pump();
      expect(theIcon(tester).size, lessThan(28.0));

      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 28.0);
    });

    testWidgets('a star built filled animates to filledColor', (tester) async {
      await pumpStar(
        tester,
        filled: true,
        emptyColor: kEmptyColor,
        filledColor: kFilledColor,
      );

      await tester.pumpAndSettle();
      expect(theIcon(tester).color, kFilledColor);
    });

    testWidgets('passes through intermediate sizes while animating',
        (tester) async {
      await pumpStar(
        tester,
        filled: true,
        starSize: 20.0,
        animationDuration: const Duration(milliseconds: 300),
      );

      await tester.pump(const Duration(milliseconds: 150));
      final midSize = theIcon(tester).size!;

      expect(midSize, greaterThan(20.0));
      expect(midSize, lessThan(28.0));

      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 28.0);
    });

    testWidgets('animates forward when it becomes filled', (tester) async {
      await pumpStar(tester, starSize: 20.0);
      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 20.0);

      await pumpStar(tester, filled: true, starSize: 20.0);
      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 28.0);
    });

    testWidgets('animates back when it becomes empty again', (tester) async {
      await pumpStar(tester, filled: true, starSize: 20.0);
      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 28.0);

      await pumpStar(tester, starSize: 20.0);
      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 20.0);
    });

    testWidgets('a half star animates to halfFilledColor', (tester) async {
      await pumpStar(
        tester,
        halfFilled: true,
        emptyColor: kEmptyColor,
        filledColor: kFilledColor,
        halfFilledColor: kHalfFilledColor,
      );

      await tester.pumpAndSettle();
      expect(theIcon(tester).color, kHalfFilledColor);
    });

    testWidgets('a half star falls back to filledColor when none is given',
        (tester) async {
      await pumpStar(
        tester,
        halfFilled: true,
        emptyColor: kEmptyColor,
        filledColor: kFilledColor,
      );

      await tester.pumpAndSettle();
      expect(theIcon(tester).color, kFilledColor);
    });

    testWidgets('halfFilledColor does not affect a filled star',
        (tester) async {
      await pumpStar(
        tester,
        filled: true,
        emptyColor: kEmptyColor,
        filledColor: kFilledColor,
        halfFilledColor: kHalfFilledColor,
      );

      await tester.pumpAndSettle();
      expect(theIcon(tester).color, kFilledColor);
    });

    testWidgets('honours a custom animation duration', (tester) async {
      await pumpStar(
        tester,
        filled: true,
        starSize: 20.0,
        animationDuration: const Duration(seconds: 2),
      );

      // Well past a 300ms default, but far from done at two seconds.
      await tester.pump(const Duration(milliseconds: 400));
      expect(theIcon(tester).size, lessThan(28.0));

      await tester.pumpAndSettle();
      expect(theIcon(tester).size, 28.0);
    });
  });

  group('lifecycle', () {
    testWidgets('disposes its controller without error', (tester) async {
      await pumpStar(tester, filled: true);
      await tester.pump(const Duration(milliseconds: 50));

      // Tear down mid-animation: a leaked ticker would be reported here.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedStar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
