import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/pages/settings/settings.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/post_model.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';
import 'package:pnirdlab/pages/create_post_screen.dart';
import 'package:pnirdlab/pages/chats_page.dart';
class ProfilePage extends StatefulWidget {
  final String myuserId;
  const ProfilePage({super.key, required this.myuserId});
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

  // Load userId from local storage
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // Retrieve userId saved during login
    firebaseId = prefs.getString('firebaseId');
    if (userId != null && userId!.isNotEmpty) {
      setState(() {
        userId = userId;
        loggedInUserId = userId;
      });
      print("useridset: $userId");
      // Fetch user details and posts from the backend
      await fetchProfileData(userId!);
      await fetchUserPosts(userId!);
    } else {
      print("No user ID found!");
    }
  }

  // Fetch profile data for the specific user
  Future<void> fetchProfileData(String userId) async {
    print("fetching profile data for user: $userId");
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/users/$firebaseId'),
      // headers: {
      //   'Authorization': 'Bearer <token>', // Include token if required
      // },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Profile data: $responseData");
      setState(() {
        username =
            responseData['username']; // Replace with data from API response
        bio = responseData['bio'];
        profilepic = responseData['profilePicture'];
      });
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> fetchUserPosts(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/posts/user/$firebaseId'),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      setState(() {
        posts = List<Post>.from(responseData.map((post) => Post.fromJson(post)));
        postCount = posts.length;
      });
    } else {
      throw Exception("Failed to load user posts");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: userId == null
          ? const Center(child: Text("User not logged in."))
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
                            : const AssetImage('assets/images/defaultprofilepic.png')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 10),

                  // Username
                  Text(
                    username ?? "Loading...",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 10),

                  // Post Count
                  Text(
                    postCount == 1 ? "$postCount Post" : "$postCount Posts",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Buttons
                  Wrap(
                    spacing: 8,
  runSpacing: 8,
                    children: [
                     ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  Setting(userId: userId!)),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.amber,
    side: const BorderSide(color: Colors.amber),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text(
    "Settings",
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
      MaterialPageRoute(builder: (context) => CreatePostScreen(userId: userId!,)),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.amber,
    side: const BorderSide(color: Colors.amber),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text(
    "Create Post",
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
      MaterialPageRoute(builder: (context) => const ChatsPage()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.amber,
    side: const BorderSide(color: Colors.amber),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text(
    "Message",
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                    ],
                  ),
                  const SizedBox(height: 20),

                  // Grid View of Posts
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.isNotEmpty ? posts.length : 1,
                      itemBuilder: (context, index) {
                        if (posts.isEmpty) {
                          return const Center(child: Text("No posts yet."));
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
                              child: Image.network(
                                posts[index].img ?? 'assets/images/defaultprofilepic.png', // Assuming each post contains an image URL
                                fit: BoxFit
                                    .cover, // Ensures the image fills the container
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // Image loaded
                                  }
                                  return const Center(
                                    child:
                                        CircularProgressIndicator(), // Show loader while image loads
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image,
                                      color:
                                          Colors.grey); // Handle broken images
                                },
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