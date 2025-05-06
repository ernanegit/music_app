import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/loading_indicator.dart';

class ContractDetailsScreen extends StatefulWidget {
  final String contractId;
  
  const ContractDetailsScreen({
    super.key,
    required this.contractId,
  });

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _contract;
  
  @override
  void initState() {
    super.initState();
    _loadContract();
  }
  
  Future<void> _loadContract() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      // Por enquanto, vamos usar dados de exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      final index = int.tryParse(widget.contractId.split('-').last) ?? 0;
      
      setState(() {
        _contract = {
          'id': widget.contractId,
          'title': 'Evento ${index + 1}',
          'description': 'Este é um evento de ${_getRandomEventType()}. '
              'Precisamos de um músico que toque vários estilos e que tenha equipamento próprio. '
              'O evento terá aproximadamente ${50 + (index * 10)} pessoas.',
          'date': DateTime.now().add(Duration(days: index * 3)),
          'startTime': '19:00',
          'endTime': '23:00',
          'location': 'Salão de Festas XYZ - Rua das Flores, 123, São Paulo - SP',
          'price': 1000 + (index * 200),
          'status': Constants.contractStatus[index % Constants.contractStatus.length],
          'musician': {
            'id': 'musician-$index',
            'name': 'Músico ${index + 1}',
            'profileImage': Constants.defaultProfileImage,
            'genres': _getRandomGenres(),
            'phone': '(11) 99999-9999',
            'email': 'musico${index + 1}@exemplo.com',
          },
          'client': {
            'id': 'client-$index',
            'name': 'Cliente ${index + 1}',
            'profileImage': Constants.defaultProfileImage,
            'phone': '(11) 88888-8888',
            'email': 'cliente${index + 1}@exemplo.com',
          },
          'createdAt': DateTime.now().subtract(Duration(days: 10 - index)),
          'requirements': [
            'Equipamento de som do músico',
            'Repertório variado',
            'Pontualidade',
          ],
          'messages': List.generate(
            3 + (index % 3),
            (i) => {
              'id': 'message-$i',
              'sender': i % 2 == 0 ? 'client' : 'musician',
              'text': 'Mensagem de exemplo ${i + 1}',
              'timestamp': DateTime.now().subtract(Duration(hours: (3 - i) * 2)),
            },
          ),
        };
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showErrorSnackBar(
        context,
        'Erro ao carregar detalhes do contrato: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _getRandomEventType() {
    final eventTypes = Constants.eventTypes;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % eventTypes.length;
    return eventTypes[randomIndex].toLowerCase();
  }
  
  List<String> _getRandomGenres() {
    final allGenres = Constants.genres;
    final genreCount = 1 + (DateTime.now().millisecondsSinceEpoch % 3);
    
    return List.generate(
      genreCount,
      (index) => allGenres[(index + DateTime.now().millisecondsSinceEpoch) % allGenres.length],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'solicitado':
        return Colors.orange;
      case 'aceito':
        return Colors.green;
      case 'recusado':
        return Colors.red;
      case 'cancelado':
        return Colors.red.shade300;
      case 'finalizado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'solicitado':
        return 'Solicitado';
      case 'aceito':
        return 'Confirmado';
      case 'recusado':
        return 'Recusado';
      case 'cancelado':
        return 'Cancelado';
      case 'finalizado':
        return 'Finalizado';
      default:
        return 'Desconhecido';
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
  
  Future<void> _updateContractStatus(String status) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        if (_contract != null) {
          _contract!['status'] = status;
        }
      });
      
      if (!mounted) return;
      
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Status do contrato atualizado com sucesso',
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showErrorSnackBar(
        context,
        'Erro ao atualizar status do contrato: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _confirmStatusChange(String newStatus) {
    String actionText;
    
    switch (newStatus) {
      case 'aceito':
        actionText = 'aceitar';
        break;
      case 'recusado':
        actionText = 'recusar';
        break;
      case 'cancelado':
        actionText = 'cancelar';
        break;
      case 'finalizado':
        actionText = 'finalizar';
        break;
      default:
        actionText = 'alterar';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText Contrato'),
        content: Text('Tem certeza que deseja $actionText este contrato?'),
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
              _updateContractStatus(newStatus);
            },
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'recusado' || newStatus == 'cancelado'
                  ? Colors.red
                  : null,
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMusician = authProvider.isMusician;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_contract != null ? _contract!['title'] : 'Detalhes do Contrato'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _contract == null
              ? const Center(
                  child: Text('Contrato não encontrado'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status do contrato
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_contract!['status']),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _contract!['status'] == 'aceito'
                                  ? Icons.check_circle
                                  : _contract!['status'] == 'solicitado'
                                      ? Icons.pending
                                      : _contract!['status'] == 'recusado' ||
                                              _contract!['status'] == 'cancelado'
                                          ? Icons.cancel
                                          : Icons.done_all,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(_contract!['status']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Informações do evento
                      _buildSectionTitle('Detalhes do Evento'),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        'Data',
                        _formatDate(_contract!['date']),
                        icon: Icons.calendar_today,
                      ),
                      _buildInfoItem(
                        'Horário',
                        '${_contract!['startTime']} às ${_contract!['endTime']}',
                        icon: Icons.access_time,
                      ),
                      _buildInfoItem(
                        'Local',
                        _contract!['location'],
                        icon: Icons.location_on,
                      ),
                      _buildInfoItem(
                        'Valor',
                        _formatCurrency(_contract!['price'].toDouble()),
                        icon: Icons.attach_money,
                        valueStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      const SizedBox(height: 4),
                      
                      // Descrição
                      _buildSectionTitle('Descrição'),
                      const SizedBox(height: 8),
                      Text(_contract!['description']),
                      const SizedBox(height: 16),
                      
                      // Requisitos
                      if ((_contract!['requirements'] as List).isNotEmpty) ...[
                        _buildSectionTitle('Requisitos'),
                        const SizedBox(height: 8),
                        ...(_contract!['requirements'] as List).map(
                          (requirement) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(requirement)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Informações de contato
                      _buildSectionTitle(
                        isMusician ? 'Informações do Contratante' : 'Informações do Músico',
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        isMusician ? _contract!['client'] : _contract!['musician'],
                        isMusician,
                      ),
                      const SizedBox(height: 24),
                      
                      // Histórico de mensagens
                      _buildSectionTitle('Histórico de Comunicação'),
                      const SizedBox(height: 8),
                      ...(_contract!['messages'] as List).map(
                        (message) => Align(
                          alignment: message['sender'] == (isMusician ? 'musician' : 'client')
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: message['sender'] == (isMusician ? 'musician' : 'client')
                                  ? Colors.indigo.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message['text']),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(message['timestamp']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Campo de nova mensagem
                      const SizedBox(height: 16),
                      if (_contract!['status'] == 'solicitado' ||
                          _contract!['status'] == 'aceito') ...[
                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Digite uma mensagem...',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.send),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: _contract != null &&
              ((_contract!['status'] == 'solicitado' && isMusician) ||
                  (_contract!['status'] == 'aceito'))
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
              child: _buildActionButtons(isMusician),
            )
          : null,
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }
  
  Widget _buildInfoItem(
    String label,
    String value, {
    IconData? icon,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.indigo,
              size: 18,
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactCard(Map<String, dynamic> person, bool isMusician) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(person['profileImage']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isMusician && person['genres'] != null) ...[
                    const Text(
                      'Gêneros:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (person['genres'] as List<String>)
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
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(person['phone']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(person['email']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(bool isMusician) {
    if (_contract!['status'] == 'solicitado' && isMusician) {
      // Músico pode aceitar ou recusar a solicitação
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _confirmStatusChange('recusado');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('RECUSAR'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _confirmStatusChange('aceito');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('ACEITAR'),
            ),
          ),
        ],
      );
    } else if (_contract!['status'] == 'aceito') {
      // Ambos podem finalizar ou cancelar
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _confirmStatusChange('cancelado');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('CANCELAR'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _confirmStatusChange('finalizado');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('FINALIZAR'),
            ),
          ),
        ],
      );
    }
    
    // Estado não requer ações
    return const SizedBox();
  }
}