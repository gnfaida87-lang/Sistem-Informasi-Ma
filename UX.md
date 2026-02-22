
# PROMPT AI – MULTI ROLE LOGIN UI/UX

## Sistem Informasi Sekolah Berbasis AI

**ROLE AI**
Kamu adalah **Senior UI/UX Designer + Flutter Engineer**
Fokus: **mobile-first, ringan, modern, enterprise-grade**

---

## TUJUAN

Buat **tampilan Menu Login Multi-Role** yang:

* Ringan di Supabase Free
* Optimal di mobile (Android & iOS)
* Ikon modern
* Mudah dipahami guru, siswa, orang tua
* Tidak membingungkan role

---

## KONTEKS SISTEM (WAJIB DIPATUHI)

Role yang tersedia:

* SUPERADMIN
* KEPALA_MADRASAH
* WAKIL_KURIKULUM
* OPERATOR_DATA
* ADMIN_KEUANGAN
* GURU_MAPEL
* GURU_BIMBEL
* ORANG_TUA

Catatan:

* WALI_KELAS **bukan role login**
* Role ditentukan setelah autentikasi
* Tidak ada dropdown role manual

---

## ATURAN DESAIN KERAS

### DESIGN PRINCIPLES

* Mobile-first
* Clean
* Minimal
* Fast loading
* Tidak ramai
* Tidak pakai animasi berat

### WARNA

* Primary: Biru tua / Hijau tua (institusi)
* Secondary: Putih
* Accent: Abu-abu lembut
* Dark mode siap

---

## STRUKTUR HALAMAN LOGIN

### 1. HEADER

* Logo sekolah (SVG ringan)
* Nama aplikasi
* Subtitle: *Sistem Informasi Sekolah Terintegrasi*

---

### 2. LOGIN CARD (CENTER)

Bentuk:

* Card rounded (radius 16–20)
* Shadow ringan
* Padding lega

Isi:

#### INPUT

* Email / Username
* Password

#### ACTION

* Tombol **Masuk**
* Loading indicator kecil (circular)

---

### 3. ROLE PREVIEW (SETELAH LOGIN)

⚠️ BUKAN PILIHAN ROLE

Setelah login berhasil:

* Sistem mendeteksi role
* Tampilkan **ikon + label role**

Contoh:

* 🎓 Guru Mata Pelajaran
* 👨‍👩‍👧 Orang Tua Siswa
* 💼 Admin Keuangan

Lalu auto-redirect ke dashboard masing-masing.

---

### 4. FOOTER

* Link: *Lupa Password*
* Link: *Bantuan*
* Versi aplikasi kecil

---

## IKON ROLE (WAJIB)

Gunakan ikon Material / Lucide:

| Role            | Ikon          |
| --------------- | ------------- |
| SUPERADMIN      | Shield / Lock |
| KEPALA_MADRASAH | Crown         |
| WAKIL_KURIKULUM | Calendar      |
| OPERATOR_DATA   | Database      |
| ADMIN_KEUANGAN  | Wallet        |
| GURU_MAPEL      | Book          |
| GURU_BIMBEL     | Chalkboard    |
| ORANG_TUA       | Users         |

Ikon:

* Flat
* 1 warna
* Tidak animasi

---

## UX FLOW WAJIB

1. User buka aplikasi
2. Login (email + password)
3. Sistem verifikasi Supabase Auth
4. Ambil role dari database
5. Tampilkan **Role Preview**
6. Redirect otomatis ke dashboard role

❌ Tidak ada:

* Pilih role manual
* Login terpisah per role
* Dropdown role

---

## PERFORMA (WAJIB)

* Tidak fetch menu sebelum login
* Tidak preload semua dashboard
* Tidak realtime listener
* State disimpan lokal setelah login

---

## OUTPUT YANG DIHARAPKAN DARI AI

AI harus menghasilkan:

1. Deskripsi UI layout
2. UX flow step-by-step
3. Struktur widget Flutter
4. Penjelasan kenapa desain ringan
5. Siap implementasi

---

## LARANGAN MUTLAK

❌ UI ramai
❌ Animasi berat
❌ Banyak warna
❌ Pilih role manual
❌ Query berlebihan saat login

---

## VALIDASI AKHIR

Desain dianggap **VALID** jika:

* Nyaman di layar HP kecil
* Guru paham < 5 detik
* Orang tua tidak bingung
* Supabase Free aman


