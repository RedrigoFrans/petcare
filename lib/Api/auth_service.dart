import 'dart:convert';
import 'package:http/http.dart' as http;

// Model untuk Customer
class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

// Model untuk Response API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(Map<String, dynamic>?)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class AuthService {
  // ✅ Ganti dengan URL Laravel server Anda
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Headers default untuk semua request
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ✅ Login function yang diperbaiki
  Future<ApiResponse<Customer>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      print('Login request to: $url'); // Debug log
      print('Email: $email'); // Debug log (jangan log password!)
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response Status: ${response.statusCode}'); // Debug log
      print('Login Response Body: ${response.body}'); // Debug log

      // ✅ Parse response JSON dengan error handling
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        print('JSON Parse Error: $e'); // Debug log
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      if (response.statusCode == 200) {
        // ✅ Success - parse customer data dengan null safety
        Customer? customer;
        if (responseBody['data'] != null) {
          try {
            customer = Customer.fromJson(responseBody['data']);
          } catch (e) {
            print('Customer Parse Error: $e'); // Debug log
            return ApiResponse<Customer>(
              success: false,
              message: 'Failed to parse customer data',
            );
          }
        }

        return ApiResponse<Customer>(
          success: true,
          message: responseBody['message'] ?? 'Login berhasil',
          data: customer,
        );
      } else {
        // ✅ Error from server
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Login gagal',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Login Error: $e'); // Debug log
      // ✅ Network atau error lainnya
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah. Periksa internet Anda.',
      );
    }
  }

  // ✅ Register function
  Future<ApiResponse<Customer>> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    
    try {
      print('Register request to: $url'); // Debug log
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Register Response Status: ${response.statusCode}'); // Debug log
      print('Register Response Body: ${response.body}'); // Debug log

      // Parse response JSON dengan error handling
      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        print('JSON Parse Error: $e'); // Debug log
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      if (response.statusCode == 201) {
        // Success - parse customer data
        Customer? customer;
        if (responseBody['data'] != null) {
          try {
            customer = Customer.fromJson(responseBody['data']);
          } catch (e) {
            print('Customer Parse Error: $e'); // Debug log
            return ApiResponse<Customer>(
              success: false,
              message: 'Failed to parse customer data',
            );
          }
        }

        return ApiResponse<Customer>(
          success: true,
          message: responseBody['message'] ?? 'Registrasi berhasil',
          data: customer,
        );
      } else {
        // Error from server
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Registrasi gagal',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Register Error: $e'); // Debug log
      // Network atau error lainnya
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah. Periksa internet Anda.',
      );
    }
  }

  // ✅ Logout function (jika diperlukan)
  Future<ApiResponse<void>> logout() async {
    // Implementasi logout jika ada endpoint
    return ApiResponse<void>(
      success: true,
      message: 'Logout berhasil',
    );
  }
}