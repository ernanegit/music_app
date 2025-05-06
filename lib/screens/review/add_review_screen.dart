import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/loading_indicator.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  bool _isLoading = false;
  double _rating = 4.0;
  String? _selectedContractId;
  List<dynamic> _availableContracts = [];
  
  @override
  void initState() {
    super.initState();
    _loadContracts();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadContracts() async {
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
        _availableContracts = List.generate(
          5,
          (index) => {
            'id': 'contract-$index',
            'title': 'Evento ${index + 1}',
            'date': DateTime.now().subtract(Duration(days: index * 3 + 1)),
            'status': 'finalizado',
            'isReviewed': index % 3 == 0,
            'otherParty': {
              'id': isMusician ? 'client-$index' : 'musician-$index',
              'name': isMusician ? 'Cliente ${index + 1}' : 'Músico ${index + 1}',
              'profileImage': Constants.defaultProfileImage,
            },
          },
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar contratos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verificar se um contrato foi selecionado
    if (_selectedContractId == null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Por favor, selecione um contrato para avaliar',
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Avaliação enviada com sucesso!',
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showErrorSnackBar(
        context,
        'Erro ao enviar avaliação: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMusician = authProvider.isMusician;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Avaliação'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selecionar contrato
                    const Text(
                      'Selecione o Contrato',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_availableContracts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Não há contratos disponíveis para avaliação',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...(_availableContracts.where((contract) => !contract['isReviewed'])).map(
                        (contract) => RadioListTile<String>(
                          title: Text(contract['title']),
                          subtitle: Row(
                            children: [
                              Text('Data: ${_formatDate(contract['date'])}'),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 14,
                              ),
                              const Text(
                                'Finalizado',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          secondary: CircleAvatar(
                            backgroundImage: NetworkImage(contract['otherParty']['profileImage']),
                          ),
                          value: contract['id'],
                          groupValue: _selectedContractId,
                          onChanged: (value) {
                            setState(() {
                              _selectedContractId = value;
                            });
                          },
                        ),
                      ),
                    
                    // Avaliações já realizadas
                    if (_availableContracts.any((contract) => contract['isReviewed'])) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Contratos já avaliados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_availableContracts.where((contract) => contract['isReviewed'])).map(
                        (contract) => ListTile(
                          title: Text(contract['title']),
                          subtitle: Row(
                            children: [
                              Text('Data: ${_formatDate(contract['date'])}'),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const Text(
                                'Avaliado',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(contract['otherParty']['profileImage']),
                          ),
                          enabled: false,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Avaliação por estrelas
                    const Text(
                      'Sua Avaliação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 1; i <= 5; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = i.toDouble();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                i <= _rating
                                    ? Icons.star
                                    : i - 0.5 <= _rating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 40,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Comentário
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comentário',
                        hintText: 'Compartilhe sua experiência...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, escreva um comentário';
                        }
                        if (value.trim().length < 5) {
                          return 'Comentário muito curto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Botão de enviar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedContractId == null ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade700,
                        ),
                        child: const Text(
                          'ENVIAR AVALIAÇÃO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  String _getRatingText(double rating) {
    if (rating <= 1) {
      return 'Muito ruim';
    } else if (rating <= 2) {
      return 'Ruim';
    } else if (rating <= 3) {
      return 'Regular';
    } else if (rating <= 4) {
      return 'Bom';
    } else {
      return 'Excelente';
    }
  }
}