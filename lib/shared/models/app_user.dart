class AppUser {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final bool isActive;
  final String? roleCode;
  final String? roleName;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.isActive,
    this.roleCode,
    this.roleName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Handle both nested structure (from older code) and flat structure (from D1 JOIN)
    String? rCode = json['role_code'];
    String? rName = json['role_name'];
    
    if (rCode == null && json['user_roles'] != null && (json['user_roles'] as List).isNotEmpty) {
      final roleData = json['user_roles'][0]['roles'];
      if (roleData != null) {
        rCode = roleData['code'];
        rName = roleData['name'];
      }
    }

    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['nama'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      roleCode: rCode,
      roleName: rName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'full_name': fullName,
    'is_active': isActive,
    'role_code': roleCode,
    'role_name': roleName,
  };
}
