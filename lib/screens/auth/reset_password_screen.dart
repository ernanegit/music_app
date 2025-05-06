import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/loading_indicator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() {
        _resetSent = true;
      });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _resetSent ? _buildSuccessMessage() : _buildResetForm(),
                ),
              ),
            ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ícone
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: Colors.indigo,
          ),
          const SizedBox(height: 24),

          // Título
          const Text(
            'Recuperação de Senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),

          // Instruções
          const Text(
            'Informe seu email para receber um link de recuperação de senha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // Campo de Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _requestPasswordReset(),
          ),
          const SizedBox(height: 24),

          // Botão de Enviar
          ElevatedButton(
            onPressed: _requestPasswordReset,
            child: const Text('ENVIAR LINK DE RECUPERAÇÃO'),
          ),
          const SizedBox(height: 16),

          // Link para voltar para o login
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              );
            },
            child: const Text('Voltar para o login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ícone de sucesso
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 24),

        // Mensagem de sucesso
        const Text(
          'Email enviado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 16),

        // Instruções
        Text(
          'Enviamos um link de recuperação de senha para ${_emailController.text}. Por favor, verifique sua caixa de entrada e siga as instruções.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),

        // Botão para voltar ao login
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.login,
            );
          },
          child: const Text('VOLTAR PARA O LOGIN'),
        ),
      ],
    );
  }
}