class Mapel {
  final String id;
  final String nama;
  final String? kode;
  final int kkm;

  Mapel({
    required this.id,
    required this.nama,
    this.kode,
    this.kkm = 75,
  });

  factory Mapel.fromJson(Map<String, dynamic> json) {
    return Mapel(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      kkm: json['kkm'] ?? 75,
    );
  }
}

class Kelas {
  final String id;
  final String nama;
  final String? waliKelasId;
  final String? waliKelasNama;

  Kelas({
    required this.id,
    required this.nama,
    this.waliKelasId,
    this.waliKelasNama,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      nama: json['nama'],
      waliKelasId: json['wali_kelas_id'],
      waliKelasNama: json['guru'] != null ? json['guru']['nama'] : null,
    );
  }
}
