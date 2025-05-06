import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_indicator.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      user.profileImage.isNotEmpty
                          ? user.profileImage
                          : Constants.defaultProfileImage,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome do usuário
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tipo de usuário
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatUserType(user.userType),
                      style: TextStyle(
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seção de Informações
                  _buildInfoSection('Informações de Contato', [
                    _buildInfoItem(Icons.email, 'Email', user.email),
                    if (user.phone != null && user.phone!.isNotEmpty)
                      _buildInfoItem(Icons.phone, 'Telefone', user.phone!),
                  ]),
                  const SizedBox(height: 16),

                  // Seção de Localização
                  if (user.location != null)
                    _buildInfoSection('Localização', [
                      if (user.location!.city != null && user.location!.city!.isNotEmpty)
                        _buildInfoItem(
                          Icons.location_city,
                          'Cidade',
                          user.location!.city!,
                        ),
                      if (user.location!.state != null && user.location!.state!.isNotEmpty)
                        _buildInfoItem(
                          Icons.map,
                          'Estado',
                          user.location!.state!,
                        ),
                      _buildInfoItem(
                        Icons.flag,
                        'País',
                        user.location!.country,
                      ),
                    ]),
                  const SizedBox(height: 32),

                  // Botões de ação
                  if (authProvider.isMusician)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.portfolio);
                      },
                      icon: const Icon(Icons.music_note),
                      label: const Text('Gerenciar Portfólio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.contracts);
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Meus Contratos'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.reviews);
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('Minhas Avaliações'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const Divider(),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatUserType(String userType) {
    if (userType == 'músico') {
      return 'Músico';
    } else if (userType == 'contratante') {
      return 'Contratante';
    }
    return userType;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}