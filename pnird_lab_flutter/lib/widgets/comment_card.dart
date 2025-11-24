// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pnirdlab/model/comment_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final Function(String) onReply; // Callback for replying to a comment

  const CommentCard({super.key, required this.comment, required this.onReply});

  String formattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  Future<String?> _getUserProfilePicture(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/username/$username'),
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return userData['profilePicture'];
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (comment.profilePicture != null && 
                                comment.profilePicture!.isNotEmpty && 
                                comment.profilePicture!.startsWith('http'))
                    ? NetworkImage(comment.profilePicture!)
                    : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error silently
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.comment,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formattedDateTime(comment.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => onReply(comment.id), // Trigger reply
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Reply',
                    style: TextStyle(color: Color(0xffFFC700)),
                  ),
                ),
              ),
            ],
          ),
          // Display replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Row(
                    children: [
                      FutureBuilder<String?>(
                        future: _getUserProfilePicture(reply.username),
                        builder: (context, snapshot) {
                          String? profilePicture = reply.profilePicture ?? snapshot.data;
                          
                          return CircleAvatar(
                            radius: 16,
                            backgroundImage: (profilePicture != null && 
                                            profilePicture.isNotEmpty && 
                                            profilePicture.startsWith('http'))
                                ? NetworkImage(profilePicture)
                                : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              // Handle image loading error silently
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reply.comment,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  formattedDateTime(reply.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
