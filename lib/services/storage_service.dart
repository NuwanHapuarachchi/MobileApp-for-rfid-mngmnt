import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class StorageService {
  static final _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // User data operations
  Future<void> saveUser(UserModel user) async {
    await init();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    await init();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await init();
    await prefs.remove(AppConstants.userKey);
  }

  // Auth token operations
  Future<void> saveAuthToken(String token) async {
    await init();
    await prefs.setString(AppConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    await init();
    return prefs.getString(AppConstants.authTokenKey);
  }

  Future<void> removeAuthToken() async {
    await init();
    await prefs.remove(AppConstants.authTokenKey);
  }

  // Theme operations
  Future<void> saveThemeMode(String themeMode) async {
    await init();
    await prefs.setString(AppConstants.themeKey, themeMode);
  }

  Future<String> getThemeMode() async {
    await init();
    return prefs.getString(AppConstants.themeKey) ?? 'dark';
  }

  // Generic operations
  Future<void> saveString(String key, String value) async {
    await init();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await init();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await init();
    await prefs.setInt(key, value);
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    await init();
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<void> saveDouble(String key, double value) async {
    await init();
    await prefs.setDouble(key, value);
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    await init();
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await init();
    await prefs.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    await init();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await init();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    await init();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await init();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    await init();
    await prefs.clear();
  }

  Future<bool> containsKey(String key) async {
    await init();
    return prefs.containsKey(key);
  }

  Future<Set<String>> getKeys() async {
    await init();
    return prefs.getKeys();
  }

  // App-specific settings
  Future<void> saveReaderRefreshInterval(int seconds) async {
    await saveInt('reader_refresh_interval', seconds);
  }

  Future<int> getReaderRefreshInterval() async {
    return await getInt('reader_refresh_interval', defaultValue: 30);
  }

  Future<void> saveAutoRefreshEnabled(bool enabled) async {
    await saveBool('auto_refresh_enabled', enabled);
  }

  Future<bool> getAutoRefreshEnabled() async {
    return await getBool('auto_refresh_enabled', defaultValue: true);
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await saveBool('notifications_enabled', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    return await getBool('notifications_enabled', defaultValue: true);
  }

  Future<void> saveDefaultPageSize(int size) async {
    await saveInt('default_page_size', size);
  }

  Future<int> getDefaultPageSize() async {
    return await getInt('default_page_size',
        defaultValue: AppConstants.defaultPageSize);
  }

  // Recent searches
  Future<void> addRecentSearch(String search) async {
    final searches = await getStringList('recent_searches');
    searches.remove(search); // Remove if already exists
    searches.insert(0, search); // Add to beginning

    // Keep only last 10 searches
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }

    await saveStringList('recent_searches', searches);
  }

  Future<List<String>> getRecentSearches() async {
    return await getStringList('recent_searches');
  }

  Future<void> clearRecentSearches() async {
    await remove('recent_searches');
  }
}
