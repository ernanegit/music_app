import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _contracts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContracts();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
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
        _contracts = List.generate(
          10,
          (index) => {
            'id': 'contract-$index',
            'title': 'Evento ${index + 1}',
            'description': 'Descrição do evento ${index + 1}',
            'date': DateTime.now().add(Duration(days: index * 3)),
            'startTime': '19:00',
            'endTime': '23:00',
            'location': 'Local do evento ${index + 1}',
            'price': 1000 + (index * 200),
            'status': Constants.contractStatus[index % Constants.contractStatus.length],
            'musician': {
              'id': 'musician-$index',
              'name': 'Músico ${index + 1}',
              'profileImage': Constants.defaultProfileImage,
            },
            'client': {
              'id': 'client-$index',
              'name': 'Cliente ${index + 1}',
              'profileImage': Constants.defaultProfileImage,
            },
            'createdAt': DateTime.now().subtract(Duration(days: 10 - index)),
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
  
  List<dynamic> _getFilteredContracts(String filter) {
    if (filter == 'ativos') {
      return _contracts.where((contract) => 
        contract['status'] == 'solicitado' || 
        contract['status'] == 'aceito'
      ).toList();
    } else if (filter == 'finalizados') {
      return _contracts.where((contract) => 
        contract['status'] == 'finalizado'
      ).toList();
    } else if (filter == 'cancelados') {
      return _contracts.where((contract) => 
        contract['status'] == 'recusado' || 
        contract['status'] == 'cancelado'
      ).toList();
    }
    return [];
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
  
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMusician = authProvider.isMusician;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Contratos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ativos'),
            Tab(text: 'Finalizados'),
            Tab(text: 'Cancelados'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                // Contratos ativos
                _buildContractList(_getFilteredContracts('ativos')),
                
                // Contratos finalizados
                _buildContractList(_getFilteredContracts('finalizados')),
                
                // Contratos cancelados
                _buildContractList(_getFilteredContracts('cancelados')),
              ],
            ),
      floatingActionButton: isMusician
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createContract);
              },
              child: const Icon(Icons.add),
            ),
    );
  }
  
  Widget _buildContractList(List<dynamic> contracts) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMusician = authProvider.isMusician;
    
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum contrato nesta categoria',
              style: TextStyle(
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
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        final otherParty = isMusician ? contract['client'] : contract['musician'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.contractDetails,
                arguments: contract['id'],
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com status
                Container(
                  color: _getStatusColor(contract['status']),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    _getStatusText(contract['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Conteúdo principal
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título e data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              contract['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(contract['date']),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Descrição
                      Text(
                        contract['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      
                      // Informações da outra parte
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(otherParty['profileImage']),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMusician ? 'Contratante:' : 'Músico:',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  otherParty['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(contract['price'].toDouble()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo,
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
        );
      },
    );
  }
}