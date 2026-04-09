// lib/core/constants/route_constants.dart

class RouteConstants {
  RouteConstants._();

  static const String home = '/';
  static const String plants = '/plants';
  static const String plantsAdd = '/plants/add';

  /// UUID sebagai path parameter
  /// Contoh: /plants/550e8400-e29b-41d4-a716-446655440000
  static String plantsDetail(String id) => '/plants/$id';
  static String plantsEdit(String id) => '/plants/$id/edit';

  static const String profile = '/profile';
}