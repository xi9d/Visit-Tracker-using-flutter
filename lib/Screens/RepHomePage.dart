import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:rtm/Services/auth_service.dart';
import 'package:rtm/Screens/CustomersScreen.dart';
import 'package:rtm/Screens/AddVisitScreen.dart';
import 'package:rtm/Screens/ActivitiesScreen.dart';
import 'package:rtm/Screens/VisitsScreen.dart';

class RepHomePage extends StatefulWidget {
  const RepHomePage({Key? key}) : super(key: key);

  @override
  _RepHomePageState createState() => _RepHomePageState();
}

class LiquidPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final bool isTop;

  LiquidPainter({
    required this.animation,
    required this.color,
    this.isTop = true,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    if (isTop) {
      // Top liquid effect - flowing down
      path.moveTo(0, 0);
      path.lineTo(0, height * 0.3);

      for (int i = 0; i < 5; i++) {
        final waveHeight = height * 0.05;
        final xOffset = width / 5 * i;
        final yOffset = height * 0.3 +
            math.sin((animation.value * 2 * math.pi) + (i * math.pi / 2.5)) * waveHeight;

        path.quadraticBezierTo(
            xOffset + width / 10,
            yOffset + (i % 2 == 0 ? waveHeight : -waveHeight),
            xOffset + width / 5,
            yOffset
        );
      }

      path.lineTo(width, 0);
      path.close();
    } else {
      // Bottom waves
      path.moveTo(0, height);
      path.lineTo(0, height * 0.7);

      for (int i = 0; i < 5; i++) {
        final waveHeight = height * 0.04;
        final xOffset = width / 5 * i;
        final yOffset = height * 0.7 +
            math.sin((animation.value * 2 * math.pi) + (i * math.pi / 2.5)) * waveHeight;

        path.quadraticBezierTo(
            xOffset + width / 10,
            yOffset + (i % 2 == 0 ? waveHeight : -waveHeight),
            xOffset + width / 5,
            yOffset
        );
      }

      path.lineTo(width, height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) => true;
}

class _RepHomePageState extends State<RepHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const VisitsScreen(),
    const CustomersScreen(),
    const ActivitiesScreen(),
  ];

  final AuthService _authService = AuthService();
  String _userName = '';
  String _userRole = '';

  // Animation controllers
  late AnimationController _liquidAnimationController;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // Initialize animations
    _liquidAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _liquidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_liquidAnimationController);
  }

  @override
  void dispose() {
    _liquidAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userRole = user.role;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;

    // Navigate to sign-in screen
    Navigator.of(context).pushReplacementNamed('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Visit Tracker'),
        flexibleSpace: CustomPaint(
          painter: LiquidPainter(
            animation: _liquidAnimation,
            color: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
          child: Container(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Representatives can only add visits, not customers
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVisitScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _showProfileMenu();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            // Liquid animation in drawer
            Positioned.fill(
              child: CustomPaint(
                painter: LiquidPainter(
                  animation: _liquidAnimation,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Role: $_userRole',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Visits'),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Customers'),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.checklist),
                  title: const Text('Activities'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(2);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Bottom wave effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenSize.height * 0.15,
            child: CustomPaint(
              painter: LiquidPainter(
                animation: _liquidAnimation,
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                isTop: false,
              ),
              child: Container(),
            ),
          ),
          // Content screens
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          // Wave above bottom navigation
          CustomPaint(
            painter: LiquidPainter(
              animation: _liquidAnimation,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              isTop: false,
            ),
            child: Container(height: 10),
          ),
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Visits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'Activities',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Background with waves
            CustomPaint(
              painter: LiquidPainter(
                animation: _liquidAnimation,
                color: Theme.of(context).cardColor,
                isTop: false,
              ),
              child: Container(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(_userName),
                  subtitle: Text('Role: $_userRole'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Profile Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}