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
      if (token != null) 'Authorization': 'Bearer \',
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
      throw ApiException('Erro inesperado: \');
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
      throw ApiException('Erro inesperado: \');
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
      throw ApiException('Erro inesperado: \');
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
      throw ApiException('Erro inesperado: \');
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
        errorMessage = 'Erro \';
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
