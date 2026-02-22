Sistem Informasi Sekolah Berbasis AI

Status : FINAL
Level : HARD ARCHITECTURE
Audience : Backend, AI Agent, Auditor
Sifat : WAJIB DIPATUHI

1. PRINSIP DESAIN ERD

Satu user = satu akun

Satu user = satu role utama

Role tidak dipilih saat login

Hak akses ditentukan dari role

Wali kelas = flag, bukan role

AI tidak mengubah struktur ini

2. ENTITAS UTAMA
2.1 USERS (Auth Identity)

Sumber utama autentikasi
Sinkron dengan auth.users Supabase

USERS
-----
id (uuid, PK)           ← auth.uid()
email (varchar)
username (varchar)
password_hash (managed by Supabase)
is_active (boolean)
created_at (timestamp)
last_login_at (timestamp)


Catatan:

Tidak menyimpan role di auth.users

Role disimpan di tabel terpisah

2.2 ROLES (Master Role – Statis)
ROLES
-----
id (int, PK)
code (varchar)  ← UNIQUE
name (varchar)
description (text)


Data awal (SEED – tidak boleh diubah AI):

SUPERADMIN
KEPALA_MADRASAH
WAKIL_KURIKULUM
OPERATOR_DATA
ADMIN_KEUANGAN
GURU_MAPEL
GURU_BIMBEL
ORANG_TUA

2.3 USER_ROLES (Relasi User ke Role)
USER_ROLES
----------
id (uuid, PK)
user_id (uuid, FK → USERS.id)
role_id (int, FK → ROLES.id)
is_primary (boolean) ← selalu TRUE


Aturan keras:

Satu user hanya satu role primary

Tidak ada multi-role aktif

Tidak ada role gabungan

3. ENTITAS PROFIL (BERDASARKAN ROLE)
3.1 GURU
GURU
----
id (uuid, PK)
user_id (uuid, FK → USERS.id)
nip (varchar)
nama (varchar)
is_wali_kelas (boolean)
created_at


Catatan:

is_wali_kelas = true → tambahan hak

Tidak membuat role baru

3.2 SISWA
SISWA
-----
id (uuid, PK)
nis (varchar)
nama (varchar)
kelas_id (uuid)
status (active/inactive)

3.3 ORANG_TUA
ORANG_TUA
---------
id (uuid, PK)
user_id (uuid, FK → USERS.id)
nama (varchar)

3.4 ORANG_TUA_SISWA (Relasi)
ORANG_TUA_SISWA
---------------
id (uuid, PK)
orang_tua_id (uuid, FK)
siswa_id (uuid, FK)


Catatan:

Satu orang tua bisa punya banyak anak

Akses data dibatasi relasi ini

4. RELASI UTAMA (TEXTUAL ERD)
USERS 1───1 USER_ROLES 1───1 ROLES

USERS 1───1 GURU
USERS 1───1 ORANG_TUA

ORANG_TUA 1───N ORANG_TUA_SISWA N───1 SISWA

5. LOGIN FLOW (BERDASARKAN ERD)
Login → auth.users
        ↓
Ambil USERS.id
        ↓
Query USER_ROLES
        ↓
Dapatkan ROLES.code
        ↓
Load menu & dashboard


❌ Tidak ada pilih role
❌ Tidak ada fallback role

6. RLS (ROW LEVEL SECURITY) – PRINSIP

Contoh prinsip (bukan SQL):

Guru → hanya data kelas & mapel sendiri

Orang tua → hanya data anak sendiri

Admin keuangan → hanya tabel keuangan

Superadmin → sistem, bukan akademik

AI Agent tidak pernah bypass RLS.

7. LARANGAN MUTLAK

❌ Role disimpan di frontend
❌ Role dipilih user
❌ Multi role aktif
❌ AI mengubah role
❌ Wali kelas sebagai role