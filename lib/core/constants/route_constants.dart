// lib/core/constants/route_constants.dart

class RouteConstants {
  RouteConstants._();

  static const String home = '/';
  static const String plants = '/plants';
  static const String plantsAdd = '/plants/add';

  /// UUID sebagai path parameter
  static String plantsDetail(String id) => '/plants/$id';
  static String plantsEdit(String id) => '/plants/$id/edit';

  /// Route Bahasa Bunga
  static const String flowers = '/flowers';
  static const String flowersAdd = '/flowers/add';
  static String flowersDetail(String id) => '/flowers/$id';
  static String flowersEdit(String id) => '/flowers/$id/edit';

  static const String profile = '/profile';
}