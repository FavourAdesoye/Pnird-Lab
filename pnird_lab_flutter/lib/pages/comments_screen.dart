import 'package:flutter/material.dart';
import 'package:pnirdlab/widgets/user_avatar.dart';
import 'package:pnirdlab/widgets/comment_card.dart';
import 'package:pnirdlab/services/comment_service.dart';
import 'package:pnirdlab/model/comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final String entityId;
  final String entityType;
  const CommentsScreen(
      {super.key, required this.entityId, required this.entityType});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Comment> comments = []; // To hold fetched comments
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final CommentService _commentService = CommentService();
  String username = "Guest";
  String? replyingToCommentId;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  void fetchComments() async {
    try {
      comments =
          await _commentService.getComments(widget.entityType, widget.entityId);
      setState(() {});
    } catch (e) {
      // Handle error appropriately
      print(e.toString());
    }
  }

  void postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      try {
        await _commentService.createComment(widget.entityType, widget.entityId,
            "username", commentText); // Replace with actual user ID
        _commentController.clear();
        fetchComments(); // Refresh comments after posting
      } catch (e) {
        // Handle error appropriately
        print(e.toString());
      }
    }
  }

  void postReply(String entityType, String commentId) async {
    final replyText = _replyController.text.trim();
    if (replyText.isNotEmpty) {
      try {
        await _commentService.createReply(
            entityType, commentId, username, replyText);
        _replyController.clear();
        replyingToCommentId = null; // Reset reply tracking
        fetchComments(); // Refresh comments after posting
      } catch (e) {
        print('Failed to post reply: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFFC700),
        title: const Text("Comments"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentCard(
                  comment: comments[index],
                  onReply: (commentId) {
                    setState(() {
                      replyingToCommentId =
                          commentId; // Set the comment ID being replied to
                    });
                  },
                );
              },
            ),
          ),
          if (replyingToCommentId != null) // Show reply input if replying
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  const UserAvatar(filename: "drKeen.jpg"),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          hintText: "Write a reply",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (replyingToCommentId != null) {
                        postReply(widget.entityType, replyingToCommentId!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: const Text(
                        'Post',
                        style: TextStyle(color: Color(0xffFFC700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                const UserAvatar(filename: "drKeen.jpg"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Write a comment",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: postComment,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Color(0xffFFC700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
