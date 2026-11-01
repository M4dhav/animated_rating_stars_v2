import 'package:flutter/material.dart';

/// A customizable animated rating bar widget.
///
/// Users can interact with this widget to provide a rating.
class AnimatedRatingStars extends StatefulWidget {
  /// The rating shown when the widget is first built.
  ///
  /// It is clamped into the [minRating]...[maxRating] range. This value is
  /// read once, when the state is created; later changes to it are ignored so
  /// that a rebuild cannot discard a rating the user has already chosen.
  final double initialRating;

  /// The lowest rating the user can select.
  ///
  /// Taps that would land below this value are raised to it.
  final double minRating;

  /// The highest rating the user can select.
  ///
  /// One star is drawn per whole unit, so a [maxRating] of `5.0` draws five.
  final double maxRating;

  /// The color for filled stars.
  final Color filledColor;

  /// The color for half-filled stars.
  ///
  /// Defaults to [filledColor] when null.
  final Color? halfFilledColor;

  /// The color for empty stars.
  final Color emptyColor;

  /// The icon used for filled stars.
  final IconData filledIcon;

  /// The icon used for half-filled stars.
  final IconData halfFilledIcon;

  /// The icon used for empty stars.
  final IconData emptyIcon;

  /// Called with the new rating whenever the user taps a star.
  final ValueChanged<double> onChanged;

  /// Whether to draw the current rating as text beside the stars.
  final bool displayRatingValue;

  /// The text style for the rating value drawn when [displayRatingValue] is
  /// set.
  ///
  /// Defaults to the surrounding text style sized against [starSize] and
  /// tinted with [filledColor].
  final TextStyle? ratingValueStyle;

  /// Whether tapping the currently selected star drops it to a half star.
  ///
  /// This also governs whether half stars are drawn at all: with it unset, a
  /// rating of `2.5` renders as two filled stars.
  final bool interactiveTooltips;

  /// The size of each star.
  final double starSize;

  /// The duration of the animation when the rating changes.
  final Duration animationDuration;

  /// The curve for the animation when the rating changes.
  final Curve animationCurve;

  /// Determines whether the widget is read-only.
  final bool readOnly;

  /// Creates an [AnimatedRatingStars] widget.
  const AnimatedRatingStars({
    super.key,
    this.initialRating = 0.0,
    this.minRating = 0.0,
    this.maxRating = 5.0,
    this.filledColor = Colors.amber,
    this.halfFilledColor,
    this.emptyColor = Colors.grey,
    this.filledIcon = Icons.star,
    this.halfFilledIcon = Icons.star_half,
    this.emptyIcon = Icons.star_border,
    required this.onChanged,
    this.displayRatingValue = true,
    this.ratingValueStyle,
    this.interactiveTooltips = false,
    this.starSize = 30.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.readOnly = false,
  });

  @override
  State<AnimatedRatingStars> createState() => _AnimatedRatingStarsState();
}

class _AnimatedRatingStarsState extends State<AnimatedRatingStars> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = _clamped(widget.initialRating);
  }

  @override
  void didUpdateWidget(covariant AnimatedRatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A widened or narrowed range can leave the current rating outside it.
    if (widget.minRating != oldWidget.minRating ||
        widget.maxRating != oldWidget.maxRating) {
      _rating = _clamped(_rating);
    }
  }

  /// [rating] held inside the configured range.
  double _clamped(double rating) =>
      rating.clamp(widget.minRating, widget.maxRating).toDouble();

  void _handleTap(int index) {
    if (widget.readOnly) return;

    final selectedRating = index + 1.0;
    // Tapping the star that is already selected drops it to a half star.
    final tapped = _rating == selectedRating && widget.interactiveTooltips
        ? selectedRating - 0.5
        : selectedRating;

    setState(() => _rating = _clamped(tapped));
    widget.onChanged(_rating);
  }

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(widget.maxRating.toInt(), (index) {
      return GestureDetector(
        onTap: () => _handleTap(index),
        child: AnimatedStar(
          filled: _rating >= index + 1,
          halfFilled: widget.interactiveTooltips && _rating == index + 0.5,
          filledColor: widget.filledColor,
          halfFilledColor: widget.halfFilledColor,
          emptyColor: widget.emptyColor,
          filledIcon: widget.filledIcon,
          halfFilledIcon: widget.halfFilledIcon,
          emptyIcon: widget.emptyIcon,
          starSize: widget.starSize,
          animationDuration: widget.animationDuration,
          animationCurve: widget.animationCurve,
        ),
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...stars,
        if (widget.displayRatingValue) ...<Widget>[
          SizedBox(width: widget.starSize / 4.0),
          Text(
            _rating.toStringAsFixed(1),
            style: widget.ratingValueStyle ??
                DefaultTextStyle.of(context).style.copyWith(
                      fontSize: widget.starSize * 0.6,
                      color: widget.filledColor,
                    ),
          ),
        ],
      ],
    );
  }
}

/// A single animated star widget.
class AnimatedStar extends StatefulWidget {
  /// Determines whether the star is filled.
  final bool filled;

  /// Determines whether the star is half-filled.
  ///
  /// Ignored while [filled] is set.
  final bool halfFilled;

  /// The color for filled stars.
  final Color filledColor;

  /// The color for half-filled stars.
  ///
  /// Defaults to [filledColor] when null.
  final Color? halfFilledColor;

  /// The color for empty stars.
  final Color emptyColor;

  /// The icon used for filled stars.
  final IconData filledIcon;

  /// The icon used for half-filled stars.
  final IconData halfFilledIcon;

  /// The icon used for empty stars.
  final IconData emptyIcon;

  /// The size of the star.
  final double starSize;

  /// The duration of the animation when the star state changes.
  final Duration animationDuration;

  /// The curve for the animation when the star state changes.
  final Curve animationCurve;

  /// Creates an [AnimatedStar] widget.
  const AnimatedStar({
    super.key,
    this.filled = false,
    this.halfFilled = false,
    this.filledColor = Colors.amber,
    this.halfFilledColor,
    this.emptyColor = Colors.grey,
    this.filledIcon = Icons.star,
    this.halfFilledIcon = Icons.star_half,
    this.emptyIcon = Icons.star_border,
    this.starSize = 30.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    if (widget.filled || widget.halfFilled) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }

    if (widget.filled != oldWidget.filled ||
        widget.halfFilled != oldWidget.halfFilled) {
      if (widget.filled || widget.halfFilled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// The icon for the star's current state.
  IconData get _icon {
    if (widget.filled) return widget.filledIcon;
    if (widget.halfFilled) return widget.halfFilledIcon;
    return widget.emptyIcon;
  }

  /// The color the star animates toward, away from [AnimatedStar.emptyColor].
  Color get _activeColor => widget.filled
      ? widget.filledColor
      : widget.halfFilledColor ?? widget.filledColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Icon(
          _icon,
          color: Color.lerp(
            widget.emptyColor,
            _activeColor,
            _animation.value,
          ),
          size: widget.starSize + 8.0 * _animation.value,
        );
      },
    );
  }
}
