# Script para criar o provider de autenticação
# Executar no diretório raiz do projeto Flutter

# Definir o caminho do arquivo
$authProviderPath = ".\lib\providers\auth_provider.dart"
$authProviderContent = @"
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isMusician => _user?.userType == 'músico';

  // Construtor - verifica autenticação ao iniciar
  AuthProvider() {
    _checkAuthentication();
  }

  // Verificar se o usuário está autenticado
  Future<void> _checkAuthentication() async {
    _setLoading(true);
    try {
      _isAuthenticated = await _authService.isAuthenticated();
      
      if (_isAuthenticated) {
        await _loadUserData();
      }
    } catch (e) {
      _setError(e.toString());
      _isAuthenticated = false;
    }
    _setLoading(false);
  }

  // Carregar dados do usuário
  Future<void> _loadUserData() async {
    try {
      // Tentar obter usuário salvo
      _user = await _authService.getSavedUser();
      
      if (_user == null) {
        // Se não houver usuário salvo, buscar da API
        final response = await _authService.getUserProfile();
        _user = User.fromJson(response['data']['user']);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _clearError();
    _setLoading(true);
    
    try {
      final response = await _authService.login(email, password);
      _user = User.fromJson(response['data']['user']);
      
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? phone,
    Map<String, String>? location,
  }) async {
    _clearError();
    _setLoading(true);
    
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        userType: userType,
        phone: phone,
        location: location,
      );
      
      _user = User.fromJson(response['data']['user']);
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }

  // Atualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? phone,
    Map<String, String>? location,
    String? profileImage,
  }) async {
    _clearError();
    _setLoading(true);
    
    try {
      _user = await _authService.updateUserProfile(
        name: name,
        phone: phone,
        location: location,
        profileImage: profileImage,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Solicitar redefinição de senha
  Future<bool> forgotPassword(String email) async {
    _clearError();
    _setLoading(true);
    
    try {
      final success = await _authService.forgotPassword(email);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _clearError();
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      _setError(e.toString());
    }
    
    _setLoading(false);
  }

  // Utilitários
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
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

# Verificar se o caminho é válido antes de chamar a função
if ([string]::IsNullOrEmpty($authProviderPath)) {
    Write-Host "ERRO: O caminho para o arquivo auth_provider.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

# Criar o arquivo de auth provider
New-File -Path $authProviderPath -Content $authProviderContent

Write-Host "Arquivo auth_provider.dart criado com sucesso!" -ForegroundColor Cyan