// Enhanced Manager Home Page with liquid animations
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rtm/Screens/ActivitiesScreen.dart';
import 'package:rtm/Screens/AddCustomerScreen.dart';
import 'package:rtm/Screens/AddVisitScreen.dart';
import 'package:rtm/Screens/CustomersScreen.dart';
import 'package:rtm/Screens/LiquidBackgroundScreen.dart';
import 'package:rtm/Screens/SignUpScreen.dart';
import 'package:rtm/Screens/StatsScreen.dart';
import 'package:rtm/Screens/VisitsScreen.dart';
import 'package:rtm/Services/auth_service.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({Key? key}) : super(key: key);

  @override
  _ManagerHomePageState createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late AnimationController _liquidController;

  final AuthService _authService = AuthService();
  String _userName = '';
  String _userRole = '';

  // App theme colors
  final Color primaryColor = const Color(0xFF2196F3);  // Blue
  final Color accentColor = const Color(0xFF64B5F6);   // Light Blue
  final Color secondaryColor = const Color(0xFF03A9F4); // Lighter Blue

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // Initialize animation controller for liquid effects
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Initialize screens with liquid backgrounds
    _screens = [
      LiquidBackgroundScreen(
        child: const StatsScreen(),
        primaryColor: primaryColor,
        accentColor: accentColor,
        controller: _liquidController,
      ),
      LiquidBackgroundScreen(
        child: const CustomersScreen(),
        primaryColor: primaryColor,
        accentColor: accentColor,
        controller: _liquidController,
      ),
      LiquidBackgroundScreen(
        child: const VisitsScreen(),
        primaryColor: primaryColor,
        accentColor: accentColor,
        controller: _liquidController,
      ),
      LiquidBackgroundScreen(
        child: const ActivitiesScreen(),
        primaryColor: primaryColor,
        accentColor: accentColor,
        controller: _liquidController,
      ),
    ];
  }

  @override
  void dispose() {
    _liquidController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manager Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddMenu();
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
        child: Column(
          children: [
            LiquidDrawerHeader(
              userName: _userName,
              userRole: _userRole,
              primaryColor: primaryColor,
              accentColor: accentColor,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Statistics'),
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
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Visits'),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.checklist),
                    title: const Text('Activities'),
                    selected: _selectedIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(3);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Add Representative'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                  ),
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
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Visits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'Activities',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LiquidBottomSheet(
          primaryColor: primaryColor,
          accentColor: accentColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Add New',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                leading: Icon(Icons.add_business, color: primaryColor),
                title: const Text('Add Customer'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add_task, color: primaryColor),
                title: const Text('Add Visit'),
                enabled: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddVisitScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LiquidBottomSheet(
          primaryColor: primaryColor,
          accentColor: accentColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 30,
                backgroundColor: primaryColor.withOpacity(0.2),
                child: Icon(Icons.person, size: 40, color: primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Role: $_userRole',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.settings, color: primaryColor),
                title: const Text('Profile Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile settings
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: primaryColor),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}