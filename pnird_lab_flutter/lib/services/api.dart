import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Api {
  static const baseUrl = "http://10.0.0.32/api/";

  static createPost(Map pdata) async {
    var url = Uri.parse("${baseUrl}createpost");
    try {
      final res = await http.post(url, body: pdata);

      if (res.statusCode == 200) {
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
