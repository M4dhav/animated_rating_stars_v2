## 1.0.0

First release as `animated_rating_stars_v2`: a pure Dart/Flutter widget package
with no platform plugin and no native code.

### Breaking

- Removed `customFilledIcon`, `customHalfFilledIcon` and `customEmptyIcon`.
  These were `required` but duplicated `filledIcon`, `halfFilledIcon` and
  `emptyIcon`, which the widget ignored. The latter three now drive the
  rendering and default to `Icons.star`, `Icons.star_half` and
  `Icons.star_border`, so the three removed arguments can simply be dropped or
  renamed.
- `onChanged` is now typed `ValueChanged<double>` rather than
  `Function(double)`.
- The package no longer declares a `plugin:` section, and the `android/`,
  `ios/`, `linux/`, `macos/` and `windows/` directories are gone. Nothing was
  registered through them.

### Fixed

- `minRating` is now honoured: it clamps `initialRating` and raises any tap that
  would otherwise land below it, including the half-star toggle.
- `displayRatingValue` now draws the current rating beside the stars. It was
  previously declared, and defaulted to `true`, but never rendered anything.

### Added

- `halfFilledColor`, so the half-star state can be coloured independently.
  Defaults to `filledColor`.
- `ratingValueStyle`, to style the rating value drawn by `displayRatingValue`.
- The rating is re-clamped when `minRating` or `maxRating` change.
- `AnimatedStar` picks up a changed `animationDuration`.

## Previous releases, as `animated_rating_stars`

### 1.0.1

- Documentation Updated.

### 1.0.0 - Initial Release

- Added the `AnimatedRatingStars` widget, a customizable animated rating bar.
- Users can interact with the rating bar to provide a rating.
- Supports customization of filled, half-filled, and empty star icons.
- Displays the rating value and allows toggling half-star state with tooltips.
- Provides animation options for rating changes.
- Suitable for cross-platform use.
