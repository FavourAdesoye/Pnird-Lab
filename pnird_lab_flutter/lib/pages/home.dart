<<<<<<< HEAD
import 'package:flutter/material.dart';  

class Homehome extends StatelessWidget {

  const Homehome({super.key});
 
  @override
  Widget build(context) {
    return const MaterialApp( 
      home: Home()
    );
  }
}





class Home extends StatelessWidget {
  const Home({super.key});

  
@override
Widget build(BuildContext context){
  return const Scaffold( 
        backgroundColor: Colors.black, 
  ); 
}
}
=======
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../model/post_model.dart';
import '../services/post_service.dart';
import 'package:pnird_lab_flutter/widgets/post_card.dart';

class HomePage extends StatefulWidget {
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
            return Center(child: CircularProgressIndicator());
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
            return Center(child: Text('No posts available'));
          }
        },
      ),
    );
  }
}
>>>>>>> main
