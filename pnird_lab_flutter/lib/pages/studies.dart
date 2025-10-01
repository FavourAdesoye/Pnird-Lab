import 'package:flutter/material.dart';
import '../model/study_model.dart';
import '../services/studies_service.dart';
import 'package:pnirdlab/pages/studies_details.dart';
import 'package:pnirdlab/pages/new_study_page.dart';
import 'package:pnirdlab/widgets/studies_card.dart';

class StudiesPage extends StatefulWidget {
  const StudiesPage({super.key});

  @override
  _StudiesPageState createState() => _StudiesPageState();
}

class _StudiesPageState extends State<StudiesPage> {
  List<Study> _studies = []; // Maintain the studies list
  bool _isLoading = true; // Track loading state
  String _errorMessage = ''; // Track error messages

  @override
  void initState() {
    super.initState();
    _fetchStudies(); // Fetch studies on page load
  }

  Future<void> _fetchStudies() async {
    try {
      final studies = await StudiesApi.fetchStudies();
      setState(() {
        _studies = studies;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studies'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage'))
              : _studies.isEmpty
                  ? const Center(child: Text('No studies available.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: _studies.length,
                      itemBuilder: (context, index) {
                        final study = _studies[index];
                        return StudiesCard(
                          imageUrl: study.imageUrl,
                          titlePost: study.titlePost,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudyDetailsPage(study: study),
                              ),
                            );
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        heroTag: const Text('btn2'),
        onPressed: () async {
          final newStudy = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewStudyPage()),
          );

          if (newStudy != null) {
            setState(() {
              _studies.add(newStudy); // Append the new study to the list
            });
          }
        },
        tooltip: 'Create New Study',
        child: const Icon(Icons.add),
      ),
    );
  }
}
