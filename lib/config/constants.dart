class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://uuqqhvipromhutlhqyjx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1cXFodmlwcm9taHV0bGhxeWp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxMDY3NDQsImV4cCI6MjA2MTY4Mjc0NH0.vqTjCzbJ8IcBclUQLlydO2BRXKELuG38cEcpYEuZEVA';

  // App Information
  static const String appName = 'RFID Manager';
  static const String appVersion = '1.0.0';

  // Table Names
  static const String usersTable = 'users';
  static const String readersTable = 'readers';
  static const String tagsTable = 'tags';
  static const String scanHistoryTable = 'scans';
  static const String settingsTable = 'settings';
  static const String warehousesTable = 'warehouses';
  static const String readerUserAssignmentsTable = 'reader_user_assignments';

  // Storage Keys
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String authTokenKey = 'auth_token';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // RFID Constants
  static const List<String> readerStatuses = [
    'active',
    'maintenance',
    'retired'
  ];
  static const List<String> tagStatuses = ['active', 'damaged', 'retired'];
  static const List<String> scanTypes = [
    'entry',
    'exit',
    'inventory',
    'maintenance'
  ];
}
