import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  final String message;
  final bool shouldFadeOut; // New parameter to trigger fade-out
  final VoidCallback? onFadeOutComplete; // Callback when fade-out completes

  const LoadingScreen({
    super.key,
    this.message = 'Cargando...',
    this.shouldFadeOut = false,
    this.onFadeOutComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _gradientController;
  late AnimationController _fadeOutController; // For fade-out animation
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeOutAnimation; // Animation for fading out
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    // Lottie animation controller
    _controller = AnimationController(vsync: this);

    // Fade animation controller (for fade-in)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Scale animation controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _scaleController.forward();
        }
      });

    // Gradient animation controller
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _gradientAnimation = ColorTween(
      begin: const Color(0xFF1E40AF),
      end: const Color(0xFF3B82F6),
    ).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.linear),
    );

    // Fade-out animation controller
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duration of fade-out
    );
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFadeOutComplete?.call(); // Notify parent when fade-out completes
        }
      });

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void didUpdateWidget(LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldFadeOut && !oldWidget.shouldFadeOut) {
      _fadeOutController.forward(); // Start fade-out when shouldFadeOut becomes true
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _gradientController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ripple effect on tap
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargando, por favor espera...')),
        );
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_gradientAnimation, _fadeOutAnimation]),
        builder: (context, _) => Opacity(
          opacity: _fadeOutAnimation.value, // Apply fade-out to the entire screen
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientAnimation.value ?? const Color(0xFF1E40AF),
                  const Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular progress indicator
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: null, // Indeterminate progress
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        // Lottie animation with scale
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            width: 100,
                            height: 100,
                            controller: _controller,
                            onLoaded: (composition) {
                              _controller
                                ..duration = composition.duration
                                ..repeat();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}