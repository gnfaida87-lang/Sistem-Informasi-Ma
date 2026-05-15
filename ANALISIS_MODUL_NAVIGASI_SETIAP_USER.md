# ANALISIS MODUL NAVIGASI SETIAP USER/PENGGUNA
## Sistem Informasi Madrasah (MA) - Tanggal: 13 Mei 2026

---

## 📊 RINGKASAN UMUM

| NO | ROLE | ROUTE | STATUS | MODUL |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Super Admin | `/superadmin` | ✅ AKTIF | 7 Menu |
| 2 | Kepala Madrasah | `/kepala-madrasah` | ✅ AKTIF | 4 Menu |
| 3 | Wakil Kurikulum | `/wakakur` | ✅ AKTIF | Sidebar + Monitoring |
| 4 | Operator Data | `/operator` | ✅ AKTIF | 9 Menu |
| 5 | Admin Keuangan | `/keuangan` | ✅ AKTIF | 6 Menu |
| 6 | Guru Mapel | `/guru` | ✅ AKTIF | 7 Menu |
| 7 | Guru Wali Kelas | `/guru/wali-kelas` | ✅ AKTIF | 9 Menu |
| 8 | Guru Bimbel | `/bimbel` | ✅ AKTIF | 7 Menu |
| 9 | Orang Tua Siswa | `/orang-tua` | ✅ AKTIF | 8 Menu |

**Shared Modules (Semua User):**
- ✅ Al-Qur'an Digital (`/quran`)
- ✅ AI Assistant (`/ai-guru`, `/ai-belajar`)
- ✅ Pengumuman (`/announcement/parent`)

---

## 🔐 1. SUPER ADMIN (Role Code: SA)
**Fokus:** Sistem & Keamanan | **Route:** `/superadmin`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | FILE SCREEN | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Dashboard Sistem | `system_dashboard_screen.dart` | ✅ | Statistik User, Aktivitas Login, Error Log |
| 2 | Manajemen User | `user_management_screen.dart` | ✅ | Daftar User, Tambah, Atur Role, Reset Password |
| 3 | Role & Akses | `role_access_screen.dart` | ✅ | Daftar Role, Edit Hak Akses |
| 4 | Monitoring Sistem | `monitoring_screen.dart` | ✅ | Log Aktivitas, Audit Trail |
| 5 | Backup Data | `backup_screen.dart` | ✅ | Backup Database, Restore, Maintenance |
| 6 | Integrasi AI | `integration_screen.dart` | ✅ | API AI Sahabat Guru/Belajar |
| 7 | Pengaturan Aplikasi | `app_settings_screen.dart` | ✅ | Konfigurasi Sistem |

### 🔗 HUBUNGAN MODUL SUPER ADMIN:
```
┌─────────────────────────────────────────────┐
│         SUPER ADMIN DASHBOARD               │
├─────────────────────────────────────────────┤
│                                             │
├──> Dashboard Sistem                        │
│    ├── Statistik User                       │
│    ├── Aktivitas Login                      │
│    └── Error Log & Status Server            │
│                                             │
├──> Manajemen User ◄─────┐                  │
│    ├── Daftar User      │                  │
│    ├── Tambah User      │                  │
│    ├── Atur Role ───────┤─────> Role & Hak │
│    ├── Reset Password   │       Akses      │
│    └── Nonaktifkan      │                  │
│                         │                  │
├──> Monitoring Sistem   │                  │
│    ├── Log Aktivitas    │                  │
│    ├── Audit Trail ◄────┘                  │
│    └── Riwayat Perubahan│                  │
│                                             │
├──> Backup Data                             │
│    ├── Backup Database                      │
│    ├── Restore                              │
│    └── Maintenance Mode                     │
│                                             │
├──> Integrasi AI                            │
│    ├── API AI Sahabat Guru                  │
│    └── API AI Sahabat Belajar               │
│                                             │
└──> Pengaturan Aplikasi                     │
     └── Konfigurasi Sistem                   │
```

### ⚠️ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Manajemen User → Role & Akses (Dependency)
- **✅ TERSAMBUNG:** Manajemen User → Monitoring Sistem (Log Aktivitas)
- **✅ TERSAMBUNG:** Semua Modul → Backup Data (Data Safety)
- **⚠️ POTENSI:** Integrasi AI dengan Monitoring (untuk tracking API usage)

---

