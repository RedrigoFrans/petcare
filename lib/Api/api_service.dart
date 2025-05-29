import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Configuration for product/order API
  static const String _baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api';
  static const bool debugMode = true;
  
  // Configuration for petcare users API
  final String _petcareBaseUrl = 'https://webfw23.myhost.id/gol_e5/petcare/users';

  // Headers default
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-App/1.0',
  };

  // Product-related methods
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      if (debugMode) {
        print('Fetching products from: $_baseUrl/products');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: defaultHeaders,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (debugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        
        // Check if response is empty
        if (responseBody.trim().isEmpty) {
          throw Exception('Empty response from server');
        }

        // Parse JSON with better error handling
        dynamic jsonData;
        try {
          jsonData = json.decode(responseBody);
        } catch (e) {
          if (debugMode) {
            print('JSON decode error: $e');
            print('Response body that failed to parse: $responseBody');
          }
          throw Exception('Invalid JSON response from server');
        }

        // Handle both simple list response and structured response
        if (jsonData is List) {
          // Simple list response
          return jsonData.map<Map<String, dynamic>>((item) {
            final product = Map<String, dynamic>.from(item);
            product['price'] = double.tryParse(product['price'].toString()) ?? 0.0;
            return product;
          }).toList();
        } else if (jsonData is Map<String, dynamic>) {
          // Structured response with status/data
          final Map<String, dynamic> responseMap = jsonData;

          // Check response status
          if (responseMap['status'] != null && responseMap['status'] != 'success') {
            throw Exception('API returned error: ${responseMap['message'] ?? 'Unknown error'}');
          }

          // Get products data
          final dynamic productsData = responseMap['data'] ?? responseMap;
          
          if (productsData == null) {
            if (debugMode) print('No products data in response');
            return [];
          }

          if (productsData is! List) {
            throw Exception('Expected products data to be a list, got ${productsData.runtimeType}');
          }

          // Convert to List<Map<String, dynamic>> with validation
          final List<Map<String, dynamic>> products = [];
          
          for (int i = 0; i < productsData.length; i++) {
            final dynamic item = productsData[i];
            
            if (item is! Map<String, dynamic>) {
              if (debugMode) {
                print('Skipping invalid product at index $i: ${item.runtimeType}');
              }
              continue;
            }

            final Map<String, dynamic> product = Map<String, dynamic>.from(item);
            
            // Validate required fields
            if (product['id'] == null || product['name'] == null) {
              if (debugMode) {
                print('Skipping product with missing required fields: $product');
              }
              continue;
            }

            // Normalize data
            product['id'] = _parseToInt(product['id']);
            product['name'] = product['name']?.toString() ?? 'Unknown Product';
            product['price'] = _parsePrice(product['price']);
            product['description'] = product['description']?.toString() ?? 'No description available';
            product['image_url'] = product['image_url']?.toString();
            product['image'] = product['image']?.toString();

            products.add(product);
          }

          if (debugMode) {
            print('Successfully parsed ${products.length} products');
          }

          return products;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException catch (e) {
      if (debugMode) print('Network error: $e');
      throw Exception('Network error: Please check your internet connection');
    } on HttpException catch (e) {
      if (debugMode) print('HTTP error: $e');
      throw Exception('Server error: ${e.message}');
    } on FormatException catch (e) {
      if (debugMode) print('Format error: $e');
      throw Exception('Invalid data format from server');
    } catch (e) {
      if (debugMode) print('Unexpected error: $e');
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getProduct(int id) async {
    try {
      if (debugMode) {
        print('Fetching product $id from: $_baseUrl/products/$id');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: defaultHeaders,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (debugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final Map<String, dynamic> responseMap = jsonData;

        if (responseMap['status'] != null && responseMap['status'] != 'success') {
          throw Exception('API returned error: ${responseMap['message'] ?? 'Unknown error'}');
        }

        final dynamic productData = responseMap['data'] ?? responseMap;
        
        if (productData == null || productData is! Map<String, dynamic>) {
          return null;
        }

        final Map<String, dynamic> product = Map<String, dynamic>.from(productData);
        
        // Normalize data
        product['id'] = _parseToInt(product['id']);
        product['name'] = product['name']?.toString() ?? 'Unknown Product';
        product['price'] = _parsePrice(product['price']);
        product['description'] = product['description']?.toString() ?? 'No description available';
        product['image_url'] = product['image_url']?.toString();

        return product;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (debugMode) print('Error fetching product: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required String address,
    XFile? pickedFile,
    Uint8List? webImage,
    String? fileName,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/orders'));
      
      List<Map<String, dynamic>> itemsForApi = cartItems.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'price': item['price'],
            'quantity': item['quantity'],
          };
        }).toList();
      request.fields['cartItems'] = json.encode(itemsForApi);
      request.fields['address'] = address;

      if (kIsWeb) {
        if (webImage != null && fileName != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'payment_proof',
            webImage,
            filename: fileName,
          ));
        } else {
           throw Exception('Web image or filename is null for web platform.');
        }
      } else {
        if (pickedFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'payment_proof',
            pickedFile.path,
          ));
        } else {
          throw Exception('PickedFile is null for mobile platform.');
        }
      }
      
      if (debugMode) {
        print('Sending order request: ${request.fields}');
        if (request.files.isNotEmpty) {
          print('With payment proof: ${request.files.first.filename}');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (debugMode) {
        print('Order response status: ${response.statusCode}');
        print('Order response body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        String errorMessage = 'Failed to create order. Status: ${response.statusCode}';
        try {
          var decodedBody = json.decode(response.body);
          if (decodedBody['error'] != null) {
            errorMessage += '. Error: ${decodedBody['error']}';
          } else if (decodedBody['errors'] != null) {
             errorMessage += '. Validation Errors: ${json.encode(decodedBody['errors'])}';
          } else {
            errorMessage += '. Body: ${response.body}';
          }
        } catch (e) {
          errorMessage += '. Body: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (debugMode) print('Error creating order: $e');
      throw Exception('Error creating order: $e');
    }
  }

  // Petcare user-related methods
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_petcareBaseUrl/users'),
        headers: defaultHeaders,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      if (debugMode) print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Test connection method
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: defaultHeaders,
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      if (debugMode) print('Connection test failed: $e');
      return false;
    }
  }

  // Helper methods for data parsing
  int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  dynamic _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) {
      // Remove currency symbols and parse
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }
}