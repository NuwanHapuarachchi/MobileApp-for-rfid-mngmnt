class WarehouseModel {
  final String id;
  final String name;
  final String location;
  final String? managerUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data for display
  final String? managerName;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.location,
    this.managerUserId,
    required this.createdAt,
    required this.updatedAt,
    this.managerName,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      managerUserId: json['manager_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      managerName: json['manager_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'manager_user_id': managerUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;
  String get managerDisplay => managerName ?? 'No manager assigned';

  WarehouseModel copyWith({
    String? id,
    String? name,
    String? location,
    String? managerUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? managerName,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      managerUserId: managerUserId ?? this.managerUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      managerName: managerName ?? this.managerName,
    );
  }
}
