import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class MusiciansListScreen extends StatefulWidget {
  const MusiciansListScreen({super.key});

  @override
  State<MusiciansListScreen> createState() => _MusiciansListScreenState();
}

class _MusiciansListScreenState extends State<MusiciansListScreen> {
  bool _isLoading = false;
  List<dynamic> _musicians = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadMusicians();
  }
  
  Future<void> _loadMusicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
     
      await Future.delayed(const Duration(seconds: 1));
      
      _musicians = List.generate(
        10,
        (index) => {
          'id': 'musician-$index',
          'name': 'Músico ${index + 1}',
          'genres': _getRandomGenres(),
          'instruments': _getRandomInstruments(),
          'rating': 3.5 + (index % 3) * 0.5,
          'reviewCount': 5 + index * 2,
          'profileImage': Constants.defaultProfileImage,
          'location': {
            'city': 'São Paulo',
            'state': 'SP',
          },
        },
      );
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
    final maxGenres = allGenres.length > 3 ? 3 : allGenres.length;
    final genreCount = 1 + (DateTime.now().millisecondsSinceEpoch % maxGenres);
    
    return allGenres
        .take(genreCount)
        .toList();
  }
  
  List<String> _getRandomInstruments() {
    final allInstruments = Constants.instruments;
    final maxInstruments = allInstruments.length > 3 ? 3 : allInstruments.length;
    final instrumentCount = 1 + (DateTime.now().millisecondsSinceEpoch % maxInstruments);
    
    return allInstruments
        .take(instrumentCount)
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Músicos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.musicianSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ],
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
                        'Erro ao carregar músicos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMusicians,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _musicians.isEmpty
                  ? const Center(
                      child: Text('Nenhum músico encontrado.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMusicians,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _musicians.length,
                        itemBuilder: (context, index) {
                          final musician = _musicians[index];
                          return _buildMusicianCard(musician);
                        },
                      ),
                    ),
    );
  }
  
  Widget _buildMusicianCard(dynamic musician) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.musicianDetails,
            arguments: musician['id'],
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(musician['profileImage']),
              ),
              const SizedBox(width: 16),
              
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      musician['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Localização
                    if (musician['location'] != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${musician['location']['city']}, ${musician['location']['state']}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    
                    // Gêneros musicais
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (musician['genres'] as List<String>)
                          .map((genre) => Chip(
                                label: Text(
                                  genre,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.indigo.shade100,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: -2,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Instrumentos
                    Text(
                      'Instrumentos: ${(musician['instruments'] as List<String>).join(', ')}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Avaliação
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < (musician['rating'] as double).floor()
                                ? Icons.star
                                : index < (musician['rating'] as double)
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${musician['rating']} (${musician['reviewCount']} avaliações)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}