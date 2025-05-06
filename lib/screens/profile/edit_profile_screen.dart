import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  String _country = 'Brasil';
  File? _profileImage;
  bool _imageChanged = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      if (user.phone != null) {
        _phoneController.text = user.phone!;
      }
      if (user.location != null) {
        if (user.location!.city != null) {
          _cityController.text = user.location!.city!;
        }
        if (user.location!.state != null) {
          _stateController.text = user.location!.state!;
        }
        _country = user.location!.country;
      }
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _imageChanged = true;
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Prepare location data
    final location = <String, String>{};
    if (_cityController.text.isNotEmpty) {
      location['city'] = _cityController.text.trim();
    }
    if (_stateController.text.isNotEmpty) {
      location['state'] = _stateController.text.trim();
    }
    location['country'] = _country;
    
    // TODO: Upload profile image if changed
    String? profileImageUrl;
    if (_imageChanged && _profileImage != null) {
      // Implementar upload da imagem no futuro
      // por enquanto, use a imagem padrão
      profileImageUrl = Constants.defaultProfileImage;
    }
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
      location: location,
      profileImage: profileImageUrl,
    );
    
    if (!mounted) return;
    
    if (success) {
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Perfil atualizado com sucesso',
      );
      Navigator.pop(context);
    } else if (authProvider.errorMessage != null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        authProvider.errorMessage!,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não encontrado'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto de perfil
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _imageChanged && _profileImage != null
                                ? FileImage(_profileImage!) as ImageProvider
                                : NetworkImage(
                                    user.profileImage.isNotEmpty
                                        ? user.profileImage
                                        : Constants.defaultProfileImage,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Campo de Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de Telefone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone (opcional)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    
                    // Seção de Localização
                    const Text(
                      'Localização',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Campo de Cidade
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: Validators.validateCity,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de Estado
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: Validators.validateState,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de País
                    DropdownButtonFormField<String>(
                      value: _country,
                      decoration: const InputDecoration(
                        labelText: 'País',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Brasil',
                          child: Text('Brasil'),
                        ),
                        // Adicionar mais países conforme necessário
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _country = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Botão de Salvar
                    ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('SALVAR ALTERAÇÕES'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botão de Cancelar
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('CANCELAR'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}