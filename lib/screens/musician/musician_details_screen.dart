import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class MusicianDetailsScreen extends StatefulWidget {
  final String musicianId;
  
  const MusicianDetailsScreen({
    super.key,
    required this.musicianId,
  });

  @override
  State<MusicianDetailsScreen> createState() => _MusicianDetailsScreenState();
}

class _MusicianDetailsScreenState extends State<MusicianDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _musician;
  String? _errorMessage;
  bool _showMoreDescription = false;
  
  @override
  void initState() {
    super.initState();
    _loadMusicianDetails();
  }
  
  Future<void> _loadMusicianDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      // Por enquanto, vamos usar dados de exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      final index = int.tryParse(widget.musicianId.split('-').last) ?? 0;
      
      setState(() {
        _musician = {
          'id': widget.musicianId,
          'name': 'Músico ${index + 1}',
          'description': 'Sou um músico profissional com mais de ${5 + (index % 10)} anos de experiência. '
              'Especializado em shows para eventos como casamentos, formaturas e festas corporativas. '
              'Possuo um repertório diversificado que pode ser adaptado conforme as preferências do cliente. '
              'Tenho equipamento próprio de alta qualidade e posso me apresentar solo ou com banda completa.',
          'genres': _getRandomGenres(),
          'instruments': _getRandomInstruments(),
          'hourlyRate': 150 + (index * 20),
          'rating': 3.5 + (index % 3) * 0.5,
          'reviewCount': 5 + index * 2,
          'profileImage': Constants.defaultProfileImage,
          'location': {
            'city': 'São Paulo',
            'state': 'SP',
            'country': 'Brasil',
          },
          'portfolio': List.generate(
            3 + (index % 3),
            (i) => {
              'id': 'portfolio-$i',
              'title': 'Performance ${i + 1}',
              'description': 'Show realizado em evento corporativo',
              'type': i % 3 == 0 ? 'video' : (i % 3 == 1 ? 'audio' : 'image'),
              'url': Constants.defaultProfileImage, // Placeholder para URL real
              'thumbnailUrl': Constants.defaultProfileImage,
            },
          ),
          'reviews': List.generate(
            3 + (index % 5),
            (i) => {
              'id': 'review-$i',
              'rating': 3 + (i % 3),
              'comment': 'Excelente músico, muito profissional e pontual. Recomendo!',
              'clientName': 'Cliente ${i + 1}',
              'date': DateTime.now().subtract(Duration(days: i * 10)),
            },
          ),
          'availableDates': List.generate(
            10,
            (i) => DateTime.now().add(Duration(days: i + 1)),
          ),
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<String> _getRandomGenres() {
    final allGenres = Constants.genres;
    final genreCount = 1 + (DateTime.now().millisecondsSinceEpoch % 5);
    
    return List.generate(
      genreCount,
      (index) => allGenres[(index + DateTime.now().millisecondsSinceEpoch) % allGenres.length],
    );
  }
  
  List<String> _getRandomInstruments() {
    final allInstruments = Constants.instruments;
    final instrumentCount = 1 + (DateTime.now().millisecondsSinceEpoch % 4);
    
    return List.generate(
      instrumentCount,
      (index) => allInstruments[(index + DateTime.now().millisecondsSinceEpoch) % allInstruments.length],
    );
  }
  
  void _createContract() {
    if (_musician == null) return;
    
    // Navegar para a tela de criação de contrato
    Navigator.pushNamed(
      context,
      AppRoutes.createContract,
      arguments: {
        'musicianId': _musician!['id'],
        'musicianName': _musician!['name'],
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_musician?['name'] ?? 'Detalhes do Músico'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar detalhes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMusicianDetails,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _musician == null
                  ? const Center(
                      child: Text('Músico não encontrado'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho com foto e informações básicas
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Foto de perfil
                              Hero(
                                tag: 'musician-${_musician!['id']}',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(_musician!['profileImage']),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Informações básicas
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nome
                                    Text(
                                      _musician!['name'],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Localização
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_musician!['location']['city']}, ${_musician!['location']['state']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Avaliação
                                    Row(
                                      children: [
                                        ...List.generate(
                                          5,
                                          (index) => Icon(
                                            index < (_musician!['rating'] as double).floor()
                                                ? Icons.star
                                                : index < (_musician!['rating'] as double)
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_musician!['rating']} (${_musician!['reviewCount']} avaliações)',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Valor por hora
                                    Text(
                                      'R\$ ${_musician!['hourlyRate']}/hora',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Seção de Gêneros
                          const Text(
                            'Gêneros Musicais',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (_musician!['genres'] as List<String>)
                                .map((genre) => Chip(
                                      label: Text(genre),
                                      backgroundColor: Colors.indigo.shade100,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Seção de Instrumentos
                          const Text(
                            'Instrumentos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (_musician!['instruments'] as List<String>)
                                .map((instrument) => Chip(
                                      label: Text(instrument),
                                      backgroundColor: Colors.indigo.shade50,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Seção de Descrição/Biografia
                          const Text(
                            'Sobre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMoreDescription = !_showMoreDescription;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _musician!['description'],
                                  maxLines: _showMoreDescription ? null : 3,
                                  overflow: _showMoreDescription ? null : TextOverflow.ellipsis,
                                ),
                                if (_musician!['description'].length > 100)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showMoreDescription = !_showMoreDescription;
                                        });
                                      },
                                      child: Text(
                                        _showMoreDescription ? 'Mostrar menos' : 'Mostrar mais',
                                        style: const TextStyle(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Seção de Portfólio
                          const Text(
                            'Portfólio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (_musician!['portfolio'] as List).length,
                              itemBuilder: (context, index) {
                                final portfolioItem = _musician!['portfolio'][index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // TODO: Implementar visualização do item do portfólio
                                    },
                                    child: Container(
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(portfolioItem['thumbnailUrl']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(8.0),
                                                  bottomRight: Radius.circular(8.0),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    portfolioItem['title'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    portfolioItem['type'] == 'video'
                                                        ? 'Vídeo'
                                                        : portfolioItem['type'] == 'audio'
                                                            ? 'Áudio'
                                                            : 'Imagem',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (portfolioItem['type'] == 'video')
                                            const Center(
                                              child: Icon(
                                                Icons.play_circle_filled,
                                                size: 48,
                                                color: Colors.white,
                                              ),
                                            ),
                                          if (portfolioItem['type'] == 'audio')
                                            const Center(
                                              child: Icon(
                                                Icons.audiotrack,
                                                size: 48,
                                                color: Colors.white,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Seção de Avaliações
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Avaliações',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implementar visualização de todas as avaliações
                                },
                                child: const Text('Ver todas'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(_musician!['reviews'] as List)
                              .take(3)
                              .map((review) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              review['clientName'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (index) => Icon(
                                                  index < review['rating'] ? Icons.star : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(review['comment']),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatDate(review['date'])}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
      bottomNavigationBar: _musician != null
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) => ElevatedButton(
                  onPressed: authProvider.isMusician ? null : _createContract,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade700,
                  ),
                  child: Text(
                    authProvider.isMusician
                        ? 'Músicos não podem criar contratos'
                        : 'Contratar Músico',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
  
  String _formatDate(DateTime date) {
    // Formatar data de forma simples
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
}