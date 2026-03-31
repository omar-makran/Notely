import 'package:flutter/material.dart';

class AuthHeroSection extends StatelessWidget {
  final String title;
  final String tagline;
  final String imagePath;
  final double positionSize;
  final double imageHeight;

  const AuthHeroSection({
    super.key,
    this.title = 'Notely',
    this.tagline = 'Your notes,\nanywhere.',
    this.imagePath = 'assets/icon/girl.png',
    this.positionSize = -10,
    this.imageHeight = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), Color(0xFFFF6B00), Color(0xFFE85D04)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.40,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(-20 * (1 - value), 0),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withAlpha(204),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: positionSize,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  imagePath,
                  height: MediaQuery.of(context).size.height * imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
