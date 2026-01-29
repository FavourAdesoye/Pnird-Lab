import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/study_model.dart'; // Import your Study model
import 'api_service.dart';

class StudiesApi {
  static String get baseUrl => "${ApiService.baseUrl}/studies";

  // Fetch all studies
  static Future<List<Study>> fetchStudies() async {
    final response = await http.get(Uri.parse('$baseUrl'));
    if (response.statusCode == 200) {
      final List studies = json.decode(response.body);
      return studies.map((study) => Study.fromJson(study)).toList();
    } else {
      throw Exception('Failed to load studies');
    }
  }

  // Add a new study (optional)
  static Future<void> createStudy(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/createstudy'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      // Check for 201 status code
      throw Exception(
        'Failed to create study. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
