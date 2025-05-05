class Validators {
  // Validar nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu nome';
    }
    if (value.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu email';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, informe um email válido';
    }
    return null;
  }

  // Validar senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // Validar confirmação de senha
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // Validar telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    if (value.length < 10) {
      return 'Por favor, informe um telefone válido';
    }
    return null;
  }

  // Validar cidade
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe sua cidade';
    }
    return null;
  }

  // Validar estado
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe seu estado';
    }
    return null;
  }
}
