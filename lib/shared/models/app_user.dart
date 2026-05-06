class AppUser {
  final String id;
  final String email;
  final String username;
  final bool isActive;
  final String? roleCode;
  final String? roleName;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
    this.roleCode,
    this.roleName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Handling nested join from Supabase: users -> user_roles -> roles
    String? rCode;
    String? rName;
    
    if (json['user_roles'] != null && (json['user_roles'] as List).isNotEmpty) {
      final roleData = json['user_roles'][0]['roles'];
      if (roleData != null) {
        rCode = roleData['code'];
        rName = roleData['name'];
      }
    }

    return AppUser(
      id: json['id'],
      email: json['email'],
      username: json['username'] ?? '',
      isActive: json['is_active'] ?? true,
      roleCode: rCode,
      roleName: rName,
    );
  }
}
