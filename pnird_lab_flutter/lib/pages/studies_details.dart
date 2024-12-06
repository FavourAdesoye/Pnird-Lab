import 'package:flutter/material.dart';
import '../model/study_model.dart'; // Import your Study model

class StudyDetailsPage extends StatelessWidget {
  final Study study;

  // Constructor to accept the study object
  const StudyDetailsPage({Key? key, required this.study}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(study.titlePost),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Study Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  study.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),

              // Title
              Text(
                study.titlePost,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Description
              Text(
                study.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Post ID

              // Created At
              Text(
                "Created At: ${study.createdAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),

              // Updated At
              Text(
                "Last Updated: ${study.updatedAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
