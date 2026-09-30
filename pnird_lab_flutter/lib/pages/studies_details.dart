import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/study_model.dart'; // Import your Study model
import 'form_viewer_page.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/services/session_storage.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';
import 'edit_study_page.dart';

class StudyDetailsPage extends StatefulWidget {
  final Study study;

  // Constructor to accept the study object
  const StudyDetailsPage({super.key, required this.study});

  @override
  State<StudyDetailsPage> createState() => _StudyDetailsPageState();
}

class _StudyDetailsPageState extends State<StudyDetailsPage> {
  bool _isStaff = false;
  bool _deleting = false;
  bool _changed = false;
  late Study _study;

  Study get study => _study;

  @override
  void initState() {
    super.initState();
    _study = widget.study;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final staff = await SessionStorage.isStaff();
    if (!mounted) return;
    setState(() => _isStaff = staff);
  }

  Future<void> _deleteStudy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete study?'),
        content: const Text('This permanently removes the study. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can delete studies.')),
      );
      return;
    }

    setState(() => _deleting = true);
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/studies/${study.id}'),
        headers: await ApiService.authHeaders(),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 403
                ? 'Only staff can delete studies.'
                : 'Could not delete study (${response.statusCode}).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete study. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _editStudy() async {
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can edit studies.')),
      );
      return;
    }
    if (!mounted) return;
    final updated = await Navigator.push<Study>(
      context,
      MaterialPageRoute(builder: (context) => EditStudyPage(study: _study)),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _study = updated;
      _changed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(study.titlePost),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _changed),
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
                child: OptimizedImage(
                  imageUrl: study.imageUrl,
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
              if (_isStaff) ...[
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _editStudy,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit study'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _deleteStudy,
                    icon: _deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(_deleting ? 'Deleting…' : 'Delete study'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
