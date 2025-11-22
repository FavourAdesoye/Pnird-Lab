import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/pages/chats_page.dart';
import 'package:pnirdlab/pages/events_page.dart';
import 'package:pnirdlab/pages/about_us.dart';
import 'package:pnirdlab/pages/games/gamehome.dart';
import 'package:pnirdlab/pages/optimized_home.dart';
import 'package:pnirdlab/pages/studies.dart';
import 'package:pnirdlab/pages/current_user_profile_page.dart';
import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:pnirdlab/providers/theme_provider.dart';

class MainScreenPage extends StatefulWidget {
  const MainScreenPage({super.key});

  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  int currentIndex = 0;
  final _screens = [
    const OptimizedHomePage(),
    const StudiesPage(),
    const EventsPage(),
    const AboutUsPage(),
    const Gamehome(),
  ];

  Future<void> _logout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await Auth.logout();
        // Navigate to login screen and clear the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ChooseAccountTypePage()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black87;
    
    return Scaffold(
      // Drawer menu
      drawer: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.yellow,
              ),
              child: Text(
                'Pnird Lab',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: iconColor),
              title: Text('Profile', style: TextStyle(color: textColor)),
              onTap: () async {
                Navigator.pop(context);
                // Navigate to current user's profile
                final prefs = await SharedPreferences.getInstance();
                final mongoUserId = prefs.getString('userId');
                if (mongoUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(myuserId: mongoUserId),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: iconColor),
              title: Text('Messages', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: iconColor),
              title: Text('Team Members', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: iconColor),
              title: Text('Settings', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: Text('Dark Mode', style: TextStyle(color: textColor)),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                    style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.yellow,
                  inactiveThumbColor: Colors.grey,
                );
              },
            ),
            Divider(color: isDark ? Colors.grey : Colors.grey[300]),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ),
          ],
        ),
      ),
      //App Bar widget
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        toolbarHeight: 100,
        //Logo
        leading: Container(
            margin: const EdgeInsets.all(0),
            child: Image.asset(
              'assets/logos/logophoto_large.png',
              fit: BoxFit.contain,
            )),
        //search bar
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: isDark ? Colors.yellow : Colors.black87,
                    width: 2.0,
                  )),
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),

        //message and menu
        actions: [
          IconButton(
              icon: Icon(
                Icons.email,
                color: isDark 
                  ? const Color.fromARGB(255, 237, 230, 230)
                  : Colors.black87,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatsPage()),
                );
              }),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black87,
                size: 30.0,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        //inorder to preserve the state of widgets when navigating, I used an index stack
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.library_books,
            ),
            label: 'Studies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Game',
          ),
        ],
      ),
    );
  }
}
