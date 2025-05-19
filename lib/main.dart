import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rtm/Screens/HomePage.dart';
import 'package:rtm/Screens/SignInScreen.dart';
import 'package:rtm/Screens/SignUpScreen.dart';
import 'package:rtm/flutter_native_splash.dart';
import 'package:rtm/Services/auth_service.dart';
import 'package:rtm/Screens/RepHomePage.dart';
import 'package:rtm/Screens/ManagerHomePage.dart';
import 'package:rtm/Screens/SplashScreen.dart';
import 'theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style to match your splash screen
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Visit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth_wrapper': (context) => const AuthWrapper(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/rep_home': (context) => const RepHomePage(),
        '/manager_home': (context) => const ManagerHomePage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSignedIn = false;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isSignedIn = await _authService.isSignedIn();
    String userRole = '';

    if (isSignedIn) {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        userRole = user.role;
      }
    }

    setState(() {
      _isSignedIn = isSignedIn;
      _userRole = userRole;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isSignedIn) {
      // Navigate based on user role
      if (_userRole == 'manager') {
        return const ManagerHomePage();
      } else {
        return const RepHomePage();
      }
    } else {
      return const SignInScreen();
    }
  }
}