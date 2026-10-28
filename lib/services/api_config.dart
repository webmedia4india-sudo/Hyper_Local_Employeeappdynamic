import 'api_service.dart';

/// Backward compatibility
/// 
/// Base URL and all endpoints are now defined directly inside [ApiService].
class ApiConfig {
  static const String baseUrl = ApiService.baseUrl;
  
}
