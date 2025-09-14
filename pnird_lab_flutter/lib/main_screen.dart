import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/chats_page.dart';
import 'package:pnirdlab/pages/events_page.dart';
import 'package:pnirdlab/pages/about_us.dart';
import 'package:pnirdlab/pages/games/gamehome.dart';
import 'package:pnirdlab/pages/home.dart';
import 'package:pnirdlab/pages/studies.dart';
import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';

class MainScreenPage extends StatefulWidget {
  const MainScreenPage({super.key});

  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  int currentIndex = 0;
  final _screens = [
    const HomePage(),
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer menu
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
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
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile page
                // You'll need to get the current user ID here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      //App Bar widget
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 100,
        //Logo
        leading: Container(
            margin: const EdgeInsets.all(0),
            // alignment: Alignment.center,
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
              hintStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide:
                      const BorderSide(color: Colors.yellow, width: 2.0)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        //message
        actions: [
          IconButton(
              icon: const Icon(
                Icons.email,
                color: Color.fromARGB(255, 237, 230, 230),
                size: 36.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatsPage()),
                );
              }),
          // Logout button
          IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 36.0,
              ),
              onPressed: _logout),
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
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
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