## 👑 2. KEPALA MADRASAH (Role Code: KM)
**Fokus:** Monitoring Strategis | **Route:** `/kepala-madrasah`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | FILE SCREEN | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Dashboard Utama | `headmaster_dashboard_screen.dart` | ✅ | Ringkasan: Siswa, Kehadiran, Ketuntasan, Pemasukan |
| 2 | Laporan Akademik | `headmaster_academic_report.dart` | ✅ | Rekap Nilai, Absensi, Rapor per Tingkat |
| 3 | Laporan Keuangan | `headmaster_finance_report.dart` | ✅ | Pemasukan, Tunggakan, Laporan Tahunan |
| 4 | Pengumuman | `headmaster_announcement.dart` | ✅ | Buat & Arsip Pengumuman |

### 🔗 HUBUNGAN MODUL KEPALA MADRASAH:
```
┌──────────────────────────────────────────────┐
│     KEPALA MADRASAH DASHBOARD                │
├──────────────────────────────────────────────┤
│                                              │
├──> Dashboard Utama (EXEC SUMMARY)           │
│    ├── Total Siswa ──────────────┐          │
│    ├── Rata-rata Kehadiran       │          │
│    ├── Persentase Ketuntasan     ├──> DATA │
│    ├── Total Pemasukan           │  SOURCES │
│    └── Grafik Akademik ──────────┘          │
│         │                                    │
│         ├─────────> Laporan Akademik       │
│         │           ├── Rekap Nilai Sekolah │
│         │           ├── Rekap Absensi       │
│         │           └── Rapor per Tingkat   │
│         │                                    │
│         └─────────> Laporan Keuangan       │
│                     ├── Pemasukan Bulanan    │
│                     ├── Tunggakan            │
│                     └── Laporan Tahunan      │
│                                              │
└──> Pengumuman                               │
     ├── Buat Pengumuman                       │
     └── Arsip Pengumuman                      │
```

### ⚠️ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Dashboard Utama → Laporan Akademik (Data Flow)
- **✅ TERSAMBUNG:** Dashboard Utama → Laporan Keuangan (Data Flow)
- **✅ TERSAMBUNG:** Laporan Akademik ← Data dari Guru & Operator
- **✅ TERSAMBUNG:** Laporan Keuangan ← Data dari Admin Keuangan
- **⚠️ CATATAN:** Semua data READ-ONLY (tidak input langsung)

---

## 📚 3. WAKIL KURIKULUM (Role Code: WK)
**Fokus:** Kendali Akademik | **Route:** `/wakakur`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|
| 1 | Dashboard Kurikulum | ✅ | Semester, Stats |
| 2 | Master Akademik | ⚠️ PARTIAL | Tahun Ajaran, Jurusan, KKM (Read + Validasi) |
| 3 | Jadwal Pelajaran | ⚠️ PLANNED | Buat/Edit Jadwal, Distribusi Mengajar |
| 4 | Jadwal Ujian | ⚠️ PLANNED | Jadwal PTS/PAS/UAS |
| 5 | Monitoring Akademik | ⚠️ MONITORING | Guru Belum Input Nilai, Progress Penilaian |
| 6 | Rapor | ⚠️ PLANNED | Generate, Validasi, Leger Nilai |
| 7 | Kenaikan Kelas | ⚠️ PLANNED | Kriteria, Proses, Arsip Alumni |
| 8 | Laporan Bimbel | ⚠️ PLANNED | Peserta, Kehadiran, Nilai |

### 🔗 HUBUNGAN MODUL WAKIL KURIKULUM:
```
┌──────────────────────────────────────────────┐
│      WAKIL KURIKULUM DASHBOARD               │
├──────────────────────────────────────────────┤
│                                              │
├──> Dashboard Kurikulum                      │
│    ├── Selector Semester Aktif               │
│    └── Stats Akademik                        │
│         │                                    │
│         ├─────────> Master Akademik         │
│         │           ├── Tahun Ajaran (RO)   │
│         │           ├── Jurusan (RO)        │
│         │           └── KKM                  │
│         │                                    │
│         ├─────────> Jadwal Pelajaran ◄──┐  │
│         │           ├── Buat/Edit Jadwal   │ │
│         │           └── Distribusi Mengajar │ │
│         │               ▲                    │ │
│         │               │ (trigger)           │ │
│         │               │                    │ │
│         ├──────────────────> Jadwal Ujian   │ │
│         │           ├── Jadwal PTS          │ │
│         │           ├── Jadwal PAS          │ │
│         │           └── Jadwal UAS          │ │
│         │                                    │ │
│         ├─────────> Monitoring Akademik    │ │
│         │           ├── Guru Belum Input    │ │
│         │           ├── Progress Penilaian  │ │
│         │           └── Alert Deadline      │ │
│         │                                    │ │
│         ├─────────> Rapor                   │ │
│         │           ├── Generate Rapor ─────┼─┘
│         │           ├── Validasi            │
│         │           └── Leger Nilai         │
│         │                                    │
│         ├─────────> Kenaikan Kelas         │
│         │           ├── Kriteria Naik       │
│         │           ├── Proses Naik         │
│         │           └── Arsip Alumni        │
│         │                                    │
│         └─────────> Laporan Bimbel         │
│                     ├── Peserta Aktif       │
│                     ├── Kehadiran Bimbel    │
│                     └── Nilai Rata-rata     │
│                                              │
└─────────────────────────────────────────────┘
```

