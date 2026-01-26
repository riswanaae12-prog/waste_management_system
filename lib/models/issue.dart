class Issue {
  final String id;
  final String userId;
  final String binId;
  final String title;
  final String description;
  final String issueType; // 'overflow', 'damage', 'sensor_malfunction', 'other'
  final List<String> images;
  final String status; // 'open', 'in_progress', 'resolved'
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  Issue({
    required this.id,
    required this.userId,
    required this.binId,
    required this.title,
    required this.description,
    required this.issueType,
    required this.images,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      binId: json['binId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      issueType: json['issueType'] ?? 'other',
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
      resolution: json['resolution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'binId': binId,
      'title': title,
      'description': description,
      'issueType': issueType,
      'images': images,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolution': resolution,
    };
  }

  Issue copyWith({
    String? id,
    String? userId,
    String? binId,
    String? title,
    String? description,
    String? issueType,
    List<String>? images,
    String? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolution,
  }) {
    return Issue(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      binId: binId ?? this.binId,
      title: title ?? this.title,
      description: description ?? this.description,
      issueType: issueType ?? this.issueType,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
    );
  }
}
