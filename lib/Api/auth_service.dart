import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart'; // ✅ Import SessionManager

// Model untuk Customer
class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  // final String? profileImageUrl; // Optional: if your API returns profile image URL

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    // this.profileImageUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      // profileImageUrl: json['profile_image_url'], // Optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      // 'profile_image_url': profileImageUrl, // Optional
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
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // ✅ Ganti dengan URL Laravel server Anda
  final SessionManager _sessionManager = SessionManager(); // ✅ Instance of SessionManager

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _headersWithAuth() async {
    final headers = Map<String, String>.from(_headers);
    final token = await _sessionManager.getToken(); // ✅ Get token from SessionManager
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse<Customer>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      print('Login request to: $url');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      // ✅ Check for 'success: true' from your API structure
      if (response.statusCode == 200 && responseBody['success'] == true) {
        Customer? customer;
        String? token; // ✅ Variable to hold the token

        // ✅ Assuming 'data' contains the customer object
        if (responseBody['data'] != null) {
          try {
            customer = Customer.fromJson(responseBody['data']);
          } catch (e) {
            print('Customer Parse Error: $e');
            return ApiResponse<Customer>(
              success: false,
              message: 'Failed to parse customer data',
            );
          }
        }

        // ✅ Attempt to extract token (adjust key 'token' if different in your API)
        if (responseBody['token'] != null && responseBody['token'] is String) {
            token = responseBody['token'] as String;
        }
        // Example if token is inside data:
        // else if (responseBody['data'] != null && responseBody['data']['token'] != null) {
        //   token = responseBody['data']['token'] as String;
        // }

        if (customer != null) {
          await _sessionManager.saveSession(customer, token); // ✅ Save session and token
          print('Login successful, token: $token'); // Debug
          return ApiResponse<Customer>(
            success: true,
            message: responseBody['message'] ?? 'Login berhasil',
            data: customer,
          );
        } else {
          return ApiResponse<Customer>(
            success: false,
            message: responseBody['message'] ?? 'Login gagal: Data pengguna tidak ditemukan.',
          );
        }
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Login gagal: ${response.statusCode}',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Login Error: $e');
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah. Periksa internet Anda.',
      );
    }
  }

  Future<ApiResponse<Customer>> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    try {
      print('Get Profile request to: $url');
      final headers = await _headersWithAuth(); // ✅ Uses token if available
      final response = await http.get(url, headers: headers);

      print('Get Profile Response Status: ${response.statusCode}');
      print('Get Profile Response Body: ${response.body}');

      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server (profile)',
        );
      }

      if (response.statusCode == 200) {
        Customer? customer;
         // ✅ Assuming your /profile endpoint returns customer data directly in 'data'
        if (responseBody['data'] != null) {
          try {
            customer = Customer.fromJson(responseBody['data']);
            // Optionally update the stored customer data if it can change
            // String? currentToken = await _sessionManager.getToken();
            // await _sessionManager.saveSession(customer!, currentToken);
          } catch (e) {
            print('Customer Parse Error (Profile): $e');
            return ApiResponse<Customer>(
              success: false,
              message: 'Failed to parse profile data',
            );
          }
        }
        return ApiResponse<Customer>(
          success: true,
          message: responseBody['message'] ?? 'Profile loaded successfully',
          data: customer,
        );
      } else if (response.statusCode == 401) {
        await _sessionManager.clearSession(); // ✅ Clear session on unauthorized
        return ApiResponse<Customer>(
          success: false,
          message: 'Sesi berakhir. Silakan login kembali.', // Session expired
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Failed to load profile: ${response.statusCode}',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Get Profile Error: $e');
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah saat mengambil profil.',
      );
    }
  }

  Future<ApiResponse<Customer>> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/profile'); // Assuming PUT to /profile for updates
    try {
      print('Update Profile request to: $url');
      final headers = await _headersWithAuth();
      final response = await http.put( // Or POST, depending on your API
        url,
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
        }),
      );

      print('Update Profile Response Status: ${response.statusCode}');
      print('Update Profile Response Body: ${response.body}');

      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      if (response.statusCode == 200 && responseBody['success'] == true) {
        Customer? customer;
        if (responseBody['data'] != null) {
          try {
            customer = Customer.fromJson(responseBody['data']);
            // ✅ Update the stored customer data after successful profile update
            String? currentToken = await _sessionManager.getToken();
            await _sessionManager.saveSession(customer!, currentToken);
          } catch (e) {
            print('Customer Parse Error (Update Profile): $e');
            return ApiResponse<Customer>(
              success: false,
              message: 'Failed to parse updated customer data',
            );
          }
        }
        return ApiResponse<Customer>(
          success: true,
          message: responseBody['message'] ?? 'Profile updated successfully',
          data: customer,
        );
      } else if (response.statusCode == 401) {
        await _sessionManager.clearSession();
        return ApiResponse<Customer>(
          success: false,
          message: 'Sesi berakhir. Silakan login kembali.',
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Failed to update profile: ${response.statusCode}',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Update Profile Error: $e');
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah. Periksa internet Anda.',
      );
    }
  }

  Future<ApiResponse<void>> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      print('Logout request to: $url');
      final headers = await _headersWithAuth(); // ✅ Send token for server-side logout
      final response = await http.post(url, headers: headers);

      print('Logout Response Status: ${response.statusCode}');
      print('Logout Response Body: ${response.body}');

    } catch (e) {
      print('Logout API Error: $e');
      // Proceed to clear local session even if API call fails
    } finally {
      await _sessionManager.clearSession(); // ✅ Always clear local session
    }
    // Consider logout successful on client-side once local session is cleared
    return ApiResponse<void>(
      success: true,
      message: 'Logout berhasil. Sesi lokal telah dihapus.',
    );
  }

  // ✅ Register function
  // If registration should also log the user in and return a token,
  // you'll need to add session saving logic here similar to the login method.
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
      print('Register request to: $url');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'username': username, // Ensure your backend expects/handles 'username'
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      Map<String, dynamic> responseBody;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        return ApiResponse<Customer>(
          success: false,
          message: 'Invalid response format from server',
        );
      }

      if (response.statusCode == 201 && responseBody['success'] == true) { // Typically 201 Created for register
        Customer? customer;
        String? token;

        if (responseBody['data'] != null) {
          // Check if 'data' contains 'customer' and 'token' or just 'customer'
           var dataContent = responseBody['data'];
           if (dataContent['customer'] != null) {
             customer = Customer.fromJson(dataContent['customer']);
           } else {
             customer = Customer.fromJson(dataContent); // If 'data' is the customer object
           }
            if (dataContent['token'] != null && dataContent['token'] is String) {
              token = dataContent['token'] as String;
            } else if (responseBody['token'] != null && responseBody['token'] is String) {
              token = responseBody['token'] as String; // If token is top-level
            }
        }
        
        if (customer != null && token != null) {
          // If registration logs the user in immediately and provides a token
          await _sessionManager.saveSession(customer, token);
          print('Registration successful and logged in, token: $token');
        } else if (customer != null) {
          // Registration successful but no auto-login/token, user needs to login separately
          print('Registration successful, please login.');
        }

        return ApiResponse<Customer>(
          success: true,
          message: responseBody['message'] ?? 'Registrasi berhasil',
          data: customer,
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: responseBody['message'] ?? 'Registrasi gagal: ${response.statusCode}',
          errors: responseBody['errors'],
        );
      }
    } catch (e) {
      print('Register Error: $e');
      return ApiResponse<Customer>(
        success: false,
        message: 'Koneksi bermasalah. Periksa internet Anda.',
      );
    }
  }
}