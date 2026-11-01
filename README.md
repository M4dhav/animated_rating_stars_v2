# Animated Rating Stars for Flutter

[![Package Version](https://img.shields.io/pub/v/animated_rating_stars_v2.svg)](https://pub.dev/packages/animated_rating_stars_v2/versions)
[![Package Downloads](https://img.shields.io/pub/dt/animated_rating_stars_v2.svg)](https://pub.dev/packages/animated_rating_stars_v2)
[![GitHub Stars](https://img.shields.io/github/stars/M4dhav/animated_rating_stars_v2.svg?style=social)](https://github.com/M4dhav/animated_rating_stars_v2/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/M4dhav/animated_rating_stars_v2.svg?style=social)](https://github.com/M4dhav/animated_rating_stars_v2/forks)
[![License](https://img.shields.io/github/license/M4dhav/animated_rating_stars_v2.svg)](https://pub.dev/packages/animated_rating_stars_v2/license)




`AnimatedRatingStars` is a highly customizable animated rating bar widget for Flutter. It allows users to interactively provide ratings by tapping on stars. The package offers a wide range of customization options and is designed to be easy to integrate into your Flutter applications.

## Demo
![DEMO1](android.gif)
![DEMO2](chrome.gif)
![DEMO3](macdesk.gif)

## Features

- Create animated rating bars with filled, half-filled, and empty stars.
- Customize star colors, icons, sizes, and animation parameters.
- Display the rating value and enable interactive tooltips for half-filled stars.
- Supports both read-only and interactive modes.

## Installation

To use this package, add `animated_rating_stars_v2` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  animated_rating_stars_v2: ^1.0.0
```

Then, run flutter pub get to fetch the package.

## Usage

Import the package in your Dart code:

```dart
import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
```

Now, you can use the AnimatedRatingStars widget in your Flutter app:

```dart
AnimatedRatingStars(
  initialRating: 3.5,
  minRating: 0.5,
  maxRating: 5.0,
  filledColor: Colors.amber,
  halfFilledColor: Colors.orangeAccent,
  emptyColor: Colors.grey,
  filledIcon: Icons.star,
  halfFilledIcon: Icons.star_half,
  emptyIcon: Icons.star_border,
  onChanged: (double rating) {
    // Handle the rating change here
    print('Rating: $rating');
  },
  displayRatingValue: true,
  ratingValueStyle: const TextStyle(fontSize: 18.0, color: Colors.amber),
  interactiveTooltips: true,
  starSize: 30.0,
  animationDuration: Duration(milliseconds: 300),
  animationCurve: Curves.easeInOut,
  readOnly: false,
)
```

Customize the properties according to your requirements. The onChanged callback is called when the rating changes.

For more <a href="https://pub.dev/packages/animated_rating_stars/example">examples</a> and usage details, refer to the <a href="https://pub.dev/packages/animated_rating_stars/example">examples</a> directory included with this package.
animated_rating_stars_v2animated_rating_stars_v2
## Customization

You can customize the appearance and behavior of the rating bar using the following properties:

- `initialRating`: The rating shown when the widget is first built, clamped into the `minRating`–`maxRating` range.
- `minRating`: The lowest rating the user can select. Taps that would land below it are raised to it.
- `maxRating`: The highest rating, and the number of stars drawn — one per whole unit.
- `filledColor`: The color for filled stars.
- `halfFilledColor`: The color for half-filled stars. Defaults to `filledColor`.
- `emptyColor`: The color for empty stars.
- `filledIcon`: The icon used for filled stars.
- `halfFilledIcon`: The icon used for half-filled stars.
- `emptyIcon`: The icon used for empty stars.
- `displayRatingValue`: Draw the current rating as text beside the stars.
- `ratingValueStyle`: The text style for that value. Defaults to the surrounding style, sized against `starSize` and tinted with `filledColor`.
- `interactiveTooltips`: Enable half stars, and let a tap on the already-selected star drop it to a half star.
- `starSize`: Set the size of each star.
- `animationDuration`: Adjust the duration of the animation when the rating changes.
- `animationCurve`: Define the animation curve for the rating change.
- `readOnly`: Make the widget read-only.

## Contributing

Contributions and feedback are welcome! If you encounter any issues or have feature requests, please open an <a href="https://github.com/M4dhav/animated_rating_stars/issues">issue</a> on <a href="https://github.com/M4dhav">GitHub</a>.

## Licenseanimated_rating_stars_v2

This package is distributed under the <a href="https://opensource.org/license/mit/">MIT License</a>. See <a href="https://pub.dev/packages/animated_rating_stars/license">LICENSE</a> for details.

For more Flutter packages and development resources, visit <a href="https://pub.dev/">pub.dev</a>.animated_rating_stars_v2
