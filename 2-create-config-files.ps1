# Script para criar os arquivos de configuração
# Executar no diretório raiz do projeto Flutter

# Criar arquivo de configuração da API
$apiConfigPath = ".\lib\config\api_config.dart"
$apiConfigContent = @"
class ApiConfig {
  // URL base da API
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Endpoints da API
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String userProfile = '/auth/me';
  static const String updateProfile = '/auth/me';
  static const String updatePassword = '/auth/update-password';
  
  // Endpoints de músicos
  static const String musicians = '/musicians';
  static const String musicianSearch = '/musicians/search';
  static const String featuredMusicians = '/musicians/featured';
  static const String musicianProfile = '/musicians/profile';
  
  // Endpoints de portfólio
  static const String portfolio = '/portfolios';
  static const String reorderPortfolio = '/portfolios/reorder';
  
  // Endpoints de contratos
  static const String contracts = '/contracts';
  static const String contractStats = '/contracts/stats';
  
  // Endpoints de avaliações
  static const String reviews = '/reviews';
  static const String userReviews = '/reviews/user/my-reviews';
  static const String musicianReviews = '/reviews/user/my-musician-reviews';
  
  // Endpoints de upload
  static const String uploadProfileImage = '/upload/profile-image';
  static const String uploadPortfolio = '/upload/portfolio';
  static const String uploadMultiplePortfolio = '/upload/portfolio/multiple';
  
  // Timeout para requisições (em segundos)
  static const int requestTimeout = 15;
}
"@

# Criar arquivo de rotas da aplicação
$appRoutesPath = ".\lib\config\app_routes.dart"
$appRoutesContent = @"
import 'package:flutter/material.dart';

// Importações serão adicionadas automaticamente pelo VSCode
// ou podem ser adicionadas manualmente conforme criamos as telas

class AppRoutes {
  // Rotas de autenticação
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  
  // Rotas de perfil
  static const String userProfile = '/profile';
  static const String editProfile = '/profile/edit';
  
  // Rotas de músicos
  static const String musicians = '/musicians';
  static const String musicianDetails = '/musicians/details';
  static const String musicianSearch = '/musicians/search';
  
  // Rotas de portfólio
  static const String portfolio = '/portfolio';
  static const String addPortfolioItem = '/portfolio/add';
  static const String editPortfolioItem = '/portfolio/edit';
  
  // Rotas de contratos
  static const String contracts = '/contracts';
  static const String contractDetails = '/contract/details';
  static const String createContract = '/contract/create';
  
  // Rotas de avaliações
  static const String reviews = '/reviews';
  static const String addReview = '/review/add';
  
  // Rota inicial
  static const String initialRoute = login;
  
  // Mapa de rotas
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      userProfile: (context) => const UserProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      musicians: (context) => const MusiciansListScreen(),
      musicianSearch: (context) => const MusicianSearchScreen(),
      portfolio: (context) => const PortfolioScreen(),
      addPortfolioItem: (context) => const AddPortfolioItemScreen(),
      contracts: (context) => const ContractsScreen(),
      createContract: (context) => const CreateContractScreen(),
      reviews: (context) => const ReviewsScreen(),
      addReview: (context) => const AddReviewScreen(),
    };
  }
  
  // Rotas que recebem argumentos
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case musicianDetails:
        final musicianId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MusicianDetailsScreen(musicianId: musicianId),
        );
      
      case contractDetails:
        final contractId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ContractDetailsScreen(contractId: contractId),
        );
        
      case editPortfolioItem:
        final portfolioItemId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddPortfolioItemScreen(portfolioItemId: portfolioItemId),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Rota não encontrada'),
            ),
          ),
        );
    }
  }
}
"@

# Arquivo de constantes
$constantsPath = ".\lib\utils\constants.dart"
$constantsContent = @"
class Constants {
  // URL de imagem de perfil padrão
  static const String defaultProfileImage = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  // Lista de gêneros musicais
  static const List<String> genres = [
    'Rock',
    'Pop',
    'MPB',
    'Samba',
    'Pagode',
    'Sertanejo',
    'Forró',
    'Axé',
    'Funk',
    'Rap',
    'Hip Hop',
    'Eletrônica',
    'Jazz',
    'Blues',
    'Clássica',
    'Gospel',
    'Reggae',
    'Outro',
  ];

  // Lista de instrumentos
  static const List<String> instruments = [
    'Voz',
    'Violão',
    'Guitarra',
    'Baixo',
    'Bateria',
    'Teclado',
    'Piano',
    'Saxofone',
    'Trompete',
    'Violino',
    'Viola',
    'Violoncelo',
    'Contrabaixo',
    'Flauta',
    'Clarinete',
    'Acordeão',
    'Cavaquinho',
    'Outro',
  ];

  // Lista de tipos de eventos
  static const List<String> eventTypes = [
    'Casamento',
    'Aniversário',
    'Formatura',
    'Corporativo',
    'Festival',
    'Bar/Restaurante',
    'Show',
    'Outro',
  ];

  // Status de contrato
  static const List<String> contractStatus = [
    'solicitado',
    'aceito',
    'recusado',
    'cancelado',
    'finalizado',
  ];
}
"@

# Criar o arquivo de validadores
$validatorsPath = ".\lib\utils\validators.dart"
$validatorsContent = @"
class Validators {
  // Validar nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu nome';
    }
    if (value.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, informe um email válido';
    }
    return null;
  }

  // Validar senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // Validar confirmação de senha
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // Validar telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    if (value.length < 10) {
      return 'Por favor, informe um telefone válido';
    }
    return null;
  }

  // Validar cidade
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe sua cidade';
    }
    return null;
  }

  // Validar estado
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu estado';
    }
    return null;
  }
}
"@

# Criar arquivo de helpers para SnackBar
$snackbarHelperPath = ".\lib\utils\snackbar_helper.dart"
$snackbarHelperContent = @"
import 'package:flutter/material.dart';

class SnackbarHelper {
  // Mostrar snackbar de erro
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Mostrar snackbar de sucesso
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
"@

# Função para criar arquivos (usando verbo aprovado)
function New-File {
    param(
        [string]$Path,
        [string]$Content
    )
    
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -ItemType File -Force | Out-Null
        Set-Content -Path $Path -Value $Content
        Write-Host "Arquivo criado: $Path" -ForegroundColor Green
    } else {
        Write-Host "Arquivo já existe: $Path, substituindo conteúdo..." -ForegroundColor Yellow
        Set-Content -Path $Path -Value $Content
    }
}

# Criar todos os arquivos
New-File -Path $apiConfigPath -Content $apiConfigContent
New-File -Path $appRoutesPath -Content $appRoutesContent
New-File -Path $constantsPath -Content $constantsContent
New-File -Path $validatorsPath -Content $validatorsContent
New-File -Path $snackbarHelperPath -Content $snackbarHelperContent

Write-Host "Arquivos de configuração criados com sucesso!" -ForegroundColor Cyan