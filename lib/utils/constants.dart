class AppConstants {
  // API Base URLs
  static const String baseUrlLocal = 'http://localhost:8000/api';  // Removed trailing slash
  static const String baseUrlProduction = 'https://webfw23.myhost.id/gol_e5/petcare/api';
  
  // Current environment - ganti ke production jika sudah deploy
  static bool isProduction = false;  // Set to false for localhost development
  static String get baseUrl => isProduction ? baseUrlProduction : baseUrlLocal;

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  
  // Complete API URLs
  static String get loginUrl => baseUrl + loginEndpoint;
  static String get registerUrl => baseUrl + registerEndpoint;
  static String get logoutUrl => baseUrl + logoutEndpoint;

  // SharedPreferences Keys
  static const String customerDataKey = 'customer_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String authTokenKey = 'auth_token';

  // App Info
  static const String appName = 'PetCare App';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Pixel Posse';
  static const String copyrightYear = '2022';

  // Colors
  static const int primaryColorValue = 0xFF4CAF50;
  static const int secondaryColorValue = 0xFF81C784;
  static const int errorColorValue = 0xFFFF5252;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF4CAF50;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 255;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 500;

  // Messages
  static const String networkError = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  static const String serverError = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
  static const String loginSuccess = 'Login berhasil!';
  static const String loginFailed = 'Email atau password salah';
  static const String registerSuccess = 'Registrasi berhasil!';
  static const String registerFailed = 'Registrasi gagal';
  static const String logoutSuccess = 'Logout berhasil!';
  static const String requiredFieldError = 'Field ini wajib diisi';
  static const String invalidEmailError = 'Format email tidak valid';
  static const String passwordTooShortError = 'Password minimal $minPasswordLength karakter';

  // Assets
  static const String logoAsset = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
}