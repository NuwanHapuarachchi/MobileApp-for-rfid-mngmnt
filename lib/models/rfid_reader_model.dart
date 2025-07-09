class RfidReaderModel {
  final String id;
  final String serialNumber;
  final String model;
  final String location;
  final String? warehouseId;
  final String status; // active, maintenance, retired
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;

  RfidReaderModel({
    required this.id,
    required this.serialNumber,
    required this.model,
    required this.location,
    this.warehouseId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
  });

  factory RfidReaderModel.fromJson(Map<String, dynamic> json) {
    return RfidReaderModel(
      id: json['id']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      warehouseId: json['warehouse_id']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'model': model,
      'location': location,
      'warehouse_id': warehouseId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'Maintenance';
      case 'retired':
        return 'Retired';
      default:
        return 'Unknown';
    }
  }

  String get connectionStatus {
    if (lastSeen == null) return 'Never Connected';

    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 5) return 'Online';
    if (diff.inHours < 1) return 'Recently Online';
    return 'Offline';
  }

  RfidReaderModel copyWith({
    String? id,
    String? serialNumber,
    String? model,
    String? location,
    String? warehouseId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
  }) {
    return RfidReaderModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      model: model ?? this.model,
      location: location ?? this.location,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
