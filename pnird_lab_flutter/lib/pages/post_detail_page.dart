import 'package:flutter/material.dart';
import 'package:pnirdlab/widgets/post_card.dart';
import 'package:pnirdlab/model/post_model.dart';

class PostDetailPage extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;

  const PostDetailPage({super.key, required this.posts, required this.initialIndex});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late ScrollController _scrollController;
  late List<Post> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List<Post>.from(widget.posts);
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex < _posts.length) {
        _scrollController.jumpTo(widget.initialIndex * 700.0); // Adjust height
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: const Center(child: Text('No posts')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${_posts[widget.initialIndex.clamp(0, _posts.length - 1)].user.username}\nPosts',
    maxLines: 2,  // Allow the text to wrap into a second line if necessary
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center),
    centerTitle: true,
    ),
   
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
  final post = _posts[index];

  return PostCard(
   post: post,
   onDeleted: () {
     setState(() => _posts.removeAt(index));
   },
  );
}

      ),
    );
  }
}