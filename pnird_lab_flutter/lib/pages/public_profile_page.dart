import 'package:flutter/material.dart';
import 'package:pnirdlab/model/user_model.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/services/user_service.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';


class PublicProfilePage extends StatefulWidget {
  final String userId;

  PublicProfilePage({required this.userId});

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
      appBar: AppBar(title: Text("User Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (profilepic != null && profilepic!.isNotEmpty)
                        ? NetworkImage(profilepic!)
                        : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    username ?? "Loading...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      bio ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    postCount == 1 ? "$postCount Post" : "$postCount Posts",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: posts.isEmpty
                        ? Text("No posts yet.")
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                        return Icon(Icons.broken_image, color: Colors.grey);
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
