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
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    
    final uri = Uri.parse('$baseUrl/boardings').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load boardings');
    }
  }
  
  static Future<Map<String, dynamic>> createBoarding(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/boardings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create boarding: ${response.body}');
    }
  }
  
  static Future<Map<String, dynamic>> updateBoardingStatus(int id, String status, {String? notes}) async {
    final data = {'status': status};
    if (notes != null) data['notes'] = notes;
    
    final response = await http.patch(
      Uri.parse('$baseUrl/boardings/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update status');
    }
  }
  
  static Future<Map<String, dynamic>> getBoardingStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/boardings/statistics'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load statistics');
    }
  }
  
  static Future<void> deleteBoarding(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/boardings/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete boarding');
    }
  }
}