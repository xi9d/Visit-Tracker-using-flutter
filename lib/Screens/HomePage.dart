import 'package:flutter/material.dart';
import 'package:rtm/Services/auth_service.dart';
import 'package:rtm/Screens/CustomersScreen.dart';
import 'package:rtm/Screens/AddVisitScreen.dart';
import 'package:rtm/Screens/ActivitiesScreen.dart';
import 'package:rtm/Screens/VisitsScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const VisitsScreen(),
    const CustomersScreen(),
    const ActivitiesScreen(),
  ];

  final AuthService _authService = AuthService();
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
        title: const Text('Customer Visit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
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
        child: ListView(
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
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
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
        );
      },
    );
  }
}