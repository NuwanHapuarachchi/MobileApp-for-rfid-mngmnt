class RfidTagModel {
  final String id;
  final String tagUid; // The actual RFID tag UID
  final String ownerName;
  final String? description;
  final String status; // active, damaged, retired
  final DateTime createdAt;
  final DateTime updatedAt;

  RfidTagModel({
    required this.id,
    required this.tagUid,
    required this.ownerName,
    this.description,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory RfidTagModel.fromJson(Map<String, dynamic> json) {
    return RfidTagModel(
      id: json['id']?.toString() ?? '',
      tagUid: json['tag_uid']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_uid': tagUid,
      'owner_name': ownerName,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'damaged':
        return 'Damaged';
      case 'retired':
        return 'Retired';
      default:
        return 'Unknown';
    }
  }

  String get displayName {
    if (description?.isNotEmpty == true) {
      return description!;
    }
    return '$ownerName - $tagUid';
  }

  bool get isActive => status == 'active';
  bool get isDamaged => status == 'damaged';
  bool get isRetired => status == 'retired';

  RfidTagModel copyWith({
    String? id,
    String? tagUid,
    String? ownerName,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RfidTagModel(
      id: id ?? this.id,
      tagUid: tagUid ?? this.tagUid,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