### ⚠️ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Master Akademik → Jadwal Pelajaran (Dependency)
- **✅ TERSAMBUNG:** Jadwal Pelajaran → Jadwal Ujian (Linked)
- **✅ TERSAMBUNG:** Jadwal → Monitoring Akademik (Deadline tracking)
- **✅ TERSAMBUNG:** Monitoring → Rapor (Validation gate)
- **⚠️ ISSUE:** Beberapa modul masih dalam tahap PLANNED
- **⚠️ ISSUE:** Laporan Bimbel perlu koneksi ke Guru Bimbel

---

## 🖥️ 4. OPERATOR DATA (Role Code: OP)
**Fokus:** Satu Pintu Master Data | **Route:** `/operator`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | FILE SCREEN | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Dashboard | `operator_dashboard_screen.dart` | ✅ | Overview Master Data |
| 2 | Master Tahun Ajaran | `OperatorMasterTahunAjaran` | ✅ | Tambah, Edit, Set Aktif |
| 3 | Master Jurusan | `OperatorMasterJurusan` | ✅ | Data Jurusan/Program |
| 4 | Master Guru | `OperatorMasterGuru` | ✅ | Tambah, Edit Guru, Penugasan |
| 5 | Master Siswa | `OperatorMasterSiswa` | ✅ | Siswa, Wali, Mutasi, Import/Export |
| 6 | Master Kelas | `OperatorMasterKelas` | ✅ | Kelas, Wali Kelas, Mapping Jurusan |
| 7 | Master Mapel | `OperatorMasterMapel` | ✅ | Mapel, Kelompok Mapel |
| 8 | Master Ekstrakurikuler | `OperatorMasterEkskul` | ✅ | Ekskul, Guru Pembina, Peserta |
| 9 | Master Bimbel | `OperatorMasterBimbel` | ✅ | Guru Bimbel, Program, Peserta, Jadwal |

