# Script para criar a tela de login
# Executar no diretório raiz do projeto Flutter

# Definir caminhos dos arquivos
$loginScreenPath = ".\lib\screens\auth\login_screen.dart"
$loadingIndicatorPath = ".\lib\widgets\common\loading_indicator.dart"

# Conteúdo do login_screen.dart
$loginScreenContent = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.musicians);
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
      body: authProvider.isLoading
          ? const LoadingIndicator()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        const Icon(
                          Icons.music_note,
                          size: 120,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 24),
                        
                        // Título
                        const Text(
                          'Bem-vindo à Plataforma Músico',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtítulo
                        const Text(
                          'Entre para conectar músicos e contratantes',
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
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo de Senha
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Botão de Entrar
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('ENTRAR'),
                        ),
                        const SizedBox(height: 16),
                        
                        // Link para recuperar senha
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.resetPassword,
                            );
                          },
                          child: const Text('Esqueci minha senha'),
                        ),
                        const SizedBox(height: 24),
                        
                        // Divisor
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OU'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Botão para Cadastrar
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.indigo),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('CRIAR CONTA'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
"@

# Conteúdo do loading_indicator.dart
$loadingIndicatorContent = @"
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
"@

# Função para criar arquivos (usando verbo aprovado)
function New-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$true)]
        [string]$Content
    )
    
    if ([string]::IsNullOrEmpty($Path)) {
        Write-Host "ERRO: O caminho do arquivo não pode ser vazio." -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path -Path $Path)) {
        try {
            # Criar diretório pai se não existir
            $parentDir = Split-Path -Path $Path -Parent
            if (-not (Test-Path -Path $parentDir)) {
                New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
                Write-Host "Diretório criado: $parentDir" -ForegroundColor Green
            }
            
            New-Item -Path $Path -ItemType File -Force | Out-Null
            Set-Content -Path $Path -Value $Content
            Write-Host "Arquivo criado: $Path" -ForegroundColor Green
        }
        catch {
            Write-Host "ERRO ao criar arquivo $Path : $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Arquivo já existe: $Path, substituindo conteúdo..." -ForegroundColor Yellow
        Set-Content -Path $Path -Value $Content
    }
}

# Verificar caminhos válidos
if ([string]::IsNullOrEmpty($loginScreenPath)) {
    Write-Host "ERRO: O caminho para o arquivo login_screen.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($loadingIndicatorPath)) {
    Write-Host "ERRO: O caminho para o arquivo loading_indicator.dart não foi definido corretamente." -ForegroundColor Red
    exit 1
}

# Criar os arquivos
New-File -Path $loginScreenPath -Content $loginScreenContent
New-File -Path $loadingIndicatorPath -Content $loadingIndicatorContent

Write-Host "Tela de login e widgets de suporte criados com sucesso!" -ForegroundColor Cyan