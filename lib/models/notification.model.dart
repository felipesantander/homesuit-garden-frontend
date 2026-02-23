class AppNotification {
  final String id;
  final String message;
  final bool seen;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.seen,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      message: json['message'] as String,
      seen: json['seen'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'seen': seen,
      'created_at': createdAt,
    };
  }
}
