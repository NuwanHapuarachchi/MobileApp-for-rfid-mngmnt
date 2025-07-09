import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/rfid_reader_model.dart';
import '../models/rfid_tag_model.dart';
import '../models/scan_history_model.dart';
import 'auth_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Check if we should use demo data
  bool get _shouldUseDemoData => _authService.isDemoMode;

  // Mock data for demo mode
  List<RfidTagModel> get _demoTags => [
        RfidTagModel(
          id: '1',
          tagUid: 'TAG-001-ABC123',
          ownerName: 'Office Equipment',
          description: 'Laptop Dell XPS 13',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RfidTagModel(
          id: '2',
          tagUid: 'TAG-002-DEF456',
          ownerName: 'Inventory Item',
          description: 'Office Chair Ergonomic',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        RfidTagModel(
          id: '3',
          tagUid: 'TAG-003-GHI789',
          ownerName: 'Medical Equipment',
          description: 'Blood Pressure Monitor',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        RfidTagModel(
          id: '4',
          tagUid: 'TAG-004-JKL012',
          ownerName: 'Vehicle Fleet',
          description: 'Company Car Honda Civic',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        RfidTagModel(
          id: '5',
          tagUid: 'TAG-005-MNO345',
          ownerName: 'Tools',
          description: 'Power Drill Professional',
          status: 'damaged',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        RfidTagModel(
          id: '6',
          tagUid: 'TAG-006-PQR678',
          ownerName: 'Security Equipment',
          description: 'CCTV Camera Wireless',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  List<RfidReaderModel> get _demoReaders => [
        RfidReaderModel(
          id: '1',
          serialNumber: 'RDR-001',
          model: 'UHF Reader Pro',
          location: 'Main Entrance',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        RfidReaderModel(
          id: '2',
          serialNumber: 'RDR-002',
          model: 'UHF Reader Pro',
          location: 'Warehouse Gate',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        RfidReaderModel(
          id: '3',
          serialNumber: 'RDR-003',
          model: 'UHF Reader Lite',
          location: 'Office Door',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        RfidReaderModel(
          id: '4',
          serialNumber: 'RDR-004',
          model: 'UHF Reader Pro',
          location: 'Loading Dock',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        RfidReaderModel(
          id: '5',
          serialNumber: 'RDR-005',
          model: 'UHF Reader Lite',
          location: 'Storage Room',
          status: 'maintenance',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  List<ScanHistoryModel> get _demoScanHistory => [
        ScanHistoryModel(
          id: '1',
          tagId: '1',
          readerId: '1',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          scanType: 'entry',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          tagUid: 'TAG-001-ABC123',
          ownerName: 'Office Equipment',
        ),
        ScanHistoryModel(
          id: '2',
          tagId: '2',
          readerId: '2',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          scanType: 'inventory',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          tagUid: 'TAG-002-DEF456',
          ownerName: 'Inventory Item',
        ),
        ScanHistoryModel(
          id: '3',
          tagId: '3',
          readerId: '1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          scanType: 'exit',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          tagUid: 'TAG-003-GHI789',
          ownerName: 'Medical Equipment',
        ),
      ];

  // RFID Readers Operations

  Future<List<RfidReaderModel>> getReaders({
    int? limit,
    int? offset,
    String? status,
  }) async {
    if (_shouldUseDemoData) {
      await Future.delayed(const Duration(milliseconds: 500));
      var readers = List<RfidReaderModel>.from(_demoReaders);
      if (status != null && status != 'all') {
        readers = readers.where((reader) => reader.status == status).toList();
      }
      return readers.take(limit ?? 50).toList();
    }

    try {
      final response = await _supabase
          .from(AppConstants.readersTable)
          .select()
          .order('created_at', ascending: false)
          .limit(limit ?? 50);

      return (response as List)
          .map((json) => RfidReaderModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching readers: $e');
      throw Exception('Failed to fetch readers: $e');
    }
  }

  Future<RfidReaderModel?> getReader(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.readersTable)
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? RfidReaderModel.fromJson(response) : null;
    } catch (e) {
      print('Error fetching reader: $e');
      throw Exception('Failed to fetch reader: $e');
    }
  }

  Future<RfidReaderModel?> createReader(RfidReaderModel reader) async {
    try {
      final response = await _supabase
          .from(AppConstants.readersTable)
          .insert(reader.toJson())
          .select()
          .single();

      return RfidReaderModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<RfidReaderModel?> updateReader(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(AppConstants.readersTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return RfidReaderModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update reader: $e');
    }
  }

  Future<bool> deleteReader(String id) async {
    try {
      await _supabase.from(AppConstants.readersTable).delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete reader: $e');
    }
  }

  // RFID Tags Operations

  Future<List<RfidTagModel>> getTags({
    int? limit,
    int? offset,
    String? status,
    String? warehouse,
  }) async {
    if (_shouldUseDemoData) {
      await Future.delayed(const Duration(milliseconds: 500));
      var tags = List<RfidTagModel>.from(_demoTags);
      if (status != null && status != 'all') {
        tags = tags.where((tag) => tag.status == status).toList();
      }
      return tags.take(limit ?? 50).toList();
    }

    try {
      final response = await _supabase
          .from(AppConstants.tagsTable)
          .select()
          .order('created_at', ascending: false)
          .limit(limit ?? 50);

      return (response as List)
          .map((json) => RfidTagModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching tags: $e');
      throw Exception('Failed to fetch tags: $e');
    }
  }

  Future<RfidTagModel?> getTag(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.tagsTable)
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? RfidTagModel.fromJson(response) : null;
    } catch (e) {
      print('Error fetching tag: $e');
      throw Exception('Failed to fetch tag: $e');
    }
  }

  Future<RfidTagModel?> getTagByTagUid(String tagUid) async {
    try {
      final response = await _supabase
          .from(AppConstants.tagsTable)
          .select()
          .eq('tag_uid', tagUid)
          .maybeSingle();

      return response != null ? RfidTagModel.fromJson(response) : null;
    } catch (e) {
      print('Error fetching tag by UID: $e');
      throw Exception('Failed to fetch tag by UID: $e');
    }
  }

  Future<RfidTagModel?> createTag(RfidTagModel tag) async {
    try {
      final response = await _supabase
          .from(AppConstants.tagsTable)
          .insert(tag.toJson())
          .select()
          .single();

      return RfidTagModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<RfidTagModel?> updateTag(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(AppConstants.tagsTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return RfidTagModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update tag: $e');
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      await _supabase.from(AppConstants.tagsTable).delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }

  // Scan History Operations

  Future<List<ScanHistoryModel>> getScanHistory({
    int? limit,
    int? offset,
    String? tagId,
    String? readerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_shouldUseDemoData) {
      await Future.delayed(const Duration(milliseconds: 500));
      var scans = List<ScanHistoryModel>.from(_demoScanHistory);

      if (tagId != null) {
        scans = scans.where((scan) => scan.tagId == tagId).toList();
      }
      if (readerId != null) {
        scans = scans.where((scan) => scan.readerId == readerId).toList();
      }
      if (startDate != null) {
        scans =
            scans.where((scan) => scan.timestamp.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        scans =
            scans.where((scan) => scan.timestamp.isBefore(endDate)).toList();
      }

      return scans.take(limit ?? 50).toList();
    }

    try {
      var query = _supabase
          .from(AppConstants.scanHistoryTable)
          .select()
          .order('timestamp', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ScanHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching scan history: $e');
      throw Exception('Failed to fetch scan history: $e');
    }
  }

  Future<ScanHistoryModel?> createScanRecord(ScanHistoryModel scan) async {
    try {
      final response = await _supabase
          .from(AppConstants.scanHistoryTable)
          .insert(scan.toJson())
          .select()
          .single();

      return ScanHistoryModel.fromJson(response);
    } catch (e) {
      print('Error creating scan record: $e');
      throw Exception('Failed to create scan record: $e');
    }
  }

  // Analytics Operations

  Future<Map<String, dynamic>> getDashboardStats() async {
    if (_shouldUseDemoData) {
      await Future.delayed(const Duration(milliseconds: 500));

      final activeReaders =
          _demoReaders.where((r) => r.status == 'active').length;
      final activeTags = _demoTags.where((t) => t.status == 'active').length;
      final todayScans = _demoScanHistory.where((s) {
        final today = DateTime.now();
        final scanDate = s.timestamp;
        return scanDate.year == today.year &&
            scanDate.month == today.month &&
            scanDate.day == today.day;
      }).length;

      return {
        'total_readers': _demoReaders.length,
        'total_tags': _demoTags.length,
        'active_readers': activeReaders,
        'active_tags': activeTags,
        'today_scans': todayScans,
      };
    }

    try {
      // Get real data from your tables
      final readersResponse =
          await _supabase.from(AppConstants.readersTable).select('id, status');
      final tagsResponse =
          await _supabase.from(AppConstants.tagsTable).select('id, status');

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final scansResponse = await _supabase
          .from(AppConstants.scanHistoryTable)
          .select('id')
          .gte('timestamp', todayStart.toIso8601String());

      final readers = readersResponse as List;
      final tags = tagsResponse as List;
      final scans = scansResponse as List;

      final activeReaders =
          readers.where((r) => r['status'] == 'active').length;
      final activeTags = tags.where((t) => t['status'] == 'active').length;

      return {
        'total_readers': readers.length,
        'total_tags': tags.length,
        'active_readers': activeReaders,
        'active_tags': activeTags,
        'today_scans': scans.length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getScansPerDay({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await _supabase
          .from('scans')
          .select('timestamp')
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: true);

      final scans = response as List;

      // Group scans by day
      final Map<String, int> scansByDay = {};

      for (int i = 0; i < days; i++) {
        final day = endDate.subtract(Duration(days: i));
        final dayKey = '${day.day}/${day.month}';
        scansByDay[dayKey] = 0;
      }

      for (final scan in scans) {
        final timestamp = DateTime.parse(scan['timestamp']);
        final dayKey = '${timestamp.day}/${timestamp.month}';
        if (scansByDay.containsKey(dayKey)) {
          scansByDay[dayKey] = scansByDay[dayKey]! + 1;
        }
      }

      return scansByDay.entries
          .map((entry) => {'day': entry.key, 'scans': entry.value})
          .toList()
          .reversed
          .toList();
    } catch (e) {
      print('Error fetching scans per day: $e');
      throw Exception('Failed to fetch scans per day: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopTags({int limit = 5}) async {
    try {
      final response =
          await _supabase.from(AppConstants.scanHistoryTable).select('''
            tag_id,
            ${AppConstants.tagsTable}!${AppConstants.scanHistoryTable}_tag_id_fkey(tag_uid, owner_name)
          ''');

      final scans = response as List;

      // Count scans per tag
      final Map<String, Map<String, dynamic>> tagCounts = {};

      for (final scan in scans) {
        final tagId = scan['tag_id'];
        final tagData = scan[AppConstants.tagsTable];

        if (tagData != null) {
          final tagKey = tagId.toString();
          if (tagCounts.containsKey(tagKey)) {
            tagCounts[tagKey]!['count'] = tagCounts[tagKey]!['count'] + 1;
          } else {
            tagCounts[tagKey] = {
              'tag_uid': tagData['tag_uid'] ?? 'Unknown',
              'owner_name': tagData['owner_name'] ?? 'Unknown',
              'count': 1,
            };
          }
        }
      }

      // Sort by count and take top tags
      final sortedTags = tagCounts.values.toList();
      sortedTags
          .sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sortedTags.take(limit).toList();
    } catch (e) {
      print('Error fetching top tags: $e');
      throw Exception('Failed to fetch top tags: $e');
    }
  }

  // User Operations
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  // Warehouses Operations
  Future<List<Map<String, dynamic>>> getWarehouses() async {
    try {
      final response = await _supabase
          .from('warehouses')
          .select()
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('Error fetching warehouses: $e');
      return [];
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response =
          await _supabase.from(AppConstants.usersTable).select('id').limit(1);
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
