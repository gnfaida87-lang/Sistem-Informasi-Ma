class Announcement {
  final String id;
  final String title;
  final String content;
  final String targetRole;
  final String createdBy;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.targetRole,
    required this.createdBy,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      targetRole: json['target_role'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'target_role': targetRole,
      'created_by': createdBy,
    };
  }
}
