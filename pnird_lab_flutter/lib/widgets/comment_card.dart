// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pnirdlab/model/comment_model.dart';
import 'package:pnirdlab/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  String formattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          UserAvatar(filename: "drKeen.jpg"),
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
                  const SizedBox(
                      height: 4), // Optional space between username and comment
                  Text(
                    comment.comment,
                    style: const TextStyle(
                        color: Color.fromARGB(
                            255, 255, 255, 255)), // Keep it simple
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formattedDateTime(comment.createdAt),
                      style: TextStyle(
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
            onTap: () => {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: const Text(
                'Reply',
                style: TextStyle(color: Color(0xffFFC700)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
