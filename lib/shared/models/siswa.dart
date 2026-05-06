class Siswa {
  final String id;
  final String nis;
  final String nama;
  final String? kelasId;
  final String status;
  final String? parentName; // Diambil lewat join table orang_tua_siswa

  Siswa({
    required this.id,
    required this.nis,
    required this.nama,
    this.kelasId,
    required this.status,
    this.parentName,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    String? pName;
    if (json['orang_tua_siswa'] != null && (json['orang_tua_siswa'] as List).isNotEmpty) {
      final ot = json['orang_tua_siswa'][0]['orang_tua'];
      if (ot != null) {
        pName = ot['nama'];
      }
    }

    return Siswa(
      id: json['id'],
      nis: json['nis'],
      nama: json['nama'],
      kelasId: json['kelas_id'],
      status: json['status'] ?? 'active',
      parentName: pName,
    );
  }
}
