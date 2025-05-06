
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
