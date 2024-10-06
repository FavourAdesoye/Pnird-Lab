// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/comments_screen.dart';
import 'package:pnirdlab/widgets/heart_animation_widget.dart';
import '../model/post_model.dart';
import 'package:intl/intl.dart';
import '../services/like_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  PostCard({required this.post});
  @override
  _PostCardState createState() => _PostCardState();
}

String formattedDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm a').format(dateTime);
}

class _PostCardState extends State<PostCard> {
  // const PostCard({Key? key}) : super(key: key);
  bool isLiked = false;
  bool isHeartAnimating = false;
  @override
  Widget build(BuildContext context) {
    final icon = isLiked ? Icons.favorite : Icons.favorite_outline;
    final color = isLiked ? Colors.red : Colors.white;
    return Container(
      color: Color.fromRGBO(0, 0, 0, 1),
      padding: const EdgeInsets.symmetric(vertical: 10),
      //User info section
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ).copyWith(right: 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/drKeen.jpg"),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.user
                              .username, //replace with username of someone
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ))
                ],
              )),
          //Image section
          GestureDetector(
            child: Stack(alignment: Alignment.center, children: [
              Expanded(
                child: Image.network(
                  widget.post.img ?? '', //Hande potential null
                  fit: BoxFit.cover,
                ),
              ),
              Opacity(
                opacity: isHeartAnimating ? 1 : 0,
                child: HeartAnimationWidget(
                  isAnimating: isHeartAnimating,
                  duration: Duration(milliseconds: 700),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 70,
                  ),
                  onEnd: () => setState(() => isHeartAnimating = false),
                ),
              ),
            ]),
            onDoubleTap: () async {
              setState(() {
                isHeartAnimating = true;
                isLiked = !isLiked; // Toggle like status
              });
              await likePost(widget.post.id, widget.post.user.id);
            },
          ),

          //Like comment section
          Row(
            children: [
              HeartAnimationWidget(
                alwaysAnimate: true,
                isAnimating: isLiked,
                child: IconButton(
                  icon: Icon(
                    icon,
                    color: color,
                  ),
                  onPressed: () async {
                    setState(() {
                      isLiked = !isLiked;
                    });
                    try {
                      await likePost(widget.post.id, widget.post.user.id);
                    } catch (e) {
                      setState(() {
                        isLiked = !isLiked; // Revert on failure
                      });
                    }
                  },
                ),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(),
                        ),
                      ),
                  icon: const Icon(
                    Icons.comment_outlined,
                  )),
            ],
          ),
          //Number of Likes and Comments and Description
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    child: Text(
                      '${widget.post.likes?.length ?? 0} likes',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                      text: TextSpan(
                          style: const TextStyle(
                              color: Color.fromARGB(255, 250, 228, 33)),
                          children: [
                        TextSpan(
                          text: widget.post.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '   ${widget.post.description ?? ''}',
                        ),
                      ])),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(),
                    ),
                  ),
                  child: Text(
                    "view all comments",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 179, 179, 172)),
                  ),
                ),
                Container(
                    child: Text(
                  formattedDateTime(widget.post.createdAt),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
