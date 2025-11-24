import 'dart:async';
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
import 'package:pnirdlab/pages/search_results_page.dart';
import 'package:pnirdlab/services/search_service.dart';

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

  // Search autocomplete state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;

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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    // Debounce API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _suggestions.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = await SearchService.getSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty && _searchFocusNode.hasFocus;
        });
        if (_showSuggestions) {
          _showSuggestionsOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      // Silently handle errors
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        _removeOverlay();
      }
    }
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();
    
    // Get the search bar's render box for accurate positioning
    final RenderBox? searchBarBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (searchBarBox == null) return;

    final searchBarSize = searchBarBox.size;
    final searchBarOffset = searchBarBox.localToGlobal(Offset.zero);
    
    // Position dropdown directly below the search bar with a small gap
    final topPosition = searchBarOffset.dy + searchBarSize.height + 8; // 8px gap below search bar
    final leftPosition = searchBarOffset.dx;
    final dropdownWidth = searchBarSize.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: leftPosition,
        top: topPosition, // Position below search bar with gap
        width: dropdownWidth,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: _suggestions.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return _buildSuggestionItem(suggestion);
                    },
                  ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    final type = suggestion['type'] as String;
    final text = suggestion['text'] as String;
    
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'post':
        icon = Icons.article;
        iconColor = Colors.blue;
        break;
      case 'study':
        icon = Icons.library_books;
        iconColor = Colors.green;
        break;
      case 'event':
        icon = Icons.event;
        iconColor = Colors.orange;
        break;
      case 'user':
        icon = Icons.person;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.search;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return InkWell(
      onTap: () {
        _searchController.text = text;
        _removeOverlay();
        _searchFocusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(query: text),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Text(
              type.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
          key: _searchBarKey,
          height: 40,
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
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
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  )),
              filled: true,
              fillColor: isDark ? Theme.of(context).inputDecorationTheme.fillColor : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onSubmitted: (value) {
              _removeOverlay();
              _searchFocusNode.unfocus();
              if (value.trim().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsPage(query: value.trim()),
                  ),
                );
              }
            },
            onTap: () {
              if (_suggestions.isNotEmpty) {
                _showSuggestionsOverlay();
              }
            },
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
