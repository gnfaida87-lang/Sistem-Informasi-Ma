
DOKUMEN SINKRONISASI DATA & ROLE

## 1. TUJUAN DOKUMEN

Dokumen ini mendefinisikan:

* Sumber data utama (Single Source of Truth)
* Arah sinkronisasi data antar role
* Hak akses baca/tulis per domain
* Aturan validasi & publikasi
* Larangan lintas domain
* Kontrak data untuk AI Agent

📌 **AI Agent wajib patuh pada dokumen ini.**

---

## 2. DEFINISI ROLE (KANONIK)

| Role Code | Nama Role                   |
| --------- | --------------------------- |
| SA        | Superadmin                  |
| KM        | Kepala Madrasah             |
| WK        | Wakil Kurikulum             |
| OP        | Operator Data               |
| AK        | Admin Keuangan              |
| GM        | Guru Mata Pelajaran         |
| WL        | Wali Kelas *(flag pada GM)* |
| GB        | Guru Bimbel                 |
| OT        | Orang Tua Siswa             |

---

## 3. DOMAIN DATA & PENGENDALI UTAMA

| Domain Data     | Kode  | Pengendali Tunggal         |
| --------------- | ----- | -------------------------- |
| User & Security | D-USR | SA                         |
| Master Siswa    | D-SIS | OP                         |
| Master Guru     | D-GUR | OP                         |
| Kelas & Rombel  | D-KLS | OP                         |
| Mata Pelajaran  | D-MAP | OP                         |
| Jadwal Akademik | D-JDW | WK                         |
| Absensi         | D-ABS | GM                         |
| Nilai           | D-NIL | GM (Input) → WK (Validasi) |
| Rapor           | D-RPR | WK                         |
| Bimbel          | D-BBL | OP                         |
| Keuangan        | D-KEU | AK                         |
| Pengumuman      | D-PNG | Role Pembuat               |
| AI & API        | D-AI  | SA                         |

---

## 4. ATURAN UMUM SINKRONISASI (GLOBAL RULES)

### RULE-01: SINGLE SOURCE OF TRUTH

Setiap domain data **hanya memiliki satu pengendali utama**.

### RULE-02: WRITE RESTRICTION

Role non-pengendali **DILARANG**:

* Mengedit
* Menghapus
* Mengunci
  data domain yang bukan kewenangannya.

### RULE-03: VALIDATION FLOW

Data akademik **WAJIB** melalui:

```
Guru → Wakil Kurikulum → Publish
```

### RULE-04: READ ONLY PROPAGATION

Data yang sudah divalidasi → **READ ONLY** bagi role lain.

### RULE-05: DOMAIN ISOLATION

Domain Keuangan **TIDAK BOLEH**:

* Mengakses nilai
* Mengakses absensi
* Mengakses rapor detail

---

## 5. KONTRAK SINKRONISASI PER ROLE (AI CONTRACT)

---

## 5.1 OPERATOR DATA (OP)

### WRITE AUTHORITY:

* D-SIS, D-GUR, D-KLS, D-MAP, D-BBL

### READ AUTHORITY:

* Semua domain (kecuali D-AI secret)

### SYNC OUT:

```
OP → WK : Kelas, Guru, Mapel
OP → GM : Daftar Siswa, Kelas
OP → AK : Identitas Siswa
OP → OT : Profil Anak
```

### AI CONSTRAINT:

❌ AI tidak boleh membuat atau mengedit data siswa tanpa OP

---

## 5.2 WAKIL KURIKULUM (WK)

### WRITE AUTHORITY:

* D-JDW
* D-RPR
* Validasi D-NIL

### READ AUTHORITY:

* D-SIS, D-GUR, D-KLS, D-ABS

### SYNC OUT:

```
WK → GM : Jadwal Final
WK → OT : Rapor, Jadwal
WK → KM : Laporan Akademik
```

### AI CONSTRAINT:

❌ AI WK tidak boleh input nilai langsung

---

## 5.3 GURU MATA PELAJARAN (GM)

### WRITE AUTHORITY:

* D-ABS
* D-NIL
* D-MAT (Materi)
* D-TGS (Tugas)

### READ AUTHORITY:

* Jadwal Mengajar
* Data Siswa Kelasnya

### SYNC OUT:

```
GM → WK : Nilai, Absensi
GM → OT : Nilai, Absensi (setelah publish)
```

### AI CONSTRAINT:

❌ AI Guru tidak boleh publish rapor
❌ AI Guru tidak boleh ubah jadwal

---

## 5.4 ADMIN KEUANGAN (AK)

### WRITE AUTHORITY:

* D-KEU

### READ AUTHORITY:

* D-SIS (identitas dasar)

### SYNC OUT:

```
AK → OT : Tagihan, Pembayaran
AK → WL : Status Pembayaran
AK → KM : Laporan Keuangan
```

### AI CONSTRAINT:

❌ AI Keuangan tidak boleh akses nilai

---

## 5.5 ORANG TUA SISWA (OT)

### READ AUTHORITY:

* D-NIL (published)
* D-RPR
* D-ABS
* D-KEU
* D-JDW

### WRITE AUTHORITY:

* ❌ NONE

### AI CONSTRAINT:

❌ AI Ortu tidak boleh mengubah data akademik
❌ AI Ortu hanya menjelaskan & membimbing

---

## 6. MATRISK HAK AKSES (AI DECISION TABLE)

| Domain ↓ / Role → | OP | WK | GM | AK | OT |
| ----------------- | -- | -- | -- | -- | -- |
| D-SIS             | W  | R  | R  | R  | R  |
| D-JDW             | R  | W  | R  | ✖  | R  |
| D-ABS             | ✖  | R  | W  | ✖  | R  |
| D-NIL             | ✖  | V  | W  | ✖  | R  |
| D-RPR             | ✖  | W  | R  | ✖  | R  |
| D-KEU             | ✖  | ✖  | ✖  | W  | R  |

Legend:
W = Write | R = Read | V = Validate | ✖ = No Access

---

## 7. EVENT & WORKFLOW (AI TRIGGER)

### EVENT: NILAI SELESAI DIINPUT

```
IF semua guru selesai input
THEN notify WK
```

### EVENT: RAPOR DIVALIDASI

```
WK publish rapor
→ notify OT
→ lock nilai
```

### EVENT: PEMBAYARAN MASUK

```
AK verify pembayaran
→ update status wali kelas
→ notify OT
```

---

## 8. LOGGING & AUDIT (WAJIB)

Setiap AI action harus mencatat:

* role
* domain
* action
* timestamp
* sumber data

---

## 9. LARANGAN KERAS (AI GUARDRAIL)

🚫 AI tidak boleh:

* Membuat data siswa
* Menghapus nilai
* Mengedit rapor final
* Membuka API key
* Melanggar domain isolation

---

## 10. STATUS DOKUMEN

**Status**: FINAL – SIAP PRODUKSI
**Digunakan oleh**:

* AI Agent
* Backend Rule Engine
* Auditor
* Tim Dev

---

