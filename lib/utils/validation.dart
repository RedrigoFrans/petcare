import '../utils/constants.dart';

class ValidationUtils {
  // Validasi email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return AppConstants.invalidEmailError;
    }
    
    if (email.length > AppConstants.maxEmailLength) {
      return 'Email maksimal ${AppConstants.maxEmailLength} karakter';
    }
    
    return null;
  }

  // Validasi password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShortError;
    }
    
    return null;
  }

  // Validasi nama
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    if (name.length > AppConstants.maxNameLength) {
      return 'Nama maksimal ${AppConstants.maxNameLength} karakter';
    }
    
    return null;
  }

  // Validasi nomor telepon
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    // Hanya angka dan beberapa simbol yang diperbolehkan
    final phoneRegex = RegExp(r'^[+]?[0-9\-\s\(\)]+$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Format nomor telepon tidak valid';
    }
    
    if (phone.length > AppConstants.maxPhoneLength) {
      return 'Nomor telepon maksimal ${AppConstants.maxPhoneLength} karakter';
    }
    
    return null;
  }

  // Validasi alamat
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    if (address.length > AppConstants.maxAddressLength) {
      return 'Alamat maksimal ${AppConstants.maxAddressLength} karakter';
    }
    
    return null;
  }

  // Validasi konfirmasi password
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppConstants.requiredFieldError;
    }
    
    if (password != confirmPassword) {
      return 'Konfirmasi password tidak cocok';
    }
    
    return null;
  }

  // Cek apakah string berisi karakter khusus
  static bool hasSpecialCharacters(String text) {
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharRegex.hasMatch(text);
  }

  // Cek kekuatan password
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = ValidationUtils.hasSpecialCharacters(password);
    
    int strengthPoints = 0;
    if (hasUppercase) strengthPoints++;
    if (hasLowercase) strengthPoints++;
    if (hasDigits) strengthPoints++;
    if (hasSpecialCharacters) strengthPoints++;
    if (password.length >= 8) strengthPoints++;
    
    if (strengthPoints >= 4) return PasswordStrength.strong;
    if (strengthPoints >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get text {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Lemah';
      case PasswordStrength.medium:
        return 'Sedang';
      case PasswordStrength.strong:
        return 'Kuat';
    }
  }
  
  int get colorValue {
    switch (this) {
      case PasswordStrength.empty:
        return 0xFF9E9E9E;
      case PasswordStrength.weak:
        return AppConstants.errorColorValue;
      case PasswordStrength.medium:
        return AppConstants.warningColorValue;
      case PasswordStrength.strong:
        return AppConstants.successColorValue;
    }
  }
}