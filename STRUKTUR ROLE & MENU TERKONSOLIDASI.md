STRUKTUR ROLE & MENU TERKONSOLIDASI
1. SUPERADMIN
Fokus: Sistem & Keamanan
Bukan Operasional Akademik
Hak Utama:
Kontrol sistem, keamanan, dan integrasi.
Menu:
1. Dashboard Sistem
•	Statistik User
•	Aktivitas Login
•	Error Log
•	Status Server
2. Manajemen User
•	Daftar User
•	Tambah User
•	Atur Role
•	Reset Password
•	Nonaktifkan User
3. Role & Hak Akses
•	Daftar Role
•	Edit Hak Akses
•	Mapping Role ke Menu
4. Monitoring Sistem
•	Log Aktivitas
•	Audit Trail
•	Riwayat Perubahan Data
5. Backup & Maintenance
•	Backup Database
•	Restore
•	Maintenance Mode
6. Pengaturan Integrasi
•	API AI Sahabat Guru
•	API AI Sahabat Belajar
Batasan:
•	Tidak mengelola jadwal
•	Tidak input nilai
•	Tidak input absensi
•	Tidak kelola keuangan operasional

2. KEPALA MADRASAH
Fokus: Monitoring Strategis
Menu:
1. Dashboard Ringkasan
•	Total Siswa
•	Rata-rata Kehadiran
•	Persentase Ketuntasan
•	Total Pemasukan
•	Grafik Akademik
2. Laporan Akademik
•	Rekap Nilai Sekolah
•	Rekap Absensi
•	Rapor per Tingkatan
3. Laporan Keuangan
•	Pemasukan Bulanan
•	Tunggakan
•	Laporan Tahunan
5. Pengumuman
•	Buat Pengumuman
•	Arsip Pengumuman
Batasan:
•	Tidak input data
•	Tidak edit jadwal
•	Tidak input nilai

3. WAKIL KURIKULUM
Fokus: Kendali Akademik
Role tetap ada walaupun dirangkap.
Menu:
1. Master Akademik (Read + Validasi)
•	Tahun Ajaran
•	Semester
•	Jurusan
•	KKM
2. Jadwal (Pengendali Tunggal)
•	Buat / Edit Jadwal Pelajaran
•	Distribusi Mengajar
•	Jadwal Ujian
3. Monitoring Akademik
•	Guru Belum Input Nilai
•	Kelas Belum Absensi
•	Progress Penilaian
4. Rapor
•	Generate Rapor
•	Validasi Rapor
•	Leger Nilai
5. Kenaikan Kelas
•	Kriteria Kenaikan
•	Proses Naik Kelas
•	Arsip Alumni

6. Laporan Bimbel
•	Peserta Aktif
•	Kehadiran
•	Nilai Rata-rata
Batasan:
•	Tidak input nilai langsung
•	Tidak input absensi

4. OPERATOR DATA
Fokus: Satu Pintu Master Data
Menu:
1. Data Siswa
•	Tambah Siswa
•	Edit Siswa
•	Mutasi
•	Nonaktifkan
2. Data Guru
•	Tambah Guru
•	Edit Guru
•	Penugasan Mengajar
3. Data Kelas
•	Tambah Kelas
•	Wali Kelas
•	Mapping Jurusan
4. Data Mata Pelajaran
•	Tambah Mapel
•	Edit Mapel
•	Kelompok Mapel
5. Master Bimbel
•	Data Guru Bimbel
•	Program Bimbel
•	Daftar Peserta
•	Buat Jadwal Bimbel
Batasan:
•	Tidak input nilai
•	Tidak input absensi
•	Tidak generate rapor

5. ADMIN KEUANGAN
Fokus: Keuangan Sekolah
Terpisah total dari akademik.
Menu:
1. Jenis Pembayaran
•	SPP
•	Ujian
•	Daftar Ulang
•	Lainnya
2. Tagihan
•	Generate Tagihan
•	Tagihan per Siswa
•	Tunggakan
3. Pembayaran
•	Input Pembayaran
•	Verifikasi
•	Cetak Kwitansi
4. Tabungan
•	Input Setoran
•	Penarikan
•	Rekap Tabungan
5. Laporan Keuangan
•	Laporan Bulanan
•	Laporan Tahunan
•	Rekap per Kelas

6. GURU MATA PELAJARAN
Fokus: Operasional Mengajar
Menu:
1. Jadwal Mengajar
•	Jadwal Hari Ini
•	Jadwal Mingguan
2. Absensi
•	Input Absensi
•	Riwayat Absensi
3. Penilaian
•	Input Nilai Tugas
•	Input Nilai PTS / PAS / UAS
•	Rekap Nilai
•	Lihat hasil nilai 
4. Materi Pembelajaran
•	Upload Materi (Link Google Drive)
•	Link Zoom / Meet
•	Latihan (CBT PG/Essai)
•	Hasil Latihan Perkelas Daftar List kelas dan siswa 
•	Arsip Materi
5. Al-Qur’an Digital
•	Pencarian Ayat
•	Audio MP3
6. AI Sahabat Guru
7. Pengumuman Kelas
•	Buat Pengumuman
•	Arsip

7. WALI KELAS
Bukan role terpisah.
Tambahan hak pada Guru (Flag: is_wali_kelas = true)
Tambahan Menu:
8. Data Siswa Kelas
•	Profil Siswa
9. Rekap Kelas
•	Rekap Nilai
•	Rekap Absensi

8. GURU BIMBEL
Fokus: Operasional Bimbel
Menu:
1. Jadwal Bimbel
•	Jadwal Hari Ini
2. Absensi Bimbel
•	Input Absensi
•	Riwayat
3. Nilai Bimbel
•	Input Nilai
•	Rekap Nilai
4. Materi & Latihan
•	Upload Materi (Link Google Drive)
•	Link Zoom / Meet
•	Video Pelajaran (Link YouTube)
•	Latihan (CBT PG/Essai)
•	Hasil Latihan List Siswa 
•	Arsip Materi (Reusable / Repostable)
5. Al-Qur’an Digital
6. AI Sahabat Guru
7. Pengumuman

9. ORANG TUA SISWA
1. Akademik
•	Lihat Nilai Tugas / PTS / PAS / UAS per Semester
•	Lihat Rapor per Semester
•	Absensi per Semester
2. Keuangan
•	Tagihan
•	Riwayat Pembayaran
•	Tabungan
3. Jadwal
•	Jadwal Pelajaran per Semester
•	Jadwal Ujian per Semester
4. Materi & Tugas
•	Materi
•	Tugas
•	Status Pengumpulan
5. Bimbel
•	Program Terdaftar
•	Jadwal Bimbel
•	Nilai Bimbel
•	Absensi Bimbel
6. Al-Qur’an Digital
7. AI Sahabat Belajar
8. Pengumuman

CATATAN ARSITEKTUR FINAL (DIPERTEGAS)
1.	Wakakur tetap ada sebagai role walaupun dirangkap.
2.	Master data hanya satu pintu → Operator.
3.	Jadwal hanya satu pengendali utama → Wakakur.
4.	Guru hanya operasional.
5.	Keuangan terpisah total dari akademik.
6.	Wali kelas adalah flag tambahan pada guru.
7.	API key hanya dapat diakses oleh Superadmin.

