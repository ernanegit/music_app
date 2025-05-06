import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _isLoading = false;
  List<dynamic> _portfolioItems = [];
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }
  
  Future<void> _loadPortfolio() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      // Por enquanto, vamos usar dados de exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _portfolioItems = List.generate(
          5,
          (index) => {
            'id': 'portfolio-$index',
            'title': 'Performance ${index + 1}',
            'description': 'Show realizado em evento corporativo',
            'type': index % 3 == 0 ? 'video' : (index % 3 == 1 ? 'audio' : 'image'),
            'url': Constants.defaultProfileImage, // Placeholder para URL real
            'thumbnailUrl': Constants.defaultProfileImage,
            'order': index,
          },
        );
      });
    } catch (e) {
      // Exibir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar portfólio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deletePortfolioItem(String id) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _portfolioItems.removeWhere((item) => item['id'] == id);
      });
      
      // Exibir mensagem de sucesso
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removido com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Exibir mensagem de erro
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover item: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _reorderPortfolio(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = _portfolioItems.removeAt(oldIndex);
    _portfolioItems.insert(newIndex, item);
    
    // Atualizar a ordem dos itens
    for (int i = 0; i < _portfolioItems.length; i++) {
      _portfolioItems[i]['order'] = i;
    }
    
    // TODO: Implementar a chamada real à API para salvar a nova ordem
  }
  
  void _confirmDeleteItem(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "$title"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePortfolioItem(id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  
  Widget _getOverlayIcon(String type) {
    if (type == 'video') {
      return const Center(
        child: Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: 24,
        ),
      );
    } else if (type == 'audio') {
      return const Center(
        child: Icon(
          Icons.audiotrack,
          color: Colors.white,
          size: 24,
        ),
      );
    }
    return const SizedBox();
  }
  
  String _getItemTypeText(String type) {
    switch (type) {
      case 'video':
        return 'Vídeo';
      case 'audio':
        return 'Áudio';
      case 'image':
        return 'Imagem';
      default:
        return type;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Verificar se o usuário é um músico
    if (!authProvider.isMusician) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Portfólio'),
        ),
        body: const Center(
          child: Text(
            'Somente músicos podem ter um portfólio.\nVocê está logado como Contratante.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Portfólio'),
        actions: [
          // Botão de edição
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _portfolioItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Você ainda não tem itens no portfólio',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.addPortfolioItem);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar primeiro item'),
                      ),
                    ],
                  ),
                )
              : _isEditing
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _portfolioItems.length,
                      onReorder: _reorderPortfolio,
                      itemBuilder: (context, index) {
                        final item = _portfolioItems[index];
                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            _confirmDeleteItem(item['id'], item['title']);
                            return false;
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  image: DecorationImage(
                                    image: NetworkImage(item['thumbnailUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: _getOverlayIcon(item['type']),
                              ),
                              title: Text(item['title']),
                              subtitle: Text(
                                _getItemTypeText(item['type']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.editPortfolioItem,
                                        arguments: item['id'],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _confirmDeleteItem(item['id'], item['title']);
                                    },
                                  ),
                                  const Icon(Icons.drag_handle),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _portfolioItems.length,
                      itemBuilder: (context, index) {
                        final item = _portfolioItems[index];
                        return GestureDetector(
                          onTap: () {
                            // TODO: Implementar visualização do item do portfólio
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Stack(
                              children: [
                                // Imagem de fundo
                                Positioned.fill(
                                  child: Image.network(
                                    item['thumbnailUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                
                                // Ícone do tipo de mídia
                                Positioned.fill(
                                  child: _getOverlayIcon(item['type']),
                                ),
                                
                                // Informações
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getItemTypeText(item['type']),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addPortfolioItem);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}