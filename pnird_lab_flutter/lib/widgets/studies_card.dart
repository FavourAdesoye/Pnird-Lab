import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudiesCard extends StatelessWidget {
  final String imageUrl;
  final String titlePost;
  final VoidCallback onTap;

  const StudiesCard({
    super.key,
    required this.imageUrl,
    required this.titlePost,
    required this.onTap, // Add onTap callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              titlePost,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller text
                  color: Colors.black),
              textAlign: TextAlign.center,
              overflow:
                  TextOverflow.ellipsis, // Adds ellipsis if text is too long
            ),
          ],
        ),
      ),
    );
  }
}
