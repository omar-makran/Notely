import 'package:flutter/material.dart';

class AuthHeroSection extends StatelessWidget {
  final String title;
  final String tagline;
  final String imagePath;
  const AuthHeroSection({
    super.key,
    this.title = 'Notely',
    this.tagline = 'Your notes,\nanywhere.',
    this.imagePath = 'assets/icon/girl.png',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
            Positioned(
              right: 8,
              bottom: -10,
              child: Image.asset(
                imagePath,
                height: MediaQuery.of(context).size.height * 0.35,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
