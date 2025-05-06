import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _myReviews = [];
  List<dynamic> _reviewsOfMe = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      // Por enquanto, vamos usar dados de exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isMusician = authProvider.isMusician;
      
      setState(() {
        _myReviews = List.generate(
          5,
          (index) => {
            'id': 'review-$index',
            'rating': 3.0 + (index % 5) * 0.5,
            'comment': 'Excelente serviço e muito profissional. Recomendo!',
            'contractId': 'contract-$index',
            'contractTitle': 'Evento ${index + 1}',
            'reviewedId': isMusician ? 'client-$index' : 'musician-$index',
            'reviewedName': isMusician ? 'Cliente ${index + 1}' : 'Músico ${index + 1}',
            'reviewedProfileImage': Constants.defaultProfileImage,
            'createdAt': DateTime.now().subtract(Duration(days: 10 - index)),
          },
        );
        
        _reviewsOfMe = List.generate(
          7,
          (index) => {
            'id': 'review-${index + 10}',
            'rating': 4.0 + (index % 3) * 0.5,
            'comment': 'Ótima experiência, profissional muito competente e pontual. Atendeu todas as minhas expectativas!',
            'contractId': 'contract-${index + 10}',
            'contractTitle': 'Evento ${index + 11}',
            'reviewerId': isMusician ? 'client-${index + 10}' : 'musician-${index + 10}',
            'reviewerName': isMusician ? 'Cliente ${index + 11}' : 'Músico ${index + 11}',
            'reviewerProfileImage': Constants.defaultProfileImage,
            'createdAt': DateTime.now().subtract(Duration(days: 20 - index * 2)),
          },
        );
      });
    } catch (e) {
      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar avaliações: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana atrás' : '$weeks semanas atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mês atrás' : '$months meses atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 ano atrás' : '$years anos atrás';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMusician = authProvider.isMusician;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Avaliações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isMusician ? 'Recebidas' : 'Dadas'),
            Tab(text: isMusician ? 'Dadas' : 'Recebidas'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                // Avaliações recebidas (para músicos) ou dadas (para contratantes)
                isMusician
                    ? _buildReviewsList(_reviewsOfMe, isReceived: true)
                    : _buildReviewsList(_myReviews, isReceived: false),
                
                // Avaliações dadas (para músicos) ou recebidas (para contratantes)
                isMusician
                    ? _buildReviewsList(_myReviews, isReceived: false)
                    : _buildReviewsList(_reviewsOfMe, isReceived: true),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addReview);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildReviewsList(List<dynamic> reviews, {required bool isReceived}) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isReceived
                  ? 'Você ainda não recebeu avaliações'
                  : 'Você ainda não avaliou ninguém',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com usuário e evento
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        isReceived
                            ? review['reviewerProfileImage']
                            : review['reviewedProfileImage'],
                      ),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isReceived
                                ? review['reviewerName']
                                : review['reviewedName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Evento: ${review['contractTitle']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(review['createdAt']),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Avaliação
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < (review['rating'] as double).floor()
                          ? Icons.star
                          : index < (review['rating'] as double)
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Comentário
                Text(review['comment']),
              ],
            ),
          ),
        );
      },
    );
  }
}