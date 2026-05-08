class ApiConstants {
  // Pakai IP WiFi rumah kamu yang baru
  static const String baseUrl = 'http://192.168.100.148:8081/v1';
  
  // Endpoints tetap sama
  static const String verifyToken = '/auth/verify-token'; 
  static const String register    = '/auth/register';    
  static const String login       = '/auth/login';       
  static const String products    = '/products';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}