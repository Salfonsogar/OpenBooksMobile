class AuthValidators {
  AuthValidators._();

  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );

  static String? validateEmail(String value) {
    if (value.isEmpty) return 'Ingresa tu correo electrónico';
    if (!emailRegex.hasMatch(value)) return 'Ingresa un correo electrónico válido';
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'Ingresa tu contraseña';
    if (!passwordRegex.hasMatch(value)) {
      return 'Mínimo 8 caracteres, mayúscula, minúscula y carácter especial';
    }
    return null;
  }

  static String? validateRequired(String value, String fieldName) {
    if (value.isEmpty) return 'Ingresa tu $fieldName';
    return null;
  }

  static String? validateMinLength(String value, int min, String fieldName) {
    if (value.length < min) {
      return 'El $fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? validateConfirmPassword(String value, String password) {
    if (value.isEmpty) return 'Confirma tu contraseña';
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }
}
