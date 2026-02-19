import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiService {

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${AppConstants.token}',
    'token': AppConstants.token,
    'x-access-token': AppConstants.token,
    'Content-Type': 'application/json',
  };

  /// GET All Categories
  static Future<List<dynamic>> getCategories() async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/api/categories');
      print('🔵 GET Categories URL: $uri');

      final response = await http.get(uri, headers: _headers);

      print('🟡 Categories Status: ${response.statusCode}');
      print('🟡 Categories Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map) {
          if (data['data'] != null) return data['data'];
          if (data['categories'] != null) return data['categories'];
          if (data['result'] != null) return data['result'];
        }
        return [];
      }
      throw Exception('Status ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('🔴 Exception in getCategories: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getSubCategories(String categoryId) async {
    try {
      final uri =
      Uri.parse('${AppConstants.baseUrl}/api/categories/$categoryId');
      print('🔵 GET SubCategories URL: $uri');

      final response = await http.get(uri, headers: _headers);

      print('🟡 SubCategories Status: ${response.statusCode}');
      print('🟡 SubCategories Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle all possible response shapes
        if (data is List) return data;
        if (data is Map) {
          if (data['subCategories'] != null) return data['subCategories'];
          if (data['data'] != null) {
            // data['data'] could be the category object itself
            // with subCategories inside
            if (data['data'] is List) return data['data'];
            if (data['data'] is Map && data['data']['subCategories'] != null) {
              return data['data']['subCategories'];
            }
          }
          if (data['result'] != null) return data['result'];
        }
        return [];
      }
      throw Exception('Status ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('🔴 Exception in getSubCategories: $e');
      rethrow;
    }
  }


  static Future<Map<String, dynamic>> createService({
    required String serviceName,
    required String description,
    required String category,
    required String subCategory,
    required String price,
    required String duration,
    required String startTime,
    required String endTime,
    required List<String> availabilityDates,
    File? imageFile,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/api/providers/services');

      // ✅ If image selected → try multipart first
      if (imageFile != null) {
        print('🔵 Sending multipart with image');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer ${AppConstants.token}';

        request.fields['serviceName'] = serviceName;
        request.fields['description'] = description;
        request.fields['category'] = category;
        request.fields['subCategory'] = subCategory;
        request.fields['price'] = price.trim();
        request.fields['duration'] = duration.trim();
        request.fields['startTime'] = startTime;
        request.fields['endTime'] = endTime;

        for (int i = 0; i < availabilityDates.length; i++) {
          request.fields['availability[$i][date]'] = availabilityDates[i];
        }

        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        print('🔵 Fields: ${request.fields}');

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        print('🟡 Multipart Status: ${response.statusCode}');
        print('🟡 Multipart Body: ${response.body}');

        // ✅ If multipart works → return
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        }

        // ❌ If multipart fails → fall through to JSON
        print('⚠️ Multipart failed, falling back to JSON...');
      }

      // ✅ JSON fallback (confirmed working) — with image filename if available
      final bodyMap = <String, dynamic>{
        'serviceName': serviceName,
        'description': description,
        'category': category,
        'subCategory': subCategory,
        'price': int.tryParse(price.trim()) ?? 0,
        'duration': int.tryParse(duration.trim()) ?? 0,
        'startTime': startTime,
        'endTime': endTime,
        'availability': availabilityDates.map((d) => {'date': d}).toList(),
        // ✅ Send image filename as per assignment spec: "image": "image.png"
        if (imageFile != null)
          'image': imageFile.path.split('/').last,
      };

      print('🔵 JSON body: ${jsonEncode(bodyMap)}');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${AppConstants.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      );

      print('🟡 Status: ${response.statusCode}');
      print('🟡 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw Exception('Status ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('🔴 Exception in createService: $e');
      rethrow;
    }
  }







  /// GET All Services
  static Future<List<dynamic>> getServices() async {
    try {
      final uri =
      Uri.parse('${AppConstants.baseUrl}/api/providers/services');
      print('🔵 GET Services URL: $uri');
      print('🔵 Headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('🟡 Status Code: ${response.statusCode}');
      print('🟡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🟢 Data type: ${data.runtimeType}');

        if (data is List) return data;
        if (data is Map) {
          if (data['data'] != null) return data['data'];
          if (data['services'] != null) return data['services'];
          if (data['result'] != null) return data['result'];
        }
        return [];
      }
      throw Exception('Status ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('🔴 Exception in getServices: $e');
      rethrow;
    }
  }
}
