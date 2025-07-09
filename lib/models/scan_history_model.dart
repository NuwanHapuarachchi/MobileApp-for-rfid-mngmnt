class ScanHistoryModel {
  final String id;
  final String tagId;
  final String readerId;
  final String? userId;
  final DateTime timestamp;
  final String? warehouseId;
  final String? area;
  final double? coordinateX;
  final double? coordinateY;
  final double? coordinateZ;
  final String scanType; // entry, exit, inventory
  final int? confidenceScore;
  final DateTime createdAt;

  // Joined data for display
  final String? tagUid;
  final String? ownerName;
  final String? userName;
  final String? readerModel;
  final String? warehouseName;

  ScanHistoryModel({
    required this.id,
    required this.tagId,
    required this.readerId,
    this.userId,
    required this.timestamp,
    this.warehouseId,
    this.area,
    this.coordinateX,
    this.coordinateY,
    this.coordinateZ,
    required this.scanType,
    this.confidenceScore,
    required this.createdAt,
    this.tagUid,
    this.ownerName,
    this.userName,
    this.readerModel,
    this.warehouseName,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id']?.toString() ?? '',
      tagId: json['tag_id']?.toString() ?? '',
      readerId: json['reader_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      warehouseId: json['warehouse_id']?.toString(),
      area: json['area']?.toString(),
      coordinateX: json['coordinate_x'] != null
          ? (json['coordinate_x'] as num).toDouble()
          : null,
      coordinateY: json['coordinate_y'] != null
          ? (json['coordinate_y'] as num).toDouble()
          : null,
      coordinateZ: json['coordinate_z'] != null
          ? (json['coordinate_z'] as num).toDouble()
          : null,
      scanType: json['scan_type']?.toString() ?? 'entry',
      confidenceScore: json['confidence_score'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      tagUid: json['tag_uid']?.toString(),
      ownerName: json['owner_name']?.toString(),
      userName: json['user_name']?.toString(),
      readerModel: json['reader_model']?.toString(),
      warehouseName: json['warehouse_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_id': tagId,
      'reader_id': readerId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'warehouse_id': warehouseId,
      'area': area,
      'coordinate_x': coordinateX,
      'coordinate_y': coordinateY,
      'coordinate_z': coordinateZ,
      'scan_type': scanType,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get scanTypeDisplay {
    switch (scanType.toLowerCase()) {
      case 'entry':
        return 'Entry';
      case 'exit':
        return 'Exit';
      case 'inventory':
        return 'Inventory';
      default:
        return 'Unknown';
    }
  }

  String get displayName {
    return tagUid ?? 'Tag $tagId';
  }

  String get locationDisplay {
    if (area != null) return area!;
    if (coordinateX != null && coordinateY != null) {
      return 'X: ${coordinateX!.toStringAsFixed(1)}, Y: ${coordinateY!.toStringAsFixed(1)}';
    }
    return 'Unknown location';
  }

  String get timeDisplay {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  bool get isEntry => scanType == 'entry';
  bool get isExit => scanType == 'exit';
  bool get isInventory => scanType == 'inventory';

  ScanHistoryModel copyWith({
    String? id,
    String? tagId,
    String? readerId,
    String? userId,
    DateTime? timestamp,
    String? warehouseId,
    String? area,
    double? coordinateX,
    double? coordinateY,
    double? coordinateZ,
    String? scanType,
    int? confidenceScore,
    DateTime? createdAt,
    String? tagUid,
    String? ownerName,
    String? userName,
    String? readerModel,
    String? warehouseName,
  }) {
    return ScanHistoryModel(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      readerId: readerId ?? this.readerId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      warehouseId: warehouseId ?? this.warehouseId,
      area: area ?? this.area,
      coordinateX: coordinateX ?? this.coordinateX,
      coordinateY: coordinateY ?? this.coordinateY,
      coordinateZ: coordinateZ ?? this.coordinateZ,
      scanType: scanType ?? this.scanType,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      tagUid: tagUid ?? this.tagUid,
      ownerName: ownerName ?? this.ownerName,
      userName: userName ?? this.userName,
      readerModel: readerModel ?? this.readerModel,
      warehouseName: warehouseName ?? this.warehouseName,
    );
  }
}
