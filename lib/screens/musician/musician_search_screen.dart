import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../utils/constants.dart';

class MusicianSearchScreen extends StatefulWidget {
  const MusicianSearchScreen({super.key});

  @override
  State<MusicianSearchScreen> createState() => _MusicianSearchScreenState();
}

class _MusicianSearchScreenState extends State<MusicianSearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  
  // Filtros
  final List<String> _selectedGenres = [];
  final List<String> _selectedInstruments = [];
  String? _selectedCity;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _search() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulando uma busca
    Future.delayed(const Duration(milliseconds: 800), () {
      final query = _searchController.text.toLowerCase();
      // Dados de exemplo
      final allMusicians = List.generate(
        20,
        (index) => {
          'id': 'musician-$index',
          'name': 'Músico ${index + 1}',
          'genres': _getRandomGenres(),
          'instruments': _getRandomInstruments(),
          'rating': 3.0 + (index % 5) * 0.5,
          'reviewCount': 5 + index * 2,
          'profileImage': Constants.defaultProfileImage,
          'location': {
            'city': index % 3 == 0 ? 'São Paulo' : (index % 3 == 1 ? 'Rio de Janeiro' : 'Belo Horizonte'),
            'state': index % 3 == 0 ? 'SP' : (index % 3 == 1 ? 'RJ' : 'MG'),
          },
        },
      );
      
      // Aplicar filtros
      final filteredMusicians = allMusicians.where((musician) {
        // Filtro de texto
        final matchesQuery = query.isEmpty ||
            musician['name'].toString().toLowerCase().contains(query);
        
        // Filtro de gêneros
        final matchesGenres = _selectedGenres.isEmpty ||
            (musician['genres'] as List<String>)
                .any((genre) => _selectedGenres.contains(genre));
        
        // Filtro de instrumentos
        final matchesInstruments = _selectedInstruments.isEmpty ||
            (musician['instruments'] as List<String>)
                .any((instrument) => _selectedInstruments.contains(instrument));
        
        // Filtro de cidade
        final matchesCity = _selectedCity == null ||
            musician['location']['city'] == _selectedCity;
        
        return matchesQuery && matchesGenres && matchesInstruments && matchesCity;
      }).toList();
      
      setState(() {
        _searchResults = filteredMusicians;
        _isLoading = false;
      });
    });
  }
  
  List<String> _getRandomGenres() {
    // Função auxiliar para selecionar gêneros aleatórios
    final allGenres = Constants.genres;
    final genreCount = 1 + (DateTime.now().millisecondsSinceEpoch % 3);
    
    return List.generate(
      genreCount,
      (index) => allGenres[(index + DateTime.now().millisecondsSinceEpoch) % allGenres.length],
    );
  }
  
  List<String> _getRandomInstruments() {
    // Função auxiliar para selecionar instrumentos aleatórios
    final allInstruments = Constants.instruments;
    final instrumentCount = 1 + (DateTime.now().millisecondsSinceEpoch % 3);
    
    return List.generate(
      instrumentCount,
      (index) => allInstruments[(index + DateTime.now().millisecondsSinceEpoch) % allInstruments.length],
    );
  }
  
  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Filtro de Gêneros
                    const Text(
                      'Gêneros Musicais',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Constants.genres
                          .map((genre) => FilterChip(
                                label: Text(genre),
                                selected: _selectedGenres.contains(genre),
                                onSelected: (selected) {
                                  setStateLocal(() {
                                    if (selected) {
                                      _selectedGenres.add(genre);
                                    } else {
                                      _selectedGenres.remove(genre);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Filtro de Instrumentos
                    const Text(
                      'Instrumentos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Constants.instruments
                          .map((instrument) => FilterChip(
                                label: Text(instrument),
                                selected: _selectedInstruments.contains(instrument),
                                onSelected: (selected) {
                                  setStateLocal(() {
                                    if (selected) {
                                      _selectedInstruments.add(instrument);
                                    } else {
                                      _selectedInstruments.remove(instrument);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Filtro de Cidade
                    const Text(
                      'Cidade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        hintText: 'Selecione uma cidade',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as cidades'),
                        ),
                        ...['São Paulo', 'Rio de Janeiro', 'Belo Horizonte']
                            .map((city) => DropdownMenuItem<String?>(
                                  value: city,
                                  child: Text(city),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setStateLocal(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botões de ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setStateLocal(() {
                              _selectedGenres.clear();
                              _selectedInstruments.clear();
                              _selectedCity = null;
                            });
                          },
                          child: const Text('Limpar Filtros'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _search();
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Músicos'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar músicos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list),
                      if (_selectedGenres.isNotEmpty ||
                          _selectedInstruments.isNotEmpty ||
                          _selectedCity != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFiltersDialog,
                ),
              ],
            ),
          ),
          
          // Chips de filtros selecionados
          if (_selectedGenres.isNotEmpty ||
              _selectedInstruments.isNotEmpty ||
              _selectedCity != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedGenres.map(
                      (genre) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(genre),
                          onDeleted: () {
                            setState(() {
                              _selectedGenres.remove(genre);
                            });
                            _search();
                          },
                        ),
                      ),
                    ),
                    ..._selectedInstruments.map(
                      (instrument) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(instrument),
                          onDeleted: () {
                            setState(() {
                              _selectedInstruments.remove(instrument);
                            });
                            _search();
                          },
                        ),
                      ),
                    ),
                    if (_selectedCity != null)
                      Chip(
                        label: Text(_selectedCity!),
                        onDeleted: () {
                          setState(() {
                            _selectedCity = null;
                          });
                          _search();
                        },
                      ),
                  ],
                ),
              ),
            ),
          
          // Resultados da busca
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty ||
                                      _selectedGenres.isNotEmpty ||
                                      _selectedInstruments.isNotEmpty ||
                                      _selectedCity != null
                                  ? 'Nenhum músico encontrado com esses filtros'
                                  : 'Busque por músicos usando a barra acima',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty ||
                                _selectedGenres.isNotEmpty ||
                                _selectedInstruments.isNotEmpty ||
                                _selectedCity != null) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedGenres.clear();
                                    _selectedInstruments.clear();
                                    _selectedCity = null;
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Limpar Filtros'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final musician = _searchResults[index];
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
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _search,
        child: const Icon(Icons.search),
      ),
    );
  }
}