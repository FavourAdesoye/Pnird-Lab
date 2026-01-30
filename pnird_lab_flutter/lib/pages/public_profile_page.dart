import 'package:flutter/material.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/services/user_service.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';
import 'package:pnirdlab/pages/message_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  _PublicProfilePageState createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  String? username = "Loading...";
  String? bio = "Loading bio...";
  String? profilepic = "";
  String? profileOwnerRole; // Role of the profile being viewed
  String? currentUserRole; // Role of logged-in user
  List<Post> posts = [];
  int postCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCurrentUserRole();
    fetchPublicProfileData(widget.userId);
  }

  Future<void> loadCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserRole = prefs.getString('role');
    });
  }

  Future<void> fetchPublicProfileData(String userId) async {
    try {
      final user = await UserService().fetchUserProfile(userId);
      final userPosts = await PostService2().fetchUserPosts(userId);

      setState(() {
        username = user.username;
        bio = user.bio;
        profilepic = user.profilePicture;
        profileOwnerRole = user.role; // Get the profile owner's role
        posts = userPosts;
        postCount = posts.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching public profile data: $e");
      setState(() => isLoading = false);
    }
  }

  // Check if current user can message this profile
  bool canMessage() {
    // Staff can message anyone
    if (currentUserRole == 'staff') return true;
    
    // Community members can only message staff
    if (currentUserRole == 'community' && profileOwnerRole == 'staff') return true;
    
    // Otherwise, no messaging allowed
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (profilepic != null && profilepic!.isNotEmpty)
                        ? NetworkImage(profilepic!)
                        : const AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username ?? "Loading...",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      bio ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
    
                  // Only show post count for staff members
                  if (profileOwnerRole == 'staff')
                    Text(
                      postCount == 1 ? "$postCount Post" : "$postCount Posts",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  // Only show Message button if user can message this profile
                  if (canMessage())
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
         onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage(
                        recipientId: widget.userId,
                        recipientName: username ?? "User",
                        isAdmin: profileOwnerRole == 'staff',
                      ),
                    ),
                  );
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.amber,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          side: const BorderSide(color: Colors.amber),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text("Message"),
      ),
                      ],
                    ),
                  // Only show posts section for staff members
                  if (profileOwnerRole == 'staff')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: posts.isEmpty
                          ? const Text("No posts yet.")
                          : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
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
                                      posts[index].img ?? '', // <- access the img field of Post
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image, color: Colors.grey);
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
            ),
    );
  }
}