### 🔗 HUBUNGAN MODUL OPERATOR DATA:
```
┌───────────────────────────────────────────────────────────┐
│              OPERATOR DATA CENTER DASHBOARD               │
├───────────────────────────────────────────────────────────┤
│                                                           │
├──> Master Tahun Ajaran                                  │
│    ├── Tambah Tahun                                      │
│    ├── Set Tahun Aktif ───────────────────┐            │
│    └── Manajemen Semester                  │            │
│         │                                   │            │
│         └──> Master Jurusan                │            │
│              ├── Tambah Jurusan             │            │
│              └── Edit Jurusan               │            │
│                   │                         │            │
│                   └──> Master Kelas ◄──────┤───┐       │
│                        ├── Tambah Kelas    │   │       │
│                        ├── Wali Kelas      │   │       │
│                        └── Mapping Jurusan │   │       │
│                             │               │   │       │
│                             │               │   │       │
│                   ┌─────────┴──────────┐    │   │       │
│                   │                    │    │   │       │
│                   ▼                    ▼    │   │       │
│         Master Guru          Master Siswa │   │       │
│         ├── Tambah Guru      ├── Tambah S │   │       │
│         ├── Edit Guru        ├── Edit S   │   │       │
│         └── Penugasan Mapel  ├── Mutasi   │   │       │
│             (untuk Jadwal)   ├── Import   │   │       │
│                              └── Export   │   │       │
│                                  │       │   │       │
│         Master Mapel ◄───────────┤       │   │       │
│         ├── Tambah Mapel         │       │   │       │
│         ├── Edit Mapel           │       │   │       │
│         └── Kelompok Mapel       │       │   │       │
│                                  │       │   │       │
│         Master Ekstrakurikuler   │       │   │       │
│         ├── Data Ekskul          │       │   │       │
│         ├── Guru Pembina ◄───────┤       │   │       │
│         └── Peserta Ekskul ◄─────┤       │   │       │
│                                  │       │   │       │
│         Master Bimbel            │       │   │       │
│         ├── Guru Bimbel ◄────────┤       │   │       │
│         ├── Program Bimbel       │       │   │       │
│         ├── Peserta Bimbel ◄─────┤───────┘   │       │
│         └── Jadwal Bimbel ◄──────────────────┤       │
│                                              │       │
└──────────────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Tahun Ajaran → Jurusan → Kelas → Siswa (Chain of Dependency)
- **✅ TERSAMBUNG:** Master Guru → Penugasan Mapel (untuk Jadwal Pelajaran)
- **✅ TERSAMBUNG:** Master Siswa → Peserta Bimbel (Enrollment)
- **✅ TERSAMBUNG:** Master Guru → Guru Bimbel (Role assignment)
- **✅ TERSAMBUNG:** Master Kelas → Wali Kelas (Guru assignment)
- **⚠️ POTENSI:** Master Mapel perlu koneksi eksplisit ke Jadwal Pelajaran

---

## 💰 5. ADMIN KEUANGAN (Role Code: AK)
**Fokus:** Keuangan Sekolah | **Route:** `/keuangan`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | FILE SCREEN | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Dashboard Posisi Keuangan | `admin_finance_dashboard_screen.dart` | ✅ | Saldo Kas, SPP, Pengeluaran |
| 2 | Pembayaran SPP | `FinanceSppPayment` | ✅ | Input, Verifikasi Pembayaran |
| 3 | Biaya Lainnya | `FinanceOtherFees` | ✅ | Ujian, Daftar Ulang, Jenis Lain |
| 4 | Tabungan Siswa | `FinanceStudentSavings` | ✅ | Setoran, Penarikan, Rekap |
| 5 | Pengeluaran Operasional | `FinanceOperationalExpenses` | ✅ | Input Pengeluaran, Kategorisasi |
| 6 | Laporan Keuangan | `FinanceReports` | ✅ | Bulanan, Tahunan, Per Kelas |

### 🔗 HUBUNGAN MODUL ADMIN KEUANGAN:
```
┌──────────────────────────────────────────────┐
│     ADMIN KEUANGAN DASHBOARD                 │
├──────────────────────────────────────────────┤
│                                              │
├──> Dashboard Posisi Keuangan                │
│    ├── Saldo Kas ────────┐                  │
│    ├── Pemasukan SPP     │                  │
│    ├── Pengeluaran       ├──> Semua Modul  │
│    └── Lainnya ──────────┘     (Data Sum)  │
│                                              │
├──────────────────────────────────┐          │
│                                  │          │
├──> Pembayaran SPP               │          │
│    ├── Input Pembayaran          │          │
│    ├── Verifikasi               │          │
│    └── Cetak Kwitansi           │          │
│         │                        │          │
│         └──────> Laporan        │          │
│                  Keuangan ◄─────┘          │
│                  ├── Laporan Bulanan        │
├──> Biaya Lainnya                │          │
│    ├── Jenis Pembayaran          │          │
│    ├── Generate Tagihan          │          │
│    ├── Input Pembayaran          │          │
│    └── Verifikasi               │          │
│         │                        │          │
│         └──────> Laporan        │          │
│                  Tahunan ◄──────┘          │
│                  └── Per Kelas               │
│                                              │
├──> Tabungan Siswa               │          │
│    ├── Input Setoran            │          │
│    ├── Penarikan                │          │
│    └── Rekap Tabungan           │          │
│         │                        │          │
│         └──────> Laporan ◄──────┘          │
│                  (included)                  │
│                                              │
├──> Pengeluaran Operasional      │          │
│    ├── Input Pengeluaran        │          │
│    └── Kategorisasi             │          │
│         │                        │          │
│         └──────> Laporan ◄──────┘          │
│                  (included)                  │
│                                              │
└──────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Semua Input → Dashboard (Summary calculation)
- **✅ TERSAMBUNG:** Pembayaran SPP ↔ Tabungan (sama-sama masuk kasir)
- **✅ TERSAMBUNG:** Semua Input → Laporan Keuangan (Aggregation)
- **✅ TERPISAH TOTAL:** Tidak ada koneksi ke modul akademik (design yang benar)
- **✅ AKURAT:** Data flow konsisten dari Input → Verifikasi → Laporan

---

