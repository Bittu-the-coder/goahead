import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response['success']) {
      await _api.setToken(response['token']);
      await _saveUser(response['user']);
    }

    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success']) {
      await _api.setToken(response['token']);
      await _saveUser(response['user']);
    }

    return response;
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get('/auth/me');
      if (response['success']) {
        final user = User.fromJson(response['user']);
        await _saveUser(response['user']);
        return user;
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(userData));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.tokenKey);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    await _api.put('/auth/preferences', {
      'preferences': preferences.toJson(),
    });
  }
}
