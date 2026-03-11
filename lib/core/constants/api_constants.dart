abstract final class ApiConstants {
  static const defaultBaseUrl = 'http://localhost:5001/api';
  static const sendVerificationCode = '/send-verification-code';
  static const register = '/register';
  static const login = '/login';
  static String user(String userId) => '/user/$userId';
  static String userProfile(String userId) => '/user/$userId/profile';
  static String userSettings(String userId) => '/user/$userId/settings';
  static String dashboardItems(String userId) => '/dashboard/$userId/items';
  static String dashboardItem(String userId, String itemId) =>
      '/dashboard/$userId/items/$itemId';
  static String dashboardAnalytics(String userId) =>
      '/dashboard/$userId/analytics';
}