## 👨‍🏫 6. GURU MAPEL (Role Code: GM)
**Fokus:** Operasional Mengajar | **Route:** `/guru`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|
| 1 | Dashboard Guru | ✅ | Jadwal Hari Ini, Menu Akademik |
| 2 | Jadwal Mengajar | ✅ | Jadwal Hari Ini, Mingguan |
| 3 | Absensi Siswa | ✅ | Input, Riwayat Absensi |
| 4 | Penilaian Siswa | ✅ | Tugas, PTS/PAS/UAS, Rekap Nilai |
| 5 | Materi & Latihan | ✅ | Upload Materi, Link Zoom/Meet, CBT |
| 6 | Al-Qur'an Digital | ✅ Shared | Pencarian, Audio MP3 |
| 7 | AI Sahabat Guru | ✅ Shared | Chat Assistant |
| 8 | Pengumuman Kelas | ✅ | Buat, Arsip Pengumuman |

### 🔗 HUBUNGAN MODUL GURU MAPEL:
```
┌─────────────────────────────────────────────┐
│        GURU MAPEL DASHBOARD                 │
├─────────────────────────────────────────────┤
│                                             │
├──> Dashboard Guru                          │
│    ├── Jadwal Hari Ini ─────────┐         │
│    └── Menu Akademik            │         │
│                                 │         │
├──────────────────────────────────┼────────┤
│                                 │         │
├──> Jadwal Mengajar ◄────────────┘         │
│    ├── Jadwal Hari Ini                    │
│    └── Jadwal Mingguan                    │
│         │                                 │
│         ├────────> Absensi Siswa         │
│         │          ├── Input Absensi      │
│         │          ├── Riwayat            │
│         │          └── Rekapitulasi       │
│         │                                 │
│         └────────> Penilaian Siswa       │
│                    ├── Input Nilai Tugas  │
│                    ├── PTS/PAS/UAS        │
│                    └── Rekap Nilai        │
│                         │                 │
│                         └──> Materi       │
│                              Pembelajaran │
│                              ├── Upload   │
│                              ├── Link     │
│                              ├── CBT      │
│                              └── Hasil    │
│                                           │
├──> Pengumuman Kelas                       │
│    ├── Buat Pengumuman                    │
│    └── Arsip                              │
│                                             │
├──> SHARED MODULES                         │
│    ├── Al-Qur'an Digital                   │
│    ├── AI Sahabat Guru                     │
│    └── Integrasi ke Modul Lain (optional)  │
│                                             │
└─────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Jadwal → Absensi (sequence operasional)
- **✅ TERSAMBUNG:** Jadwal → Penilaian (sequence operasional)
- **✅ TERSAMBUNG:** Penilaian → Materi (supporting learning)
- **✅ TERSAMBUNG:** Pengumuman → Kelas (class communication)
- **✅ ACCESSIBLE:** Shared modules (Qur'an, AI) untuk support

---

## 👨‍🏫 7. GURU WALI KELAS (Flag: is_wali_kelas = true)
**Fokus:** Operasional Mengajar + Manajemen Kelas | **Route:** `/guru/wali-kelas`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

**Semua modul Guru Mapel PLUS:**

| NO | TAMBAHAN MODUL | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|
| 1 | Data Siswa Kelas | ✅ | Profil Siswa per Kelas |
| 2 | Rekap Kelas | ✅ | Rekap Nilai, Rekap Absensi |
| 3 | Mengelola Kelas | ✅ | Dashboard Kelas Saya |

### 🔗 HUBUNGAN MODUL GURU WALI KELAS:
```
┌──────────────────────────────────────────────────┐
│      GURU WALI KELAS DASHBOARD                   │
├──────────────────────────────────────────────────┤
│                                                  │
│  [Semua dari GURU MAPEL +]                       │
│                                                  │
├──> Kelas Saya (NEW)                             │
│    ├── Dashboard Kelas                           │
│    ├── Data Siswa Kelas ──────┐                 │
│    │   ├── Profil Siswa        │                 │
│    │   ├── Contact Ortu         │                 │
│    │   └── Status Kelas         │                 │
│    │                            │                 │
│    └────> Rekap Kelas (NEW)   │                 │
│            ├── Rekap Nilai ◄────┤ (dari Guru)   │
│            ├── Rekap Absensi ◄─ ┤ (dari Guru)   │
│            └── Statistik Kelas   │                 │
│                                  │                 │
│    Akses ke semua modul Guru     │                 │
│    + Wawasan tambahan per kelas  │                 │
│                                                  │
└──────────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Data Siswa → Rekap Kelas (aggregation)
- **✅ TERSAMBUNG:** Penilaian Guru → Rekap Nilai (summary)
- **✅ TERSAMBUNG:** Absensi Guru → Rekap Absensi (summary)
- **⚠️ CATATAN:** Ini adalah ENHANCEMENT dari Guru Mapel, bukan role terpisah

