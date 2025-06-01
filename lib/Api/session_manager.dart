import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart'; // For Customer model, adjust path if necessary

class SessionManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _customerDataKey = 'customerData';
  static const String _authTokenKey = 'authToken';

  // Saves session data (customer info and token)
  Future<void> saveSession(Customer customer, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_customerDataKey, jsonEncode(customer.toJson()));
    if (token != null) {
      await prefs.setString(_authTokenKey, token);
    } else {
      // Clear old token if new login doesn't provide one
      await prefs.remove(_authTokenKey);
    }
  }

  // Retrieves the stored Customer data
  Future<Customer?> getCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson = prefs.getString(_customerDataKey);
    if (customerJson != null) {
      try {
        return Customer.fromJson(jsonDecode(customerJson));
      } catch (e) {
        print("Error deserializing customer data: $e");
        // Clear potentially corrupted data
        await clearSession();
        return null;
      }
    }
    return null;
  }

  // Retrieves the stored authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Checks if a user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clears all session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_customerDataKey);
    await prefs.remove(_authTokenKey);
    print("Session cleared");
  }
}