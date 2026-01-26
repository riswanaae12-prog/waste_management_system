class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'bin_full', 'issue_update', 'collection_reminder', 'system'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedBinId;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.relatedBinId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      data: json['data'] ?? {},
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isRead: json['isRead'] ?? false,
      relatedBinId: json['relatedBinId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'relatedBinId': relatedBinId,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? relatedBinId,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedBinId: relatedBinId ?? this.relatedBinId,
    );
  }
}
