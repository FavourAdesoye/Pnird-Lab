import 'package:flutter/material.dart';
import '../model/study_model.dart'; // Import your Study model
import 'form_viewer_page.dart';

class StudyDetailsPage extends StatelessWidget {
  final Study study;

  // Constructor to accept the study object
  const StudyDetailsPage({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(study.titlePost),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              const SizedBox(height: 16),

              // Title
              Text(
                study.titlePost,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                study.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Post ID

              // Created At
              Text(
                "Created At: ${study.createdAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),

              // Updated At
              Text(
                "Last Updated: ${study.updatedAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Form Link Button (only show if formLink exists)
              if (study.formLink != null && study.formLink!.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormViewerPage(
                            formUrl: study.formLink!,
                            studyTitle: study.titlePost,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('Fill Out Survey'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
