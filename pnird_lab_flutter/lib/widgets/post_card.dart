// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/comments_screen.dart';
import 'package:pnirdlab/widgets/heart_animation_widget.dart';
import '../model/post_model.dart';
import 'package:intl/intl.dart';
import '../services/like_service.dart';
import 'package:pnirdlab/pages/current_user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/pages/public_profile_page.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});
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
  String? loggedInUserId; // Store the logged-in user ID

  @override
void initState() {
  super.initState();
  loadUserId().then((_) {
    setState(() {
      isLiked = widget.post.likes?.contains(loggedInUserId) ?? false;
    });
  });
}


  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Get the stored user ID
  }

  Future<void> loadUserId() async {
    loggedInUserId = await getLoggedInUserId();
    setState(() {}); // Rebuild widget after fetching ID
  }

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
                vertical: 9,
                horizontal: 16,
              ).copyWith(right: 0),
              child: GestureDetector(
                onTap: () {
                  String clickedUserId = widget.post.user.id; //getting the regular id. not firebase id
                  print("clickedUserId: $clickedUserId");

                  if (loggedInUserId != null && clickedUserId == loggedInUserId
                   ) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(myuserId: clickedUserId), //regular id
                      ),
                    );
                   } 
                   else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PublicProfilePage(userId: clickedUserId),
                      ),
                    );
                  }
                },
             
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.post.user.profilePicture.isNotEmpty
                          ? NetworkImage(widget.post.user.profilePicture)
                          : AssetImage('assets/images/defaultprofilepic.png')
                              as ImageProvider,
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
                ),
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
  if (loggedInUserId == null) return;

  final alreadyLiked = widget.post.likes?.contains(loggedInUserId) ?? false;

  setState(() {
    isHeartAnimating = true;
    isLiked = !alreadyLiked;
    if (alreadyLiked) {
      widget.post.likes?.remove(loggedInUserId);
    } else {
      widget.post.likes?.add(loggedInUserId!);
    }
  });

  try {
    await likePost(widget.post.id, loggedInUserId!);
  } catch (e) {
    print("Failed to like post on double tap: $e");
  }
}

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
  if (loggedInUserId == null) return;

  final alreadyLiked = widget.post.likes?.contains(loggedInUserId) ?? false;

  setState(() {
    isLiked = !alreadyLiked;
    if (alreadyLiked) {
      widget.post.likes?.remove(loggedInUserId);
    } else {
      widget.post.likes?.add(loggedInUserId!);
    }
  });

  try {
    await likePost(widget.post.id, loggedInUserId!);
  } catch (e) {
    print("Failed to like post: $e");
    // Revert the like state on failure
    setState(() {
      if (alreadyLiked) {
        widget.post.likes?.add(loggedInUserId!);
      } else {
        widget.post.likes?.remove(loggedInUserId);
      }
      isLiked = alreadyLiked;
    });
  }
}

                ),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            entityId: widget.post.id,
                            entityType: 'post',
                          ),
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
                          text: widget.post.description ?? '',
                        ),
                      ])),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        entityId: widget.post.id,
                        entityType: 'post',
                      ),
                    ),
                  ),
                  child: Text(
                    "view all comments",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 179, 179, 172)),
                  ),
                ),
                Text(
                  formattedDateTime(widget.post.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
