// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnird_lab_flutter/widgets/heart_animation_widget.dart';

class PostCard extends StatefulWidget {
  @override
  _PostCardState createState() => _PostCardState();
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
                          'Dr. Larry Keen', //replace with username of someone
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/pnird_group_photo.jpg",
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
            onDoubleTap: () {
              setState(() {
                isHeartAnimating = true;
                isLiked = true;
              });
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
                  onPressed: () => setState(() => isLiked = !isLiked),
                ),
              ),
              IconButton(
                  onPressed: () {},
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
                      '80 likes',
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
                          text: 'Dr. Larry-Keen',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              '   We had a great time at the national psychology conference',
                        ),
                      ])),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "view all comments",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 179, 179, 172)),
                  ),
                ),
                Container(
                    child: Text(
                  "2 days ago",
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
