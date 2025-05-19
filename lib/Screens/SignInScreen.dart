import 'package:flutter/material.dart';
import 'package:rtm/Services/auth_service.dart';
import 'package:rtm/Screens/RepHomePage.dart';
import 'package:rtm/Screens/ManagerHomePage.dart';
import 'dart:math' as math;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _liquidController;
  late AnimationController _waveController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _liquidController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Navigate based on user role
        if (user.role == 'manager') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ManagerHomePage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RepHomePage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in. Please try again.';
      });
      print('SignIn error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
          ),

          // Wave animation at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: _waveController,
                    primaryColor: primaryColor.withOpacity(0.3),
                    secondaryColor: accentColor.withOpacity(0.2),
                  ),
                  size: Size(screenSize.width, 160),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // App Logo with flowing liquid effect
                      Center(
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _liquidController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: LiquidPainter(
                                      animation: _liquidController.value,
                                      color: primaryColor,
                                    ),
                                    size: const Size(120, 120),
                                  );
                                },
                              ),
                              Icon(
                                Icons.business_center,
                                size: 60,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Customer Visit Tracker',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Field with floating animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },

                        ),
                      ),

                      // Error Message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 30),

                      // Replace the Sign In Button code with this improved version that prevents shifting:

// Sign In Button with liquid-like background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withBlue(255)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero, // Remove default padding
                          ),
                          child: Center( // Center widget helps maintain alignment
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100), // Space for the wave animation

                      // Sign Up Button - positioned above the waves
                      Center(
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Contact Administrator'),
                                content: const Text(
                                  'Please contact your manager to set up an account for you.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the liquid effect in the logo
class LiquidPainter extends CustomPainter {
  final double animation;
  final Color color;

  LiquidPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw a circle with wavy edges
    for (double angle = 0; angle < 360; angle += 1) {
      final angleInRadians = angle * math.pi / 180;

      final waveAmplitude = 10.0;
      final waveFrequency = 6.0;
      final wave = math.sin((angleInRadians * waveFrequency) + (animation * math.pi * 2));

      final x = center.dx + (radius + wave * waveAmplitude) * math.cos(angleInRadians);
      final y = center.dy + (radius + wave * waveAmplitude) * math.sin(angleInRadians);

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Custom painter for the wave effect at the bottom
class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  WavePainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryWave = _buildWavePath(
      size: size,
      waveAmplitude: 20.0,
      waveFrequency: 1.5,
      phase: animation.value * 2 * math.pi,
    );

    final secondaryWave = _buildWavePath(
      size: size,
      waveAmplitude: 15.0,
      waveFrequency: 2.0,
      phase: (animation.value + 0.5) * 2 * math.pi,
    );

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Draw waves from bottom to top (back to front)
    canvas.drawPath(secondaryWave, secondaryPaint);
    canvas.drawPath(primaryWave, primaryPaint);
  }

  Path _buildWavePath({
    required Size size,
    required double waveAmplitude,
    required double waveFrequency,
    required double phase,
  }) {
    final path = Path();

    // Start at bottom-left corner
    path.moveTo(0, size.height);

    // Draw the wave
    for (double x = 0; x <= size.width; x++) {
      final relativeX = x / size.width;
      final y = size.height - 60 - waveAmplitude *
          math.sin((relativeX * waveFrequency * math.pi * 2) + phase);

      path.lineTo(x, y);
    }

    // Complete the path to the bottom-right corner
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}