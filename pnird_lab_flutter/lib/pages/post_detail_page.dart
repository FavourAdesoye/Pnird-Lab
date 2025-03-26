import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/widgets/post_card.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/model/post_model.dart';


// import 'package:pnirdlab/services/post_service.dart';
// import 'package:pnirdlab/pages/profile_page.dart';
// class PostDetailPage extends StatefulWidget {
//   final List<String> posts;
//   final int initialIndex;

//   PostDetailPage({required this.posts, required this.initialIndex});

//   @override
//   _PostDetailPageState createState() => _PostDetailPageState();
// }

// class _PostDetailPageState extends State<PostDetailPage> {
//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();

//     // Jump to the selected post after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController
//           .jumpTo(widget.initialIndex * 400.0); // Adjust height if needed
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Post Details")),
//       body: ListView.builder(
//         controller: _scrollController,
//         itemCount: widget.posts.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Column(
//               children: [
//                 Image.network(
//                   widget.posts[index],
//                   fit: BoxFit.contain,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(child: CircularProgressIndicator());
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(Icons.broken_image, color: Colors.grey);
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 Text("Post ${index + 1}",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Divider(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class PostDetailPage extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;

  PostDetailPage({required this.posts, required this.initialIndex});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex < widget.posts.length)
        _scrollController.jumpTo(widget.initialIndex * 700.0); // Adjust height
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post Details")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
  final post = widget.posts[index];

  return PostCard(
   post: post,
  );
}

      ),
    );
  }
}