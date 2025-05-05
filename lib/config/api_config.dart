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
