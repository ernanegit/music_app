import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    // Salvar token
    if (response['token'] != null) {
      await _apiService.saveToken(response['token']);
    }

    // Salvar dados do usuário
    if (response['data'] != null && response['data']['user'] != null) {
      await _saveUserData(response['data']['user']);
    }

    return response;
  }

  // Registro
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? phone,
    Map<String, String>? location,
  }) async {
    final response = await _apiService.post(
      ApiConfig.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'userType': userType,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
      },
    );

    // Salvar token
    if (response['token'] != null) {
      await _apiService.saveToken(response['token']);
    }

    // Salvar dados do usuário
    if (response['data'] != null && response['data']['user'] != null) {
      await _saveUserData(response['data']['user']);
    }

    return response;
  }

  // Obter perfil do usuário
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _apiService.get(ApiConfig.userProfile);
    
    // Salvar dados do usuário
    if (response['data'] != null && response['data']['user'] != null) {
      await _saveUserData(response['data']['user']);
    }
    
    return response;
  }

  // Atualizar perfil do usuário
  Future<User> updateUserProfile({
    String? name,
    String? phone,
    Map<String, String>? location,
    String? profileImage,
  }) async {
    final response = await _apiService.put(
      ApiConfig.updateProfile,
      body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
        if (profileImage != null) 'profileImage': profileImage,
      },
    );

    // Salvar dados atualizados
    if (response['data'] != null && response['data']['user'] != null) {
      await _saveUserData(response['data']['user']);
      return User.fromJson(response['data']['user']);
    }

    throw ApiException('Erro ao atualizar perfil');
  }

  // Solicitar redefinição de senha
  Future<bool> forgotPassword(String email) async {
    await _apiService.post(
      ApiConfig.forgotPassword,
      body: {'email': email},
    );
    
    return true;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.get('${ApiConfig.login}/logout');
    } catch (_) {
      // Ignorar erros durante o logout
    }
    
    // Limpar token e dados salvos
    await _apiService.removeToken();
    await _clearUserData();
  }

  // Verificar se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  // Obter dados do usuário salvos localmente
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    
    return null;
  }

  // Salvar dados do usuário localmente
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Limpar dados do usuário
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}