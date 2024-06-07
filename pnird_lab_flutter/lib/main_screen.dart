import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnird_lab_flutter/pages/events.dart';
import 'package:pnird_lab_flutter/pages/about_us.dart';
import 'package:pnird_lab_flutter/pages/games.dart';
import 'package:pnird_lab_flutter/pages/home.dart';
import 'package:pnird_lab_flutter/pages/studies.dart';

class MainScreenPage extends StatefulWidget {
  MainScreenPage({Key? key}) : super(key: key);

  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  int currentIndex = 0;
  final _screens = [
    HomePage(),
    StudiesPage(),
    EventsPage(),
    AboutUsPage(),
    GamesPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Icons.message,
                color: Color.fromARGB(255, 237, 230, 230),
                size: 36.0,
              ),
              onPressed: () {
                //Define on pressed functiom
              }),
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
        items: [
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
