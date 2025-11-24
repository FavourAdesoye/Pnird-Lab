import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/post_model.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';
import 'package:pnirdlab/pages/edit_profile_screen.dart';
import 'package:pnirdlab/pages/create_post_screen.dart';
import 'package:pnirdlab/pages/chats_page.dart';
import 'package:pnirdlab/pages/message_page.dart';
import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
class ProfilePage extends StatefulWidget {
  final String myuserId;
  ProfilePage({required this.myuserId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String? loggedInUserId;
  String? firebaseId;
  String? username = "Loading...";
  String? bio = "Loading bio...";
  String? profilepic = "";
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

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
          (Route<dynamic> route) => false,
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

  // Load userId from local storage
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInUserId = prefs.getString('userId'); // Store logged-in user ID for comparison
    firebaseId = prefs.getString('firebaseId');
    
    // Use the provided myuserId parameter, or fall back to logged-in user's ID
    final targetUserId = widget.myuserId.isNotEmpty ? widget.myuserId : loggedInUserId;
    
    if (targetUserId != null && targetUserId.isNotEmpty) {
      setState(() {
        userId = targetUserId;
      });
      // Fetch user details and posts from the backend for the target user
      await fetchProfileData(targetUserId);
      await fetchUserPosts(targetUserId);
    } else {
      // Handle case where no user ID is found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    }
  }

  // Fetch profile data for the specific user
  Future<void> fetchProfileData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getUserByIdEndpoint(userId)),
        // headers: {
        //   'Authorization': 'Bearer <token>', // Include token if required
        // },
      );


      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          username = responseData['username'];
          bio = responseData['bio'];
          profilepic = responseData['profilePicture'];
        });
      } else {
        // Handle API error
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      throw Exception('Failed to load profile data: $e');
    }
  }

  Future<void> fetchUserPosts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getUserPostsEndpoint(userId)),
      );
      
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          posts = List<Post>.from(responseData.map((post) => Post.fromJson(post)));
          postCount = posts.length;
        });
      } else {
        // Handle API error
        throw Exception("Failed to load user posts: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exception
      throw Exception("Failed to load user posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: userId == null
          ? Center(child: Text("User not logged in."))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profilepic != null && profilepic!.isNotEmpty
                            ? NetworkImage(profilepic!)
                            : AssetImage('assets/images/defaultprofilepic.png')
                                as ImageProvider,
                  ),
                  SizedBox(height: 10),

                  // Username
                  Text(
                    username ?? "Loading...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // Short Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      bio ?? "Loading bio...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Post Count
                  Text(
                    postCount == 1 ? "$postCount Post" : "$postCount Posts",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Buttons - Show different buttons based on whether viewing own profile or other user's profile
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Only show Edit Profile and Create Post if viewing own profile
                      if (userId == loggedInUserId) ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileEditScreen(userId: userId!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.amber,
                            side: BorderSide(color: Colors.amber),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreatePostScreen(userId: userId!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.amber,
                            side: BorderSide(color: Colors.amber),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Create Post",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      // Message button - show for both own profile and other users
                      ElevatedButton(
                        onPressed: () {
                          if (userId == loggedInUserId) {
                            // If viewing own profile, go to chats page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatsPage()),
                            );
                          } else {
                            // If viewing other user's profile, go directly to message page with that user
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagePage(
                                  recipientId: userId!,
                                  recipientName: username ?? 'User',
                                  isAdmin: false,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.amber,
                          side: BorderSide(color: Colors.amber),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          userId == loggedInUserId ? "Messages" : "Message",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Grid View of Posts
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.isNotEmpty ? posts.length : 1,
                      itemBuilder: (context, index) {
                        if (posts.isEmpty) {
                          return Center(child: Text("No posts yet."));
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(
                                    posts: posts, initialIndex: index),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: posts[index].img != null && posts[index].img!.isNotEmpty
                                  ? Image.network(
                                      posts[index].img!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
