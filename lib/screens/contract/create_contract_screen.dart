import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/loading_indicator.dart';

class CreateContractScreen extends StatefulWidget {
  final Map<String, dynamic>? musicianData;
  
  const CreateContractScreen({
    super.key,
    this.musicianData,
  });

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedMusicianId;
  String? _selectedMusicianName;
  bool _isLoading = false;
  List<Map<String, dynamic>> _musicians = [];
  
  // Itens requisitos
  final List<String> _requirements = [];
  final _requirementController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Se o musicista for passado como argumento
    if (widget.musicianData != null) {
      _selectedMusicianId = widget.musicianData!['musicianId'];
      _selectedMusicianName = widget.musicianData!['musicianName'];
    } else {
      _loadMusicians();
    }
    
    // Valores iniciais
    _startTimeController.text = '19:00';
    _endTimeController.text = '23:00';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priceController.dispose();
    _requirementController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMusicians() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implementar a chamada real à API
      // Por enquanto, vamos usar dados de exemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _musicians = List.generate(
          10,
          (index) => {
            'id': 'musician-$index',
            'name': 'Músico ${index + 1}',
            'profileImage': Constants.defaultProfileImage,
            'genres': _getRandomGenres(),
            'rating': 3.5 + (index % 3) * 0.5,
          },
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar músicos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<String> _getRandomGenres() {
    final allGenres = Constants.genres;
    final genreCount = 1 + (DateTime.now().millisecondsSinceEpoch % 3);
    
    return List.generate(
      genreCount,
      (index) => allGenres[(index + DateTime.now().millisecondsSinceEpoch) % allGenres.length],
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay initialTime = controller.text.isNotEmpty
        ? TimeOfDay(
            hour: int.parse(controller.text.split(':')[0]),
            minute: int.parse(controller.text.split(':')[1]),
          )
        : TimeOfDay.now();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (picked != null) {
      setState(() {
        controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text.trim());
        _requirementController.clear();
      });
    }
  }
  
  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
  }
  
  Future<void> _createContract() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verificar se um músico foi selecionado
    if (_selectedMusicianId == null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Por favor, selecione um músico',
      );
      return;
    }
    
    // Verificar se uma data foi selecionada
    if (_selectedDate == null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Por favor, selecione uma data para o evento',
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
        'Contrato criado com sucesso!',
      );
      
      // Navegar para a tela de contratos
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.contracts,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showErrorSnackBar(
        context,
        'Erro ao criar contrato: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Contrato'),
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
                    // Seleção de músico
                    if (_selectedMusicianId != null && _selectedMusicianName != null)
                      _buildSelectedMusicianCard()
                    else
                      _buildMusicianSelection(),
                    const SizedBox(height: 24),
                    
                    // Detalhes do evento
                    const Text(
                      'Detalhes do Evento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Título do evento
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Evento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe um título para o evento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Data do evento
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Data do Evento',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Por favor, selecione uma data';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Horário de início e fim
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, _startTimeController),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Horário de Início',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                controller: _startTimeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe o horário de início';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, _endTimeController),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Horário de Término',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                controller: _endTimeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe o horário de término';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Local do evento
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Local do Evento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o local do evento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Preço
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (R$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o valor';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) == null) {
                          return 'Por favor, informe um valor válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Descrição do evento
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do Evento',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, descreva o evento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Requisitos
                    const Text(
                      'Requisitos para o Músico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione requisitos específicos que o músico deverá atender.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de requisitos
                    ..._requirements.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.indigo,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(entry.value),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeRequirement(entry.key),
                                ),
                              ],
                            ),
                          ),
                        ),
                    
                    // Adicionar requisito
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _requirementController,
                            decoration: const InputDecoration(
                              labelText: 'Novo Requisito',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addRequirement,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 16,
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Botão de criar contrato
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createContract,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'CRIAR CONTRATO',
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
  
  Widget _buildMusicianSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o Músico',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),
        
        // Lista de músicos
        if (_musicians.isEmpty)
          const Center(
            child: Text(
              'Nenhum músico encontrado',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          )
        else
          Column(
            children: _musicians.map((musician) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(musician['profileImage']),
                  ),
                  title: Text(musician['name']),
                  subtitle: Text(
                    (musician['genres'] as List<String>).join(', '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
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
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Radio<String>(
                        value: musician['id'],
                        groupValue: _selectedMusicianId,
                        onChanged: (value) {
                          setState(() {
                            _selectedMusicianId = value;
                            _selectedMusicianName = musician['name'];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
  
  Widget _buildSelectedMusicianCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Músico Selecionado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: Text(_selectedMusicianName!),
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(Constants.defaultProfileImage),
            ),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  _selectedMusicianId = null;
                  _selectedMusicianName = null;
                  _loadMusicians();
                });
              },
              child: const Text('ALTERAR'),
            ),
          ),
        ),
      ],
    );
  }
}