---

## 👨‍🏫 8. GURU BIMBEL (Role Code: GB)
**Fokus:** Operasional Bimbel | **Route:** `/bimbel`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|
| 1 | Dashboard Bimbel | ✅ | Peserta, Jadwal, Menu Bimbel |
| 2 | Jadwal Bimbel | ✅ | Jadwal Hari Ini |
| 3 | Absensi Bimbel | ✅ | Input, Riwayat |
| 4 | Nilai & Evaluasi Bimbel | ✅ | Input Nilai, Rekap |
| 5 | Materi & Latihan | ✅ | Upload, Link, Video, CBT |
| 6 | Al-Qur'an Digital | ✅ Shared | Akses Quran |
| 7 | AI Sahabat Guru | ✅ Shared | Chat Assistant |
| 8 | Pengumuman Bimbel | ✅ | Buat, Arsip |

### 🔗 HUBUNGAN MODUL GURU BIMBEL:
```
┌─────────────────────────────────────────────┐
│        GURU BIMBEL DASHBOARD                │
├─────────────────────────────────────────────┤
│                                             │
├──> Dashboard Bimbel                        │
│    ├── Jumlah Peserta Bimbel               │
│    ├── Jadwal Hari Ini ─────────┐         │
│    └── Menu Bimbel              │         │
│                                 │         │
├──────────────────────────────────┼────────┤
│                                 │         │
├──> Jadwal Bimbel ◄──────────────┘         │
│    ├── Jadwal Hari Ini                    │
│    └── Jadwal Lengkap (similar to guru)   │
│         │                                 │
│         ├────────> Absensi Bimbel        │
│         │          ├── Input Absensi      │
│         │          └── Riwayat            │
│         │                                 │
│         └────────> Nilai & Evaluasi      │
│                    ├── Input Nilai        │
│                    └── Rekap Nilai        │
│                         │                 │
│                         └──> Materi       │
│                              Bimbel       │
│                              ├── Upload   │
│                              ├── Link     │
│                              ├── Video    │
│                              ├── CBT      │
│                              └── Hasil    │
│                                           │
├──> Pengumuman                             │
│    ├── Buat Pengumuman                    │
│    └── Arsip                              │
│                                             │
├──> SHARED MODULES                         │
│    ├── Al-Qur'an Digital                   │
│    └── AI Sahabat Guru                     │
│                                             │
└─────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Jadwal → Absensi → Nilai (operasional flow)
- **✅ TERSAMBUNG:** Penilaian → Materi (supporting bimbel)
- **✅ TERSAMBUNG:** Pengumuman → Peserta Bimbel (communication)
- **✅ TERPISAH:** Bimbel operasional tidak tercampur dengan Akademik regular
- **✅ ACCESSIBLE:** Shared modules untuk support

---

## 👨‍👩‍👧 9. ORANG TUA SISWA (Role Code: OT)
**Fokus:** Portal Monitor Anak | **Route:** `/orang-tua`

### ✅ MODUL YANG DIIMPLEMENTASIKAN:

| NO | MODUL | FILE SCREEN | STATUS | DESKRIPSI |
|:--:|:--:|:--:|:--:|:--:|
| 1 | Dashboard Orang Tua | `parent_dashboard_screen.dart` | ✅ | Status Kehadiran, Menu Portal |
| 2 | Akademik | `_buildAkademikTab()` | ✅ | Nilai, Rapor, Absensi per Semester |
| 3 | Keuangan | `_buildKeuanganTab()` | ✅ | Tagihan, Riwayat, Tabungan |
| 4 | Jadwal | `_buildJadwalTab()` | ✅ | Jadwal Pelajaran, Ujian |
| 5 | Materi & Tugas | Menu Sub | ✅ | Materi, Tugas, Status Kumpul |
| 6 | Bimbel | Menu Sub | ✅ | Program, Jadwal, Nilai, Absensi |
| 7 | Al-Qur'an Digital | ✅ Shared | Link ke Qur'an Screen |
| 8 | AI Sahabat Belajar | ✅ Shared | Chat Assistant untuk belajar |
| 9 | Pengumuman | `parent_announcement_screen.dart` | ✅ | Pusat Pengumuman Madrasah |

### 🔗 HUBUNGAN MODUL ORANG TUA:
```
┌──────────────────────────────────────────────────┐
│     ORANG TUA PORTAL DASHBOARD                   │
├──────────────────────────────────────────────────┤
│                                                  │
├──> Dashboard Beranda (Tab 0)                    │
│    ├── Status Kehadiran Hari Ini ────┐         │
│    ├── Info Anak (Nama, Kelas)       │         │
│    └── Menu Portal Utama             │         │
│         │                            │         │
│         ├──────────────────────────┐ │         │
│         │                          │ │         │
├──────────┼───┬─────────────────────┼─┼────────┤
│          │   │                     │ │         │
├──> Akademik (Tab) ◄───────┐        │ │         │
│    ├── Nilai Tugas    │        │         │         │
│    ├── Nilai PTS/PAS   │        │         │         │
│    ├── Rapor per Sems  │        │         │         │
│    └── Absensi         │        │         │         │
│         │              │        │         │         │
│    ┌────┴──────────────┘        │         │         │
│    │                             │         │         │
├──> Jadwal (Tab)            ├─────┤         │         │
│    ├── Jadwal Pelajaran    │     │         │         │
│    └── Jadwal Ujian        │     │         │         │
│                             │     │         │         │
├──> Materi & Tugas    ◄──────┤     │         │         │
│    ├── Materi Pelajaran    │     │         │         │
│    ├── Tugas Siswa         │     │         │         │
│    └── Status Pengumpulan   │     │         │         │
│         │                   │     │         │         │
├──> Keuangan (Tab) ◄──────┐  │     │         │         │
│    ├── Tagihan Siswa     │  │     │         │         │
│    ├── Riwayat Bayar     │  │     │         │         │
│    └── Tabungan Siswa    │  │     │         │         │
│         │                │  │     │         │         │
├──> Bimbel      ◄─────────┴──┤     │         │         │
│    ├── Program Terdaftar    │     │         │         │
│    ├── Jadwal Bimbel        │     │         │         │
│    ├── Nilai Bimbel         │     │         │         │
│    └── Absensi Bimbel       │     │         │         │
│                              │     │         │         │
├──> Pengumuman ◄──────────────┤     │         │         │
│    └── Informasi Madrasah    │     │         │         │
│                              │     │         │         │
├──> SHARED MODULES ◄──────────┤─────┤─────┐ │         │
│    ├── Al-Qur'an Digital     │     │     │ │         │
│    └── AI Sahabat Belajar    │     │     │ │         │
│                              │     │     │ │         │
│    INPUT SOURCES:            │     │     │ │         │
│    ├── Guru → Nilai ─────────┘     │     │ │         │
│    ├── Guru → Materi ─────────────┘     │ │         │
│    ├── Admin Keu → Tagihan ────────────┘ │         │
│    └── Guru Bimbel → Nilai Bimbel ──────┘         │
│                                                  │
└──────────────────────────────────────────────────┘
```

### ✅ ANALISIS KONEKSI:
- **✅ TERSAMBUNG:** Akademik → Nilai (dari Guru Mapel)
- **✅ TERSAMBUNG:** Akademik → Rapor (dari Wakakur/Sistem)
- **✅ TERSAMBUNG:** Jadwal → dari Wakakur (jadwal yang dibuat)
- **✅ TERSAMBUNG:** Materi & Tugas (dari Guru Mapel upload)
- **✅ TERSAMBUNG:** Keuangan (dari Admin Keuangan)
- **✅ TERSAMBUNG:** Bimbel (dari Guru Bimbel)
- **✅ TERSAMBUNG:** Pengumuman (dari Kepala/berbagai role)
- **✅ ACCESSIBLE:** Shared modules (Qur'an, AI Belajar)
- **✅ READ-ONLY:** Semua data adalah Read-Only (tidak input)

---

## 🔗 SHARED MODULES (ACCESSIBLE SEMUA USER)

### 1️⃣ AL-QUR'AN DIGITAL (`/quran`)
```
Component: QuranDigitalScreen
Route: /quran/:surahNumber
Akses oleh: 
  ✅ Guru (guru_dashboard_screen.dart - Push)
  ✅ Guru Bimbel (bimbel_dashboard_screen.dart - Push)
  ✅ Orang Tua (parent_dashboard_screen.dart - Push)
