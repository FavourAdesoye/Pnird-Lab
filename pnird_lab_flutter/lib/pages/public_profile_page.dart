import 'package:flutter/material.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/services/user_service.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';
import 'package:pnirdlab/pages/chats_page.dart';

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
  List<Post> posts = [];
  int postCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPublicProfileData(widget.userId);
  }

  Future<void> fetchPublicProfileData(String userId) async {
    try {
      final user = await UserService().fetchUserProfile(userId);
      final userPosts = await PostService2().fetchUserPosts(userId);

      setState(() {
        username = user.username;
        bio = user.bio;
        profilepic = user.profilePicture;
        posts = userPosts;
        postCount = posts.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching public profile data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
    
                  Text(
                    postCount == 1 ? "$postCount Post" : "$postCount Posts",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        side: const BorderSide(color: Colors.amber), // Optional: outline
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text("Message"),
    ),
                    ],
                  ),
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
    );
  }
}
