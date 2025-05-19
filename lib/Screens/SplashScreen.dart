import 'package:flutter/material.dart';
import 'dart:async';
import '../flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start animation
    _animationController.forward();

    // Remove native splash screen after our UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // Navigate to AuthWrapper after 2.5 seconds
    Timer(const Duration(milliseconds: 3300), () {
      Navigator.of(context).pushReplacementNamed('/auth_wrapper');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Icon(
                Icons.location_on,  // Replace with your custom app icon
                size: 80,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 24),
              // App name
              Text(
                'Customer Visit Tracker',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
