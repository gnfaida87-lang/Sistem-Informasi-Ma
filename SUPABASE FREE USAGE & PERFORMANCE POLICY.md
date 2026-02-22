
# SUPABASE FREE USAGE & PERFORMANCE POLICY

## Sistem Informasi Sekolah Berbasis AI

Status   : FINAL
Level    : HARD POLICY
Audience : AI Agent, Backend, Frontend, DevOps
Sifat    : WAJIB DIPATUHI

---

## 1. TUJUAN DOKUMEN

Dokumen ini menetapkan aturan agar sistem:

* Tetap **ringan**
* **Tidak boros Supabase Free**
* Skalabel untuk sekolah
* Aman untuk integrasi AI Agent

Jika terjadi konflik antara implementasi teknis dan dokumen ini,
**dokumen ini WAJIB diikuti**.

---

## 2. PRINSIP UTAMA

### PRINCIPLE-01: FREE TIER FIRST

Sistem **harus dirancang agar stabil di Supabase Free** tanpa asumsi upgrade.

### PRINCIPLE-02: ROLE-DRIVEN DATA ACCESS

Setiap query database **WAJIB berbasis role dan konteks**.

### PRINCIPLE-03: MOBILE-FIRST PERFORMANCE

Mayoritas akses berasal dari **mobile**, bukan desktop.

---

## 3. ARSITEKTUR RESMI

### Frontend

* Flutter
* Material 3
* Mobile-first
* State disimpan lokal (bukan fetch berulang)

### Backend

* Supabase (PostgreSQL + Auth + RLS)
* Tidak ada query tanpa filter

### Edge & Security

* Cloudflare sebagai:

  * Auth guard
  * Rate limiter
  * Cache layer

### AI Agent

* Read-only context-based
* Tidak polling database
* Tidak realtime listener

---

## 4. ATURAN DATABASE (WAJIB)

### RULE-01: NO FULL TABLE QUERY

❌ DILARANG:

```sql
select * from siswa;
select * from nilai;
```

✔️ WAJIB:

```sql
where kelas_id = ?
where guru_id = auth.uid()
where semester = ?
```

---

### RULE-02: PAGINATION WAJIB

Setiap list:

* siswa
* nilai
* absensi
* pembayaran

**WAJIB pagination / limit**

---

### RULE-03: QUERY SESUAI ROLE

| Role           | Akses Data             |
| -------------- | ---------------------- |
| GURU           | kelas & mapel sendiri  |
| WAKAKUR        | agregat & validasi     |
| ORANG TUA      | data anak sendiri      |
| ADMIN KEUANGAN | keuangan saja          |
| SUPERADMIN     | sistem, bukan akademik |

---

## 5. REALTIME POLICY (SANGAT KERAS)

### RULE-04: REALTIME DILARANG DEFAULT

❌ Tidak boleh realtime untuk:

* Absensi
* Nilai
* Jadwal
* Rapor
* Keuangan

✔️ Realtime hanya diperbolehkan jika:

* Sangat penting
* Jumlah user kecil
* Diset manual

Realtime = koneksi hidup = **boros Supabase Free**

---

## 6. STORAGE POLICY

### RULE-05: NO HEAVY FILES

❌ DILARANG menyimpan:

* Video
* PDF besar
* File materi berat

✔️ BOLEH:

* Link Google Drive
* Link YouTube
* Link Zoom / Meet

Supabase Storage Free **bukan CDN**.

---

## 7. DASHBOARD & ANALYTICS

### RULE-06: AGREGASI SERVER-SIDE

* Gunakan `COUNT`, `SUM`, `AVG`
* Jangan tarik data mentah ke frontend

Dashboard **tidak boleh**:

* Load semua siswa
* Load semua nilai

---

## 8. AI AGENT USAGE POLICY

### RULE-07: AI TIDAK MEMICU QUERY LANGSUNG

AI hanya boleh bekerja dengan konteks:

```json
{
  "role": "GURU_MAPEL",
  "menu": "Penilaian",
  "action": "input_nilai"
}
```

AI:

* Tidak polling
* Tidak realtime
* Tidak looping request

---

## 9. ESTIMASI KAPASITAS AMAN (REALISTIS)

Dengan policy ini:

* 500–1.000 user → AMAN
* 1.500 siswa + guru → AMAN
* 1 tahun ajaran penuh → AMAN

Masalah hanya muncul jika policy dilanggar.

---

## 10. LARANGAN MUTLAK

❌ Query tanpa filter
❌ Realtime berlebihan
❌ Dashboard rakus
❌ File besar di storage
❌ AI mengakses DB langsung

---

## 11. KESIMPULAN RESMI

Dengan mematuhi dokumen ini:

* Sistem **ringan**
* Supabase Free **tidak boros**
* UI responsif di mobile
* AI Agent **aman & konsisten**
* Upgrade **tidak mendesak**

Dokumen ini **FINAL** dan **siap digunakan** sebagai:

* Referensi implementasi
* Pegangan AI Agent
* Standar audit teknis

---

**SELESAI.**
(Tidak ada opsi, tidak ada alternatif.)
