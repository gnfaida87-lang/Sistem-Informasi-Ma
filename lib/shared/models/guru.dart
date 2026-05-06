class Guru {
  final String id;
  final String? userId;
  final String? nip;
  final String nama;
  final bool isWaliKelas;
  final String? username; // Diambil dari tabe users

  Guru({
    required this.id,
    this.userId,
    this.nip,
    required this.nama,
    this.isWaliKelas = false,
    this.username,
  });

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      id: json['id'],
      userId: json['user_id'],
      nip: json['nip'],
      nama: json['nama'],
      isWaliKelas: json['is_wali_kelas'] ?? false,
      username: json['users'] != null ? json['users']['username'] : null,
    );
  }
}
