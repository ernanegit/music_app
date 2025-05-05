# Script para criar o serviço de autenticação e API base
# Executar no diretório raiz do projeto Flutter

# Definir caminhos dos arquivos
$apiServicePath = ".\lib\services\api_service.dart"
$authServicePath = ".\lib\services\auth_service.dart"
$userModelPath = ".\lib\models\user.dart"

# Conteúdo do api_service.dart
$apiServiceContent = @"
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Headers padrão para requisições
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer \$token',
    };
  }

  // GET
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(ApiConfig.baseUrl + endpoint).replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())),
    );

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on HttpException {
      throw ApiException('Erro de requisição HTTP');
    } on FormatException {
      throw ApiException('Formato de resposta inválido');
    } catch (e) {
      throw ApiException('Erro inesperado: \${e.toString()}');
    }
  }

  // POST
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(ApiConfig.baseUrl + endpoint);

    try {
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on HttpException {
      throw ApiException('Erro de requisição HTTP');
    } on FormatException {
      throw ApiException('Formato de resposta inválido');
    } catch (e) {
      throw ApiException('Erro inesperado: \${e.toString()}');
    }
  }

  // PUT
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(ApiConfig.baseUrl + endpoint);

    try {
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on HttpException {
      throw ApiException('Erro de requisição HTTP');
    } on FormatException {
      throw ApiException('Formato de resposta inválido');
    } catch (e) {
      throw ApiException('Erro inesperado: \${e.toString()}');
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(ApiConfig.baseUrl + endpoint);

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.requestTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on HttpException {
      throw ApiException('Erro de requisição HTTP');
    } on FormatException {
      throw ApiException('Formato de resposta inválido');
    } catch (e) {
      throw ApiException('Erro inesperado: \${e.toString()}');
    }
  }

  // Manipular resposta
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      // Tentar extrair mensagem de erro da resposta
      String errorMessage = 'Erro desconhecido';
      try {
        final body = json.decode(response.body);
        if (body.containsKey('error') && body['error'].containsKey('message')) {
          errorMessage = body['error']['message'];
        } else if (body.containsKey('message')) {
          errorMessage = body['message'];
        }
      } catch (_) {
        errorMessage = 'Erro \${response.statusCode}';
      }

      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  // Salvar token de autenticação
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Obter token de autenticação
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Remover token de autenticação
  Future<void> removeToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
"@

# Conteúdo do auth_service.dart
$authServiceContent = @"
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
      await _apiService.get(ApiConfig.login + '/logout');
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
"@

# Conteúdo do user.dart
$userModelContent = @"
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final Location? location;
  final String profileImage;
  final String userType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    required this.profileImage,
    required this.userType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      profileImage: json['profileImage'] ?? 'default-profile.jpg',
      userType: json['userType'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location?.toJson(),
      'profileImage': profileImage,
      'userType': userType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final String? city;
  final String? state;
  final String country;

  Location({
    this.city,
    this.state,
    this.country = 'Brasil',
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      state: json['state'],
      country: json['country'] ?? 'Brasil',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
    };
  }
}
"@

# Função para criar arquivos (usando verbo aprovado)
function New-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [string]$Content
    )
    
    if ([string]::IsNullOrEmpty($Path)) {
        Write-Host "ERRO: O caminho do arquivo não pode ser vazio." -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path -Path $Path)) {
        try {
            # Criar diretório pai se não existir
            $parentDir = Split-Path -Path $Path -Parent
            if (-not (Test-Path -Path $parentDir)) {
                New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
                Write-Host "Diretório criado: $parentDir" -ForegroundColor Green
            }
            
            New-Item -Path $Path -ItemType File -Force | Out-Null
            Set-Content -Path $Path -Value $Content
            Write-Host "Arquivo criado: $Path" -ForegroundColor Green
        }
        catch {
            Write-Host "ERRO ao criar arquivo $Path : $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Arquivo já existe: $Path, substituindo conteúdo..." -ForegroundColor Yellow
        Set-Content -Path $Path -Value $Content
    }
}

# Verificar caminhos válidos
if ([string]::IsNullOrEmpty($apiServicePath)) {
    Write-Host "ERRO: O caminho para o arquivo api_service.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($authServicePath)) {
    Write-Host "ERRO: O caminho para o arquivo auth_service.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($userModelPath)) {
    Write-Host "ERRO: O caminho para o arquivo user.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

# Criar os arquivos
New-File -Path $apiServicePath -Content $apiServiceContent
New-File -Path $authServicePath -Content $authServiceContent
New-File -Path $userModelPath -Content $userModelContent

Write-Host "Arquivos de serviço e modelo criados com sucesso!" -ForegroundColor Cyan