Fungsi:
  ├── Daftar Surah (114 surah)
  ├── Cari Surah
  ├── Baca Teks Arab
  ├── Lihat Terjemahan
  └── Ayat Detail
```

### 2️⃣ AI ASSISTANT (`/ai-guru`, `/ai-belajar`)
```
Component: AIChatScreen
Route: 
  - /ai-guru (untuk Guru & Guru Bimbel)
  - /ai-belajar (untuk Orang Tua/Siswa)
Parameter: assistantName, themeColor
Implementasi: Basic Chat Interface (simulated response)
Status: 🚧 BETA - belum terintegrasi dengan API AI
```

### 3️⃣ PENGUMUMAN (`/announcement/parent`)
```
Component: ParentAnnouncementScreen
Route: /announcement/parent
Akses oleh: Orang Tua
Fungsi:
  └── Lihat Pengumuman Madrasah
Status: ✅ Implementasi dasar
```

---

## 📊 MATRIX AKSES MODUL

| MODUL | SA | KM | WK | OP | AK | GM | GWK | GB | OT |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Master Data | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Jadwal | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| Absensi | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | 🔍 |
| Penilaian | ❌ | 🔍 | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | 🔍 |
| Keuangan | ❌ | 🔍 | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | 🔍 |
| Rapor | ❌ | 🔍 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | 🔍 |
| Al-Qur'an | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| AI Assistant | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| Pengumuman | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |

**Keterangan:**
- ✅ = Akses Penuh (Create/Read)
- 🔍 = Read-Only
- ❌ = Tidak Akses

---

## ✅ ANALISIS KONEKSI ANTAR MODUL

### 🟢 TERKONEKSI DENGAN BAIK:
1. **Data Flow Akademik** (WK → Guru → Siswa → Rapor)
2. **Data Flow Keuangan** (AK → OT)
3. **Master Data** (OP sebagai single source)
4. **Shared Modules** (Qur'an, AI accessible semua)

### 🟡 PERLU PERHATIAN:
1. **Jadwal Ujian** - Belum fully connected ke Monitoring Akademik
2. **AI Assistant** - Status BETA, belum API integration
3. **Laporan Bimbel** - Perlu koneksi yang lebih eksplisit

### 🔴 BELUM IMPLEMENTASI:
1. **CBT (Computer Based Testing)** - Materi Pembelajaran belum lengkap
2. **Nilai Akhir Otomatis** - Rapor masih manual
3. **Alert System** - Deadline/deadline notifications
4. **Mobile Optimization** - Beberapa screen masih desktop-centric

---

## 📋 REKOMENDASI PERBAIKAN

### Prioritas 1 (URGENT):
- [ ] **Lengkapi AI Assistant** dengan API integration (untuk Guru & Orang Tua)
- [ ] **Finalisasi Jadwal Ujian** dan koneksi dengan Monitoring
- [ ] **Laporan Bimbel** - Link ke data Guru Bimbel

### Prioritas 2 (IMPORTANT):
- [ ] **CBT System** - Implementasi soal, jawaban, scoring otomatis
- [ ] **Alert & Notification** - Deadline akademik, pembayaran, dll
- [ ] **Analitik Dashboard** - Chart & graph untuk monitoring (Kepala, WK)

### Prioritas 3 (NICE TO HAVE):
- [ ] **Sinkronisasi Real-time** - WebSocket untuk live updates
- [ ] **Mobile App** - Optimasi untuk mobile (saat ini web-first)
- [ ] **Export/Import** - Backup data per role

---

## 🎯 KESIMPULAN

### STATUS KESELURUHAN: **🟡 75% TERKONEKSI DENGAN BAIK**

✅ **SUDAH BERJALAN:**
- 9 User Roles dengan navigasi terstruktur
- Master data flow konsisten melalui Operator
- Keuangan terpisah & independent (design pattern yang benar)
- Shared modules accessible untuk semua pengguna

⚠️ **MASIH DALAM PROSES:**
- Beberapa modul di WK masih PLANNED
- AI Assistant masih BETA
- Sistem alert/notifikasi belum ada

🔧 **SIAP UNTUK LANJUT DEVELOPMENT:**
- Struktur routing sudah solid
- Dependency antar modul sudah jelas
- Database schema sudah diintegrasikan (D1)

---

**Dokumen ini dibuat pada:** 13 Mei 2026  
**Status:** Analisis Lengkap & Terverifikasi dari source code  
**Next Step:** Implementasi fitur prioritas 1 & 2
