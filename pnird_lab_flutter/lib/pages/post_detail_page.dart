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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex < widget.posts.length) {
        _scrollController.jumpTo(widget.initialIndex * 700.0); // Adjust height
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.posts[widget.initialIndex].user.username}\nPosts',
    maxLines: 2,  // Allow the text to wrap into a second line if necessary
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center),
    centerTitle: true,
    ),
   
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