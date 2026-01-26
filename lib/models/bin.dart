class Bin {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final double fillLevel; // 0-100
  final String status; // 'available', 'full', 'maintenance'
  final String wasteType; // 'general', 'organic', 'recyclable', 'hazardous'
  final double capacity;
  final DateTime lastEmptied;
  final DateTime lastUpdated;
  final String? sensorsData;

  Bin({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.fillLevel,
    required this.status,
    required this.wasteType,
    required this.capacity,
    required this.lastEmptied,
    required this.lastUpdated,
    this.sensorsData,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      fillLevel: (json['fillLevel'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'available',
      wasteType: json['wasteType'] ?? 'general',
      capacity: (json['capacity'] ?? 100.0).toDouble(),
      lastEmptied: DateTime.parse(json['lastEmptied'] ?? DateTime.now().toString()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toString()),
      sensorsData: json['sensorsData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'fillLevel': fillLevel,
      'status': status,
      'wasteType': wasteType,
      'capacity': capacity,
      'lastEmptied': lastEmptied.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'sensorsData': sensorsData,
    };
  }

  Bin copyWith({
    String? id,
    String? location,
    double? latitude,
    double? longitude,
    double? fillLevel,
    String? status,
    String? wasteType,
    double? capacity,
    DateTime? lastEmptied,
    DateTime? lastUpdated,
    String? sensorsData,
  }) {
    return Bin(
      id: id ?? this.id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fillLevel: fillLevel ?? this.fillLevel,
      status: status ?? this.status,
      wasteType: wasteType ?? this.wasteType,
      capacity: capacity ?? this.capacity,
      lastEmptied: lastEmptied ?? this.lastEmptied,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sensorsData: sensorsData ?? this.sensorsData,
    );
  }
}
