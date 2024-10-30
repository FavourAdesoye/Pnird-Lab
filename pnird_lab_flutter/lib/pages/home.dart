import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Post>> futurePosts;
  @override
  void initState() {
    super.initState();
    futurePosts = getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Post> posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            );
          } else {
            return const Center(child: Text('No posts available'));
          }
        },
      ),
    );
  }
}
