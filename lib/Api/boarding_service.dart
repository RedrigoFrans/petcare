// boarding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BoardingService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static Future<Map<String, dynamic>> getAllBoardings({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('$baseUrl/boardings').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load boardings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createBoarding(Map<String, dynamic> data) async {
    try {
      print('Sending boarding data: ${json.encode(data)}'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/boardings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 422) {
        // Validation errors
        final errorData = json.decode(response.body);
        throw Exception('Validation error: ${errorData['message'] ?? 'Invalid data'}');
      } else {
        throw Exception('Failed to create boarding: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the server is running on http://127.0.0.1:8000');
      }
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> updateBoardingStatus(int id, String status, {String? notes}) async {
    try {
      final data = {'status': status};
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;
      
      final response = await http.patch(
        Uri.parse('$baseUrl/boardings/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getBoardingStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/boardings/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<void> deleteBoarding(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/boardings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete boarding: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getBoardingById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/boardings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load boarding: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, dynamic>> updateBoarding(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/boardings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception('Validation error: ${errorData['message'] ?? 'Invalid data'}');
      } else {
        throw Exception('Failed to update boarding: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}