class ParkingSensor {
  final String id;
  final String deviceName;
  final String description;
  final int availableSlots;
  final int occupiedSlots;
  final bool isActive;
  final DateTime updatedAt;

  ParkingSensor({
    required this.id,
    required this.deviceName,
    required this.description,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.isActive,
    required this.updatedAt,
  });

  factory ParkingSensor.fromJson(Map<String, dynamic> json) {
    return ParkingSensor(
      id: json['id'] ?? '',
      deviceName: json['device_name'] ?? 'Unknown Sensor',
      description: json['description'] ?? '',
      availableSlots: json['available_slots'] ?? 0,
      occupiedSlots: json['occupied_slots'] ?? 0,
      isActive: json['is_active'] ?? false,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'description': description,
      'available_slots': availableSlots,
      'occupied_slots': occupiedSlots,
      'is_active': isActive,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
