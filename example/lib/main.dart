import 'package:animated_rating_stars_v2/animated_rating_stars_v2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  /// Constructs a new instance of [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _rating = 2.5;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Animated Rating Stars',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Animated Rating Stars'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Rating: $_rating',
                style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 24.0),

              // Interactive, with its own colour for the half star and the
              // rating value drawn alongside. minRating keeps it above zero.
              AnimatedRatingStars(
                initialRating: 2.5,
                minRating: 0.5,
                maxRating: 5.0,
                filledColor: Colors.amber,
                halfFilledColor: Colors.orangeAccent,
                emptyColor: Colors.grey,
                filledIcon: Icons.star,
                halfFilledIcon: Icons.star_half,
                emptyIcon: Icons.star_border,
                onChanged: (rating) => setState(() => _rating = rating),
                displayRatingValue: true,
                interactiveTooltips: true,
                starSize: 40.0,
                animationDuration: const Duration(milliseconds: 500),
                animationCurve: Curves.easeInOut,
              ),
              const SizedBox(height: 32.0),

              // Read-only, with a palette and icons of its own and the rating
              // value hidden.
              AnimatedRatingStars(
                initialRating: 4.0,
                filledColor: Colors.redAccent,
                emptyColor: Colors.pink.shade100,
                filledIcon: Icons.favorite,
                halfFilledIcon: Icons.heart_broken,
                emptyIcon: Icons.favorite_border,
                onChanged: (_) {},
                displayRatingValue: false,
                starSize: 28.0,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
