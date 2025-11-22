import 'package:flutter/material.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';
import 'package:pnirdlab/pages/comments_screen.dart';
import 'package:pnirdlab/widgets/heart_animation_widget.dart';
import 'package:intl/intl.dart';
import 'package:pnirdlab/services/like_service.dart';
import 'package:pnirdlab/pages/current_user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/pages/public_profile_page.dart';

class OptimizedPostCard extends StatefulWidget {
  final Post post;
  const OptimizedPostCard({super.key, required this.post});

  @override
  _OptimizedPostCardState createState() => _OptimizedPostCardState();
}

String formattedDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
}

class _OptimizedPostCardState extends State<OptimizedPostCard> {
  bool isLiked = false;
  bool isHeartAnimating = false;
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (mounted) {
      setState(() {
        loggedInUserId = userId;
        isLiked = widget.post.likes?.contains(userId) ?? false;
      });
    }
  }

  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile picture and username
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => _navigateToProfile(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (widget.post.user.profilePicture != null && 
                                    widget.post.user.profilePicture!.isNotEmpty)
                        ? NetworkImage(widget.post.user.profilePicture!)
                        : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDateTime(widget.post.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Post content
          if (widget.post.description != null && widget.post.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.post.description!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Post image
          if (widget.post.img != null && widget.post.img!.isNotEmpty)
            GestureDetector(
              onDoubleTap: _toggleLike,
              child: Center(
                child: OptimizedImage(
                  imageUrl: widget.post.img!,
                  height: 400, // Standardized height
                  fit: BoxFit.contain,
                placeholder: Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
                ),
              ),
            ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      isHeartAnimating
                          ? HeartAnimationWidget(
                              isAnimating: true,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 24,
                              ),
                            )
                          : Icon(
                              isLiked ? Icons.favorite : Icons.favorite_outline,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.post.likes?.length ?? 0}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _navigateToComments,
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.post.comments?.length ?? 0}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() async {
    if (loggedInUserId == null) return;

    setState(() {
      isHeartAnimating = true;
    });

    try {
      await likePost(widget.post.id, loggedInUserId!);
      setState(() {
        isLiked = !isLiked;
        if (isLiked) {
          widget.post.likes?.add(loggedInUserId!);
        } else {
          widget.post.likes?.remove(loggedInUserId!);
        }
      });
    } catch (e) {
      // Handle error silently
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            isHeartAnimating = false;
          });
        }
      });
    }
  }

  void _navigateToComments() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          entityId: widget.post.id,
          entityType: 'post',
        ),
      ),
    );
    
    // If a comment was added, refresh the post data
    if (result == true) {
      // You could add a callback here to refresh the post data
      // For now, we'll just trigger a rebuild
      setState(() {});
    }
  }

  void _navigateToProfile() async {
    String clickedUserId = widget.post.user.id;
    
    if (loggedInUserId == null) {
      loggedInUserId = await getLoggedInUserId();
    }
    
    if (loggedInUserId != null && clickedUserId == loggedInUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(myuserId: clickedUserId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PublicProfilePage(userId: clickedUserId),
        ),
      );
    }
  }
}
