import 'package:flutter/material.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _noteScale;
  late Animation<double> _noteFade;
  late Animation<Offset> _noteSlide;

  late Animation<double> _penFade;
  late Animation<double> _penRotation;
  late Animation<Offset> _penPosition;

  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // ── NOTE: Scale up from small + fade in (0% → 40%) ──
    _noteScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.elasticOut),
      ),
    );

    _noteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _noteSlide = Tween<Offset>(begin: const Offset(0, 3.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
          ),
        );

    // ── PEN: Swoops in from top-right, settles on note (35% → 75%) ──
    _penFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.45, curve: Curves.easeIn),
      ),
    );

    // Pen starts pointing up-right, rotates to its resting angle
    _penRotation = Tween<double>(begin: -1.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Pen slides from far top-right down to its resting position
    _penPosition =
        TweenSequence<Offset>([
          // Swoop in from top-right
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(3.0, -3.0),
              end: const Offset(0.0, 0.0),
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 70,
          ),
          // Tiny bounce settle
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0.0, 0.0),
              end: const Offset(0.02, -0.02),
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 15,
          ),
          TweenSequenceItem(
            tween: Tween<Offset>(
              begin: const Offset(0.02, -0.02),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 15,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.30, 0.80),
          ),
        );

    // ── APP NAME: Fades in + slides up after logo forms (75% → 100%) ──
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 240,
              height: 240,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      SlideTransition(
                        position: _noteSlide,
                        child: Transform.scale(
                          scale: _noteScale.value,
                          child: Opacity(
                            opacity: _noteFade.value,
                            child: Image.asset('assets/splash/note.png'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 42,
                        right: 30,
                        child: Transform.rotate(
                          angle: _penRotation.value,
                          alignment: Alignment.bottomLeft,
                          child: SlideTransition(
                            position: _penPosition,
                            child: Opacity(
                              opacity: _penFade.value,
                              child: SizedBox(
                                width: 160,
                                child: Image.asset('assets/splash/pen.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Text(
                  'Notely',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
